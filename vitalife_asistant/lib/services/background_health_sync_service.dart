import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';
import 'package:vitalife_asistant/services/health_service.dart';
import 'package:vitalife_asistant/services/firestore_service.dart';
import 'sync_preferences.dart';

class BackgroundHealthSyncService {
  static const String syncTaskId = 'healthDataSync';
  static final _auth = FirebaseAuth.instance;
  static final _healthService = HealthService();
  static final _firestoreService = FirestoreService();

  // ===========================
  // INITIALIZE BACKGROUND TASKS
  // ===========================
  static Future<void> initializeBackgroundSync() async {
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

      // Schedule periodic sync every 30 minutes
      await Workmanager().registerPeriodicTask(
        syncTaskId,
        'syncHealthData',
        frequency: const Duration(minutes: 30),
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(
          networkType: NetworkType.connected, // Only sync with internet
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
        ),
      );

      print('✅ Background health sync initialized');
    } catch (e) {
      print('❌ Error initializing background sync: $e');
    }
  }

  // ===========================
  // CALLBACK DISPATCHER (MUST BE TOP-LEVEL)
  // ===========================
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        if (task == 'syncHealthData') {
          await _syncHealthData();
        }
        return true;
      } catch (e) {
        print('❌ Background sync error: $e');
        return false;
      }
    });
  }

  // ===========================
  // MAIN SYNC LOGIC
  // ===========================
  static Future<void> _syncHealthData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️  No user logged in, skipping sync');
      return;
    }

    try {
      print('🔄 Starting background health data sync...');

      // Fetch latest health data from Google Fit/Apple HealthKit
      final healthData = await _healthService.fetchData();

      // Save to Firebase
      await _firestoreService.saveHeartRate(
        uid: user.uid,
        heartRate: healthData['heartRate'] ?? 0,
        spo2: healthData['spo2'],
        steps: healthData['steps'],
      );

      // Record sync timestamp
      await SyncPreferences.recordSync();

      print('✅ Health data synced to Firebase');
      print('   Heart Rate: ${healthData['heartRate']}');
      print('   SpO2: ${healthData['spo2']}');
      print('   Steps: ${healthData['steps']}');
    } catch (e) {
      print('❌ Error syncing health data: $e');
      rethrow;
    }
  }

  // ===========================
  // MANUAL SYNC (FOR WHEN APP IS OPENED)
  // ===========================
  static Future<void> syncNow() async {
    await _syncHealthData();
  }

  // ===========================
  // STOP BACKGROUND SYNC
  // ===========================
  static Future<void> stopBackgroundSync() async {
    try {
      await Workmanager().cancelByUniqueName(syncTaskId);
      print('🛑 Background sync stopped');
    } catch (e) {
      print('Error stopping background sync: $e');
    }
  }

  // ===========================
  // GET SYNC STATUS
  // ===========================
  static Future<Map<String, dynamic>> getSyncStatus() async {
    final lastSync = await SyncPreferences.getLastSync();
    final syncCount = await SyncPreferences.getSyncCount();

    return {'lastSync': lastSync, 'syncCount': syncCount, 'isEnabled': true};
  }
}
