export 'pdf_view_factory_stub.dart'
    if (dart.library.html) 'pdf_view_factory_web.dart'
    if (dart.library.io) 'pdf_view_factory_mobile.dart';
