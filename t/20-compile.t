use v6;
use Test;
use NativeLibs:ver<0.0.8>;

plan 2;

my \Compile = NativeLibs::Compile;
my \is-win = NativeLibs::is-win;
my \is-darwin = $*VM.config<osname> ~~ 'darwin';

ok (my $lc = Compile.new(:name<foo>)),  'Can create compiler';

if !is-darwin {
    $lc.compile-all;
    ok $lc.lib.IO.e, "Object builded"
} else {
    skip "Not ready for darwin"
}
# vim: et
