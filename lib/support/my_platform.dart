library support;

export 'platform/unknown.dart'
    if (dart.library.html) 'platform/web.dart'
    if (dart.library.ffi) 'platform/native.dart';
