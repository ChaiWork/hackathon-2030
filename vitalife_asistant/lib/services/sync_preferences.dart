import 'package:shared_preferences/shared_preferences.dart';

class SyncPreferences {
  static const String _lastSyncKey = 'last_health_sync';
  static const String _syncCountKey = 'sync_count';

  // ===========================
  // RECORD SYNC TIMESTAMP
  // ===========================
  static Future<void> recordSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

    final count = prefs.getInt(_syncCountKey) ?? 0;
    await prefs.setInt(_syncCountKey, count + 1);
  }

  // ===========================
  // GET LAST SYNC TIME
  // ===========================
  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // ===========================
  // GET TOTAL SYNC COUNT
  // ===========================
  static Future<int> getSyncCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_syncCountKey) ?? 0;
  }

  // ===========================
  // GET FORMATTED LAST SYNC STRING
  // ===========================
  static Future<String> getLastSyncFormatted() async {
    final lastSync = await getLastSync();
    if (lastSync == null) {
      return 'Never synced';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  // ===========================
  // CLEAR SYNC DATA (FOR TESTING)
  // ===========================
  static Future<void> clearSyncData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_syncCountKey);
  }
}
