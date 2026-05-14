import 'package:flutter/material.dart';
import 'package:gateway_mobile/nav_menu.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gateway_mobile/common/widgets/loaders/loaders.dart';
import 'package:gateway_mobile/features/authentication/models/authModel.dart';
import 'package:gateway_mobile/utils/constants/api_constants.dart';
import 'package:gateway_mobile/utils/helpers/network_manager.dart';
import 'package:gateway_mobile/utils/http/http_client.dart';

class SigninController extends GetxController {
  static SigninController get instance => Get.find();

  final hidePassword = true.obs;
  final email = TextEditingController();
  final isLoading = false.obs;
  final password = TextEditingController();
  final emailError = false.obs;
  final passwordError = false.obs;
  final isFormValid = false.obs;

  GlobalKey<FormState> signinFormKey = GlobalKey<FormState>();

  final deviceStorage = GetStorage();

  Future<void> signin() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) return;
      if (!signinFormKey.currentState!.validate()) return;

      isLoading.value = true;
      emailError.value = false;
      passwordError.value = false;

      LoginModule loginModule = LoginModule(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      var res = await APPHttpHelper.post(
        APIConstants.loginendpoint,
        "",
        loginModule,
      );

      if (res['status'] == "success") {
        final data = res['data'] ?? {};
        final user = data['user'] ?? {};
        final merchant = user['merchant'] ?? {};
        deviceStorage.write("token", data['token']);

        deviceStorage.write("id", user['id'] ?? '');
        deviceStorage.write("email", user['email'] ?? '');
        deviceStorage.write("name", user['name'] ?? '');
        deviceStorage.write("phone", user['phone'] ?? '');
        deviceStorage.write("status", user['status'] ?? '');

        deviceStorage.write("merchantId", merchant['id'] ?? '');
        deviceStorage.write("merchantName", merchant['business_name'] ?? '');
        deviceStorage.write(
          "merchantNumber",
          merchant['merchant_number'] ?? '',
        );
        deviceStorage.write("businessStatus", merchant['status'] ?? '');

        deviceStorage.write("kycStatus", merchant['kyc_status'] ?? '');

        // Show success message
        APPLoaders.successSnackBar(
          title: "Login Successful",
          message: res["message"] ?? "Welcome back!",
        );

        // Reset form and loading state
        email.clear();
        password.clear();
        isLoading.value = false;

        // Navigate to home screen
        Get.offAll(
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 500),
          () => const NavigationMenu(),
        );
        return;
      } else if (res['status'] == "Timeout") {
        isLoading.value = false;
        APPLoaders.errorSnackBar(
          title: "Connection Timeout",
          message:
              "The server is taking too long to respond. Please check your internet connection.",
        );
        return;
      } else if (res['error'] != null) {
        if (res["code"] == "401") {
          emailError.value = true;
          passwordError.value = true;
          isLoading.value = false;
          throw Exception(res["error"]);
        } else if (res["code"] == "403") {
          isLoading.value = false;
          throw Exception(res["message"]);
        } else {
          isLoading.value = false;
          throw Exception(res["error"]);
        }
      }
    } catch (exception) {
      isLoading.value = false;
      //  APPFullScreenLoader.stopLoader();
      APPLoaders.errorSnackBar(
        title: "Oh snap!",
        message: exception.toString().substring(11),
      );
    }
  }
}
