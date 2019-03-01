use v6;
use Test;

plan 23;

use-ok 'NativeLibs' or do { diag "Can't continue"; exit 1 };
use NativeLibs;

# Our own classes
ok ::('NativeLibs::Loader') !~~ Failure, 'Class Loader exists';
ok ::('NativeLibs::Searcher') !~~ Failure, 'Class Searcher exists';
ok ::('NativeLibs::&cannon-name') !~~ Failure, 'sub cannon-name exists';
ok ::('NativeLibs::is-win') !~~ Failure, 'constant is-win exists';

# Test transitive imports
ok ::('NativeCall') !~~ Failure, 'NativeCall loaded too';

my \NCexports = ::('NativeCall::EXPORT::ALL');
for '&trait_mod:<is>',
    |<ulonglong Pointer &explicitly-manage &cglobal
     bool CArray ulong void &nativesizeof long size_t OpaquePointer &refresh
     longlong &guess_library_name &nativecast>
{
         ok NCexports::{$_}:exists, "'$_' loaded too";
}

# vim: et
