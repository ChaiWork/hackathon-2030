import 'package:flutter/material.dart';

class SyncDialog {
  static Future<SyncResult?> show({
    required BuildContext context,
    required Future<Map<String, dynamic>> syncFuture,
  }) async {
    return showDialog<SyncResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _SyncDialogContent(syncFuture: syncFuture);
      },
    );
  }
}

class SyncResult {
  final bool success;
  final Map<String, dynamic> data;
  final String? error;

  SyncResult({required this.success, required this.data, this.error});
}

class _SyncDialogContent extends StatefulWidget {
  final Future<Map<String, dynamic>> syncFuture;

  const _SyncDialogContent({required this.syncFuture});

  @override
  State<_SyncDialogContent> createState() => _SyncDialogContentState();
}

class _SyncDialogContentState extends State<_SyncDialogContent> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  Map<String, dynamic> _syncData = {};

  @override
  void initState() {
    super.initState();
    _performSync();
  }

  Future<void> _performSync() async {
    try {
      final result = await widget.syncFuture;
      setState(() {
        _syncData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading) _buildLoadingState(),
            if (!_isLoading && _hasError) _buildErrorState(),
            if (!_isLoading && !_hasError) _buildSuccessState(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          strokeWidth: 3,
        ),
        const SizedBox(height: 24),
        const Text(
          "Syncing Health Data",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          "Please wait while we fetch your latest health metrics from Google Health Connect...",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildSyncStep("Heart Rate", false, null),
        const SizedBox(height: 8),
        _buildSyncStep("Blood Oxygen (SpO2)", false, null),
        const SizedBox(height: 8),
        _buildSyncStep("Steps", false, null),
      ],
    );
  }

  Widget _buildSyncStep(String label, bool isComplete, dynamic value) {
    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.sync,
          color: isComplete ? Colors.green : Colors.blue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14)),
        if (value != null) ...[
          const Spacer(),
          Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        ),
        const SizedBox(height: 20),
        const Text(
          "Sync Complete!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSyncResultRow(
                "❤️ Heart Rate",
                _syncData["heartRate"] != null
                    ? "${_syncData["heartRate"].toInt()} BPM"
                    : "No data",
                _syncData["heartRate"] != null,
              ),
              const Divider(),
              _buildSyncResultRow(
                "🫁 Blood Oxygen",
                _syncData["spo2"] != null
                    ? "${_syncData["spo2"].toStringAsFixed(0)}%"
                    : "No data",
                _syncData["spo2"] != null,
              ),
              const Divider(),
              _buildSyncResultRow(
                "👟 Steps",
                _syncData["steps"] != null
                    ? "${_syncData["steps"]} steps"
                    : "No data",
                _syncData["steps"] != null,
              ),
              if (_syncData["lastUpdated"] != null) ...[
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Last synced: ${_formatDate(_syncData["lastUpdated"])}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    SyncResult(success: true, data: _syncData),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSyncResultRow(String label, String value, bool hasData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasData ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        ),
        const SizedBox(height: 20),
        const Text(
          "Sync Failed",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Retry sync
                  SyncDialog.show(
                    context: context,
                    syncFuture: widget.syncFuture,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Retry"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return "Just now";
      } else if (difference.inHours < 1) {
        return "${difference.inMinutes} minutes ago";
      } else if (difference.inDays < 1) {
        return "${difference.inHours} hours ago";
      } else {
        return "${difference.inDays} days ago";
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}
