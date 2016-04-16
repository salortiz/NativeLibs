# NativeLibs

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

Other examples in the drivers of https://github.com/perl6/DBIish
