export 'file_opener_stub.dart'
    if (dart.library.html) 'file_opener_web.dart'
    if (dart.library.io) 'file_opener_mobile.dart';
