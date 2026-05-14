import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gateway_mobile/utils/constants/api_constants.dart';
import 'package:gateway_mobile/utils/http/http_client.dart';

class CollectStatusController extends GetxController {
  final String reference;
  
  CollectStatusController({required this.reference});

  final status = "pending".obs;
  final message = "".obs;
  final checking = false.obs;
  final pollWindowEnded = false.obs;

  Timer? _pollTimer;
  Timer? _startDelayTimer;
  int _attempts = 0;
  final int maxAttempts = 9; // 90 seconds / 10 seconds
  final deviceStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    if (reference.isNotEmpty) {
      startPolling();
    } else {
      status.value = "unknown";
      message.value = "Missing transaction reference.";
    }
  }

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }

  void startPolling() {
    // Allow a microtask for the UI to set initialStatus before we decide to poll
    Future.microtask(() {
      if (status.value != "pending") return;

      _attempts = 0;
      pollWindowEnded.value = false;
      
      // Initial delay before first poll (10s)
      _startDelayTimer = Timer(const Duration(seconds: 10), () {
        performPoll();
        _pollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
          performPoll();
        });
      });
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _startDelayTimer?.cancel();
  }

  Future<void> performPoll() async {
    if (status.value != "pending" || _attempts >= maxAttempts) {
      stopPolling();
      if (_attempts >= maxAttempts && status.value == "pending") {
        pollWindowEnded.value = true;
        message.value = "Transaction is still being processed. Please check again shortly.";
      }
      return;
    }

    _attempts++;
    checking.value = true;

    try {
      final token = deviceStorage.read("token") ?? "";
      final res = await APPHttpHelper.get(
        "${APIConstants.merchantCollectStatus}$reference",
        token,
      );

      if (res['status'] == 'success' || res['data'] != null) {
        final data = res['data'] ?? res;
        final newStatus = data['status']?.toString().toLowerCase() ?? "pending";
        
        // Map status
        if (newStatus == "success" || newStatus == "successful" || newStatus == "completed") {
          status.value = "successful";
        } else if (newStatus == "failed" || newStatus == "error" || newStatus == "declined") {
          status.value = "failed";
        } else {
          status.value = "pending";
        }

        message.value = data['message'] ?? "";

        if (status.value != "pending") {
          stopPolling();
        }
      }
    } catch (e) {
      // Keep pending or set error message
      message.value = "Unable to fetch status right now.";
    } finally {
      checking.value = false;
    }
  }

  Future<void> manualCheck() async {
    if (checking.value) return;
    await performPoll();
  }
}
