use v6;
use Test;
use NativeLibs;

plan 10;

# A simple shortcut
my \Util = ::NativeLibs::Searcher;

my $lib;
# A 'must be there' test
given $*VM.config<osname> {
    when 'linux' {
        $lib = Util.try-versions('m', 'sin', 5, 6, 7);
        ok $lib ~~ / 'libm.so.' (\d) /,              "found libm.so.$0";
        my $ver = $0;
        ok $ver == any(5, 6, 7),                     'In version range';

        ok my $dll = NativeLibs::Loader.load($lib),             'So can be loaded';
        is $dll.symbol('sin', :(num64 --> num64))(pi / 2), 1e0, 'used';
        ok $dll.dispose,                                        'and disposed';

        nok Util.try-versions('m', 'sin', 8, 9, 10), 'No version found';

        dies-ok {
            NativeLibs::Loader.load('libm.so.9');
        }, "Can't be loaded";
    }
}

# Test delayed search
my $sub = Util.at-runtime('mysqlclient', 'mysql_init', 16 .. 20);

does-ok $sub, Callable;
lives-ok { $lib = $sub() },             'Closure can be called';

todo "Can fail if the mysqlclient library isn't installed", 1;
like $lib,  / 'mysql' .* \d+ /,         "Indeed $lib";

