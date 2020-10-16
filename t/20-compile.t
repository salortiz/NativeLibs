use v6;
use Test;
use NativeLibs:ver<0.0.8>;

plan 1;

my \Compile = NativeLibs::Compile;
my \is-win = NativeLibs::is-win;

ok (my $lc = Compile.new(:name<foo>)),  'Can create compiler';

$lc.compile-all unless $*VM.config<osname> ~~ 'darwin'; # Not ready for
# vim: et
