import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web / Microsoft Edge
      return 'http://127.0.0.1:8000/api/v1';
    }

    // Android Emulator
    return 'http://10.0.2.2:8000/api/v1';
  }

  static const String appName = 'Resto Kay-Y';

  static const Duration requestTimeout =
      Duration(seconds: 15);

  static const Duration connectionTimeout =
      Duration(seconds: 10);
}