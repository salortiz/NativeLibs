use v6;

unit module NativeLibs:auth<salortiz>:ver<0.0.3>;
use NativeCall :ALL;

our proto sub cannon-name(|) { * }

multi sub cannon-name(Str $libname, Version $version = Version) {
    with $libname.IO {
	if .extension {
	    .Str; # Assume resolved, so don't touch
	} else {
	    $*VM.platform-library-name($_, :$version).Str;
	}
    }
}

multi sub cannon-name(Str $libname, Cool $ver) {
    cannon-name($libname, Version.new($ver));
}

class Loader {
    # This is an HLL clone of MoarVM's loadlib, freelib, et.al. ops.
    # not available in rakudo.
    class DLLib is repr('CPointer') { };

    my  %Libraries;
    my  \dyncall = $*VM.config<nativecall_backend> eq 'dyncall';

    has Str   $.name;
    has DLLib $.library;

    method !dlerror() {
	my sub dlerror(--> Str)         is native { * } # For linux or darwin/OS X
	my sub GetLastError(--> uint32) is native { * } # On Microsoft land
	given $*VM.config<osname> {
	    when 'linux' | 'darwin' {
		dlerror() // '';
	    }
	    when 'mswin32' | 'mingw' | 'msys' | 'cygwin' {
		"error({ GetLastError })";
	    }
	}
    }

    method !dlLoadLibrary(Str $libname --> DLLib) {
	my sub dlLoadLibrary(Str --> DLLib)  is native { * } # dyncall
	my sub dlopen(Str, uint32 --> DLLib) is native { * } # libffi

	dyncall
	    ?? dlLoadLibrary($libname)
	    !! dlopen($libname, 0x102); # RTLD_GLOBAL | RTLD_NOW

    }

    method load(::?CLASS:U: $libname) {
	with self!dlLoadLibrary($libname) {
	    self.bless(:name($libname), :library($_));
	} else {
	    fail "Cannot load native library '$libname'";
	}
    }

    method symbol(::?CLASS $self: Str $symbol, Mu $want = Pointer) {
	my sub dlFindSymbol(DLLib, Str --> Pointer) is native { * } # dyncall
	my sub dlsym(       DLLib, Str --> Pointer) is native { * } # libffi

	my \c = \( $self.DEFINITE ?? $!library !! DLLib, $symbol );
	my \ptr = (dyncall ?? &dlFindSymbol !! &dlsym)(|c);

	if ptr && $want !=== Pointer {
	    nativecast($want, ptr);
	} else {
	    ptr
	}
    }

    method dispose(--> True) {
	sub dlFreeLibrary(DLLib) is native { * }
	sub dlclose(      DLLib) is native { * }
	with $!library {
	    dyncall ?? dlFreeLibrary($_) !! dlclose($_);
	    $_ = Nil;
	}
    }
}

class Searcher {
    method !test($try, $wks) {
	(try cglobal($try, $wks, Pointer)) ~~ Pointer ?? $try !! Nil
    }
    method try-versions(Str $libname, Str $wks, *@vers) {
	my $wlibname;
	for @vers {
	    my $version = $_.defined ?? Version.new($_) !! Version;
	    $wlibname = $_ and last with self!test:
		cannon-name($libname, $version), $wks;
	}
	# Try unversionized
	$wlibname //= self!test: cannon-name($libname), $wks unless @vers;
	$wlibname;
    }

    method at-runtime($libname, $wks, *@vers) {
	-> {
	    with self.try-versions($libname, $wks, |@vers) {
		$_
	    } else {
		# The sensate thing to do is die, but somehow that don't work
		#   ( 'Cannot invoke this object' ... )
		# so let NC::!setup die for us returning $libname.
		# die "Cannot locate native library '$libname'"
		$libname;
	    }
	}
    }
}

# Reexport on demand all of NativeCall
CHECK for NativeCall::EXPORT::.keys {
    UNIT::EXPORT::{$_} := NativeCall::EXPORT::{$_};
}
