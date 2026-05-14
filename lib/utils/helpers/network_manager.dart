import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gateway_mobile/common/widgets/loaders/loaders.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  ConnectivityResult get connectionStatus =>
      _connectionStatus.value; // Add this getter

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      // Use the first result if available, otherwise default to none
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      await _updateConnectionStatus(result);
    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus.value = result;
    if (_connectionStatus.value == ConnectivityResult.none) {
      APPLoaders.warningSnackBar(
        title: 'No internet connection',
        message: "Please check your internet connection!",
      );
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    _subscription.cancel();
  }
}
