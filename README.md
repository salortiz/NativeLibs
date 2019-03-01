# NativeLibs

The simple use in your module is:

```perl6
use NativeLibs;
my $Lib; # To keep the reference

sub some_native_func() is native { * } # Note no library needed
… The rest of your module

INIT {
    # Load the needed library
    without $Lib = NativeLibs::Loader.load('libsomelib.so.4') {
        .fail;
    }
}
…
```

If in your native library binding you need to support a range of versions:

```perl6
use NativeLibs;

constant LIB = NativeLibs::Searcher.at-runtime(
    'mysqlclient', # The library short name
    'mysql_init',  # A 'well known symbol'
    16..20	       # range of supported versions
);

sub mysql_get_client_info(--> Str)       is export is native(LIB) { * }

...
```

This is a grow-up version of the original NativeLibs included in DBIish now released
to allow the interested people the testing and discussion of the module.

Other examples in the drivers of https://github.com/perl6/DBIish
