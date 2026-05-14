import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gateway_mobile/common/widgets/loaders/loaders.dart';
import 'package:gateway_mobile/utils/constants/api_constants.dart';
import 'package:gateway_mobile/utils/http/http_client.dart';

class DisburseController extends GetxController {
  static DisburseController get instance => Get.find();

  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final narrationController = TextEditingController();
  
  final lookingUp = false.obs;
  final submitting = false.obs;
  final loadingBalance = false.obs;
  
  final customerName = Rx<String?>(null);
  final balance = Rx<double?>(null);
  final balanceError = Rx<String?>(null);
  
  final phoneError = Rx<String?>(null);
  final amountError = Rx<String?>(null);

  Timer? _debounce;
  final deviceStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadBalance();
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    narrationController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void clearForm() {
    phoneController.clear();
    amountController.clear();
    narrationController.clear();
    customerName.value = null;
    phoneError.value = null;
    amountError.value = null;
  }

  Future<void> loadBalance() async {
    loadingBalance.value = true;
    balanceError.value = null;
    try {
      final token = deviceStorage.read("token") ?? "";
      final res = await APPHttpHelper.get(
        APIConstants.merchantBalanceDisbursement,
        token,
      );

      if (res['status'] == 'success' || res['data'] != null) {
        final data = res['data'] ?? res;
        balance.value = (data['balance'] as num?)?.toDouble() ?? 0.0;
      } else {
        balanceError.value = res['message'] ?? "Unable to load balance.";
      }
    } catch (e) {
      balanceError.value = "Unable to load balance.";
    } finally {
      loadingBalance.value = false;
    }
  }

  void onPhoneChanged(String value) {
    customerName.value = null;
    phoneError.value = null;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (!RegExp(r'^\d{9}$').hasMatch(value)) return;

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      await performNameLookup(value);
    });
  }

  Future<void> performNameLookup(String phoneDigits) async {
    lookingUp.value = true;
    try {
      final token = deviceStorage.read("token") ?? "";
      final res = await APPHttpHelper.get(
        "${APIConstants.merchantNameLookup}260$phoneDigits",
        token,
      );

      if (res['status'] == 'success' || res['data'] != null) {
        final data = res['data'] ?? res;
        customerName.value = data['name'] ?? data['names'] ?? data['account_name'];
      } else {
        customerName.value = null;
      }
    } catch (e) {
      customerName.value = null;
    } finally {
      lookingUp.value = false;
    }
  }

  bool validate() {
    phoneError.value = null;
    amountError.value = null;

    bool isValid = true;

    if (!RegExp(r'^\d{9}$').hasMatch(phoneController.text)) {
      phoneError.value = "Enter a valid 9-digit Zambian number";
      isValid = false;
    }

    final amt = double.tryParse(amountController.text);
    if (amountController.text.isEmpty || amt == null || amt <= 0) {
      amountError.value = "Enter a valid amount greater than 0";
      isValid = false;
    } else if (balance.value != null && amt > balance.value!) {
      amountError.value = "Exceeds available balance";
      isValid = false;
    }

    return isValid;
  }

  Future<Map<String, dynamic>?> submitDisbursement() async {
    if (!validate()) return null;

    submitting.value = true;
    try {
      final token = deviceStorage.read("token") ?? "";
      final data = {
        "phone_number": "260${phoneController.text}",
        "amount": double.parse(amountController.text),
        "narration": narrationController.text.trim().isEmpty ? "payout" : narrationController.text.trim(),
      };

      final res = await APPHttpHelper.post(
        APIConstants.merchantDisburse,
        token,
        data,
      );

      final resData = res['data'] ?? res;
      final hasRef = resData['transaction_ref'] != null || 
                     resData['transaction_reference'] != null || 
                     resData['reference'] != null;
      
      final status = (res['status'] ?? resData['status'] ?? "").toString().toLowerCase();
      final isGoodStatus = status == 'success' || status == 'successful' || 
                           status == 'pending' || status == 'processing' || status == 'created' || status == 'queued';

      if (hasRef || isGoodStatus) {
        return res;
      } else {
        String errorMsg = "Could not process disbursement.";
        if (res['message'] != null) {
          errorMsg = res['message'];
        } else if (resData['message'] != null) {
          errorMsg = resData['message'];
        } else if (res['error'] != null) {
          errorMsg = res['error'];
        } else if (res['errors'] != null && res['errors'] is Map) {
          final errors = res['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMsg = firstError.first.toString();
            } else {
              errorMsg = firstError.toString();
            }
          }
        }

        APPLoaders.errorSnackBar(
          title: "Disbursement Failed",
          message: errorMsg,
        );
        return null;
      }
    } catch (e) {
      APPLoaders.errorSnackBar(
        title: "Disbursement Failed",
        message: e.toString(),
      );
      return null;
    } finally {
      submitting.value = false;
    }
  }
}
