import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:gateway_mobile/common/widgets/loaders/loaders.dart';
import 'package:gateway_mobile/features/authentication/screens/login/login.dart';
import 'package:gateway_mobile/utils/constants/api_constants.dart';
import 'package:gateway_mobile/utils/helpers/network_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gateway_mobile/utils/http/http_client.dart';

class SetupController extends GetxController {
  static SetupController get instance => Get.find();

  GlobalKey<FormState> setupFormKey = GlobalKey<FormState>();
  final deviceStorage = GetStorage("setup");
  final email = TextEditingController();
  final serialNumber = TextEditingController();
  final phoneNumber1 = TextEditingController();
  final phoneNumber2 = TextEditingController();
  final deviceModel = TextEditingController();
  String terminalTypeId = "";
  final deviceName = TextEditingController();
  final deviceIdentificationNumber = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }

  Future<Map<String, String>> getLocationFromIP() async {
    final response = await http.get(Uri.parse('http://ip-api.com/json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      var longitude = data['lon']?.toString() ?? "";
      var latitude = data['lat']?.toString() ?? "";
      return {"latitude": latitude, "longitude": longitude};
    } else {
      throw Exception('Failed to get location from IP');
    }
  }

  Future setup() async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      APPLoaders.errorSnackBar(
        title: "No Connection",
        message: "Please check your internet connection.",
      );
      return;
    }

    if (!setupFormKey.currentState!.validate()) {
      APPLoaders.errorSnackBar(
        title: "Invalid Input",
        message: "Please enter a valid email address.",
      );
      return;
    }

    try {
      isLoading.value = true;
      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      final locationData = await getLocationFromIP();
      final android = await deviceInfoPlugin.androidInfo;

      final body = {
        "serial_number": android.id,
        "name": deviceName.text.trim(),
        "terminal_type_id": terminalTypeId,
        "current_app_version": packageInfo.version,
        "last_known_latitude": locationData["latitude"]!,
        "last_known_longitude": locationData["longitude"]!,
        "status": "online",
        "device_model": android.model,
        "operating_system": "Android ${android.version.release}",
        "description": "${android.manufacturer} ${android.model}",
        "locationLastUpdatedAt": DateTime.now().toIso8601String(),
        "email": email.text.trim(),
        "fingerprint": android.fingerprint,
        "primary_number": phoneNumber1.text.trim(),
        "secondary_number": phoneNumber2.text.trim(),
        "device_identification_number": deviceIdentificationNumber.text.trim(),
      };

      final res = await APPHttpHelper.postMaster(
        APIConstants.deviceregistrationendpoint,
        "",
        body,
      );

      if (res["status"] == "success") {
        final posDeviceID = res["device_id"];
        deviceStorage.write("firstSetup", false);
        deviceStorage.write("posdevice_id", posDeviceID);
        deviceStorage.write('last_latitude', locationData["latitude"] ?? "0.0");
        deviceStorage.write(
          'last_longitude',
          locationData["longitude"] ?? "0.0",
        );

        APPLoaders.successSnackBar(
          title: "Success",
          message: "Device registered successfully!",
        );

        Get.offAll(
          transition: Transition.leftToRight,
          duration: const Duration(milliseconds: 300),
          () => const LoginScreen(),
        );
      } else if (res["status"] == "error") {
        isLoading.value = false;
        APPLoaders.errorSnackBar(
          title: "Registration Failed",
          message: res["message"] ?? "Unknown error occurred.",
        );
      } else {
        isLoading.value = false;
        APPLoaders.errorSnackBar(
          title: "Registration Failed",
          message: res["error"] ?? "Unknown error occurred.",
        );
      }
    } catch (exception, stackTrace) {
      isLoading.value = false;
      debugPrint("Setup error: $exception\n$stackTrace");
      APPLoaders.errorSnackBar(
        title: "Oh snap!",
        message: exception.toString(),
      );
    }
  }
}
