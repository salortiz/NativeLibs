use v6;
use Test;
use NativeLibs:ver<0.0.8>;

# A simple shortcut
my \Util = ::NativeLibs::Searcher;

my $lib;
# A 'must be there' test
given $*VM.config<osname>.lc {
    when 'linux' {
        $lib = Util.try-versions('m', 'sin', 5, 6, 7);
        ok $lib ~~ / 'libm.so.' (\d) /,              "found libm.so.$0";
        my $ver = $0;
        ok $ver == any(5, 6, 7),                     'In version range';

        ok my $dll = NativeLibs::Loader.load($lib),             'So can be loaded';
        is $dll.symbol('sin', :(num64 --> num64))(pi / 2), 1e0, 'used';
        is $dll.symbol('cos', :(num64 --> num64))(pi),    -1e0, 'twice';
        ok $dll.dispose,                                        'and disposed';
	unless "/etc/os-release".IO.lines[0] eq 'NAME="Alpine Linux"' {
            nok Util.try-versions('m', 'sin', 8, 9, 10), 'No version found';

            dies-ok {
		NativeLibs::Loader.load('libm.so.9');
            }, "Can't be loaded";
	}
    }
    when 'darwin' {
    }
    when 'mswin32' | 'mingw' | 'msys' | 'cygwin' {
        $lib = Util.try-versions('kernel32', 'GetLastError');
        ok $lib ~~ / 'kernel32.dll' /,              'found kernel32.dll';
        pass                                        'Unversionized';

        ok my $dll = NativeLibs::Loader.load($lib),                     'Can be loaded';
        is $dll.symbol('GetCurrentProcessId', :(--> uint32))(), $*PID,  'used';
        ok $dll.dispose,                                                'and disposed';

    }
}
my $dbclient = 'mysql';
$dbclient ~= 'client' unless NativeLibs::is-win;
# Test delayed search
my $sub = Util.at-runtime($dbclient, 'mysql_init', 16 .. 22);

does-ok $sub, Callable;
lives-ok { $lib = $sub() },             'Closure can be called';

todo "Can fail if the mysqlclient library isn't installed", 1;
like $lib, NativeLibs::is-win ?? / 'mysql' / !! / 'mysql' .* \d+ /,    "Indeed $lib";

done-testing;

# vim: et
