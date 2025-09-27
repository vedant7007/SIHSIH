import 'package:flutter/foundation.dart';

class AppConfig {
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String aiServiceUrl = 'http://localhost:8000';
  static const String satelliteServiceUrl = 'http://localhost:8001';

  static const String contractAddress = '0x...'; // To be updated after deployment
  static const String rpcUrl = 'https://rpc-amoy.polygon.technology/';

  static Future<void> initialize() async {
    // App initialization complete
  }
}