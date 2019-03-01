use v6;
use Test;
use NativeLibs;

plan 1;

my \Compile = NativeLibs::Compile;
my \is-win = NativeLibs::is-win;

ok (my $lc = Compile.new(:name<foo>)),  'Can create compiler';

$lc.compile-all;
# vim: et
