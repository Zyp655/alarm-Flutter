import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

export 'web_download_stub.dart'
    if (dart.library.html) 'web_download_real.dart';

bool get isAndroidDevice {
  if (kIsWeb) return false;
  return Platform.isAndroid;
}
