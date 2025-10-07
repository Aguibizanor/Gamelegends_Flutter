import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Para web, usa localhost
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      // Para Android emulador, usa 10.0.2.2
      return 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      // Para iOS simulator, usa localhost
      return 'http://localhost:8080';
    } else {
      // Para outras plataformas, usa localhost
      return 'http://localhost:8080';
    }
  }
}