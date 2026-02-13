import 'dart:convert';

import 'package:flutter/services.dart';

import 'api_service.dart';

class AppConfigService {
  static Future<void> initialize() async {
    // Optional runtime override:
    // flutter run --dart-define=BACKEND_URL=http://192.168.1.10:5000
    const backendOverride = String.fromEnvironment('BACKEND_URL');
    if (backendOverride.isNotEmpty) {
      ApiService.configureBaseUrl(backendOverride);
      return;
    }

    try {
      final configRaw =
          await rootBundle.loadString('assets/config/config.json');
      final decoded = jsonDecode(configRaw);
      if (decoded is Map<String, dynamic>) {
        final backendUrl = decoded['backendUrl'];
        if (backendUrl is String && backendUrl.trim().isNotEmpty) {
          ApiService.configureBaseUrl(backendUrl);
        }
      }
    } catch (_) {
      // Keep ApiService defaults if config file cannot be loaded.
    }
  }
}
