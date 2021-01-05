use v6;
use Test;

plan 10;
use NativeLibs:ver<0.0.8>;
my &cn = &NativeLibs::cannon-name;

given $*VM.config<osname>.lc {
    when 'linux'|'freebsd' {
        is cn('foo'),          'libfoo.so',    'libfoo.so';
        is cn('libfoo.so'),    'libfoo.so',    'the same';

        is cn('foo', v2),      'libfoo.so.2',  'libfoo.so.2';
        is cn('libfoo.so.2'),  'libfoo.so.2',  'the same';

        is cn('foo', 2),       'libfoo.so.2',  'libfoo.so.2';
        is cn('libfoo.so.2'),  'libfoo.so.2',  'the same';

        is cn('./foo'),    "$*CWD/libfoo.so",  'In CWD';
        is cn('./libfoo.so'),  './libfoo.so',  'Not modified';

        is cn('/bar/foo'),    "/bar/libfoo.so", 'Absolute';
        is cn('/bar/libfoo.so'), '/bar/libfoo.so',  'Not modified';
    }
    when 'darwin' {
        is cn('foo'),          'libfoo.dylib', 'libfoo.dylib';
        is cn('libfoo.dylib'), 'libfoo.dylib', 'libfoo.dylib';

        is cn('foo', v2),      'libfoo.2.dylib', 'libfoo.2.dylib';
        is cn('libfoo.2.dylib'), 'libfoo.2.dylib', 'libfoo.2.dylib';

        is cn('foo', 2),      'libfoo.2.dylib', 'libfoo.2.dylib';
        is cn('libfoo.2.dylib'), 'libfoo.2.dylib', 'libfoo.2.dylib';

        skip-rest, "Tests missing"; # TODO
    }
    when 'mswin32' | 'mingw' | 'msys' | 'cygwin' {
        is cn('foo'),         'foo.dll',       'foo.dll';
        is cn('foo.dll'),     'foo.dll',       'foo.dll';

        skip-rest, "Tests missing"; # TODO
    }
}
