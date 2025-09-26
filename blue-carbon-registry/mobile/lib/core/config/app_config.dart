import 'package:workmanager/workmanager.dart';

class AppConfig {
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String aiServiceUrl = 'http://localhost:8000';
  static const String satelliteServiceUrl = 'http://localhost:8001';

  static const String contractAddress = '0x...'; // To be updated after deployment
  static const String rpcUrl = 'https://rpc-amoy.polygon.technology/';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    switch (task) {
      case 'sync-offline-data':
        return _syncOfflineData();
      case 'periodic-sync':
        return _periodicSync();
      default:
        return Future.value(true);
    }
  });
}

Future<bool> _syncOfflineData() async {
  try {
    // Implement offline data sync logic
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> _periodicSync() async {
  try {
    // Implement periodic sync logic
    return true;
  } catch (e) {
    return false;
  }
}