import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class DownloadsPathProvider {
  static const MethodChannel _channel =
      const MethodChannel('downloads_path_provider_28');

  static Future<Directory> get downloadsDirectory async {
    final String path = await _channel.invokeMethod('getDownloadsDirectory');
    if (path == null) {
      return null;
    }
    return Directory(path);
  }
}
