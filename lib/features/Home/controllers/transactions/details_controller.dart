import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:gateway_mobile/common/dialogs/custom_dialog.dart';
import 'package:gateway_mobile/common/widgets/loaders/loaders.dart';
import 'package:gateway_mobile/utils/constants/api_constants.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';
import 'package:gateway_mobile/utils/http/http_client.dart';

class TransactionController extends GetxController {
  final deviceStorage = GetStorage();

  RxBool isLoading = true.obs;
  RxString txnType = ''.obs;
  RxString status = ''.obs;
  RxString date = ''.obs;
  RxString phone = ''.obs;
  RxString paymentChannel = ''.obs;
  RxString currency = ''.obs;
  RxString amount = ''.obs;
  RxString fee = '0.00'.obs;
  RxString netAmount = '0.00'.obs;
  RxString operatorName = ''.obs;
  RxString description = ''.obs;
  RxString externalReference = ''.obs;
  RxString failureReason = ''.obs;
  RxString zescoToken = ''.obs;
  RxString units = ''.obs;
  RxString totalVat = ''.obs;
  RxString kwhAmount = ''.obs;
  RxString customerName = ''.obs;
  RxString voucherSerial = ''.obs;
  RxString customerAddress = ''.obs;
  RxString transactionUuid = ''.obs; // UUID for checking status
  // RxString failureReason = ''.obs; // Reason for failure

  final String transactionId;
  final bool isMerchant;

  TransactionController({required this.transactionId, this.isMerchant = false});

  @override
  void onInit() {
    super.onInit();

    fetchTransactionData();
  }

  Future<void> fetchTransactionData({bool quiet = false}) async {
    if (!quiet) isLoading.value = true;
    final token = deviceStorage.read("token");
    final baseUrl = isMerchant
        ? APIConstants.merchantTransactionDetails
        : APIConstants.transactiondetails;
    final endpoint = isMerchant
        ? "$baseUrl$transactionId"
        : "$baseUrl/$transactionId";

    try {
      final res = await APPHttpHelper.get(endpoint, token);
      final transaction = res["data"]?['transaction'] ?? {};

      txnType.value = transaction['transaction_type'] ?? "";
      currency.value = transaction['currency'] ?? "";
      paymentChannel.value = transaction['payment_channel'] ?? "";
      amount.value = transaction["amount"]?.toString() ?? "0";
      fee.value = transaction["fee"]?.toString() ?? "0.00";
      netAmount.value = transaction["net_amount"]?.toString() ?? "0.00";
      operatorName.value = transaction["processed_by"]?["name"] ?? "";
      description.value = transaction["description"]?.toString() ?? "";
      externalReference.value =
          transaction["external_reference"]?.toString() ?? "";
      failureReason.value = transaction["failed_reason"]?.toString() ?? "";
      date.value = transaction["created_at"] != null
          ? APPHelperFunctions.parseIsoDate(
              transaction["created_at"],
            ).toString()
          : "No Date Available";
      status.value = transaction["status"] ?? "";
      phone.value = transaction["customer"] ?? "";
      transactionUuid.value = transaction["transaction_id"] ?? "";

      final metadata = transaction["meta_data"];
      if (metadata != null) {
        // Extract UUID for status check
        // transactionUuid.value =
        //     metadata["response"]?["data"]?["transaction"]?["id"]?.toString() ??
        //         "";

        // Extract Failure Reason
        failureReason.value = metadata["failure_reason"]?.toString() ?? "";

        zescoToken.value = metadata["token"]?.toString() ?? "";
        units.value = metadata["units"]?.toString() ?? "";
        totalVat.value = metadata["total_vat"]?.toString() ?? "";
        kwhAmount.value = metadata["kwh_amount"]?.toString() ?? "";
        customerName.value = metadata["customer_name"] ?? "";
        customerAddress.value = metadata["customer_address"] ?? "";
        voucherSerial.value = metadata["voucher_serial"] ?? "";
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkTransactionStatus() async {
    try {
      // 1. Show Loading Dialog
      showCustomDialog(
        title: "Checking Status...",
        content: Column(
          children: [
            const SizedBox(height: APPSizes.spaceBtwItem),
            LoadingAnimationWidget.threeArchedCircle(
              color: APPColors.primary,
              size: 30,
            ),
            const SizedBox(height: APPSizes.spaceBtwItem),
            const Text(
              "Please wait, we are verifying the transaction status.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

      final token = deviceStorage.read("token");

      if (isMerchant) {
        final type = txnType.value.toLowerCase();
        final isCollect = type.contains('collect') || type.contains('request');
        final endpoint = isCollect
            ? "${APIConstants.merchantCollectStatus}$transactionId"
            : "${APIConstants.merchantDisburseStatus}$transactionId";

        final res = await APPHttpHelper.get(endpoint, token);

        if (Get.isDialogOpen ?? false) Navigator.of(Get.context!).pop();

        if (res['status'] == 'success' || res['data'] != null) {
          await fetchTransactionData(quiet: true);
          final data = res['data'] ?? res;
          final statusData = data['status']?.toString().toLowerCase() ?? "";
          final resMessage = data['message'] ?? "Status updated.";
          final isSuccess =
              statusData == 'success' ||
              statusData == 'successful' ||
              statusData == 'completed';
          final isPending =
              statusData == 'pending' || statusData == 'processing';

          showCustomDialog(
            showClose: true,
            title: "Status Update",
            icon: isSuccess
                ? Icons.check_circle
                : (isPending ? Icons.timer : Icons.error_outline),
            iconColor: isSuccess
                ? Colors.green
                : (isPending ? Colors.orange : Colors.red),
            content: Column(
              children: [
                Text(
                  "Status: ${statusData.toUpperCase()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: APPSizes.spaceBtwItem),
                Text(resMessage, textAlign: TextAlign.center),
              ],
            ),
          );
        } else {
          APPLoaders.errorSnackBar(
            title: "Check Failed",
            message: res['message'] ?? "Could not verify status.",
          );
        }
        return;
      }

      if (transactionUuid.value.isEmpty) {
        if (Get.isDialogOpen ?? false) Navigator.of(Get.context!).pop();
        APPLoaders.errorSnackBar(
          title: "Error",
          message:
              "Transaction UUID not found. Status check cannot be performed without a unique transaction ID.",
        );
        return;
      }

      final body = {
        "transaction_id": transactionUuid.value,
        "channel": _getChannelSlug(paymentChannel.value),
      };

      final res = await APPHttpHelper.post(
        APIConstants.transactionStatusendpoint,
        token,
        body,
      );

      if (Get.isDialogOpen ?? false) Navigator.of(Get.context!).pop();

      if (res["status"] == "success") {
        // Update values by re-fetching all data quietly (no shimmer)
        await fetchTransactionData(quiet: true);

        final statusData = res["data"]?["status"] ?? status.value;
        final resMessage =
            res["data"]?["message"] ?? "Transaction status updated.";
        final isSuccess = statusData == 'success' || statusData == 'successful';

        showCustomDialog(
          showClose: true,
          title: "Status Update",
          icon: isSuccess ? Icons.check_circle : Icons.info_outline,
          iconColor: isSuccess ? Colors.green : Colors.orange,
          content: Column(
            children: [
              Text(
                "Status: ${statusData.toString().toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: APPSizes.spaceBtwItem),
              Text(resMessage, textAlign: TextAlign.center),
              if (!isSuccess && failureReason.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Reason: ${failureReason.value}",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        );
      } else if (res["status"] == "failed") {
        showCustomDialog(
          showClose: true,
          title: "Status Update",
          icon: Icons.error_outline,
          iconColor: Colors.red,
          content: Column(
            children: [
              Text(
                "Status: ${status.value.toString().toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: APPSizes.spaceBtwItem),
              Text(res["message"] ?? "", textAlign: TextAlign.center),
            ],
          ),
        );
      } else if (res["status"] == "pending") {
        showCustomDialog(
          showClose: true,
          title: "Status Update",
          icon: Icons.info_outline,
          iconColor: Colors.orange,
          content: Column(
            children: [
              Text(
                "Status: ${status.value.toString().toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: APPSizes.spaceBtwItem),
              Text(res["message"] ?? "", textAlign: TextAlign.center),
            ],
          ),
        );
      } else if (res["status"] == "Timeout") {
        APPLoaders.errorSnackBar(
          title: "Check Timed Out",
          message:
              "The status check is taking too long. Please try again or check back later.",
        );
        return;
      } else {
        APPLoaders.errorSnackBar(
          title: "Check Failed",
          message: res["message"] ?? "Could not verify status.",
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Navigator.of(Get.context!).pop();
      APPLoaders.errorSnackBar(
        title: "Error",
        message: "Something went wrong: $e",
      );
    }
  }

  String _getChannelSlug(String channelName) {
    final normalized = channelName.toLowerCase().trim();
    if (normalized.contains('airtel')) {
      return 'airtel_money';
    } else if (normalized.contains('mtn')) {
      return 'mtn_money';
    } else if (normalized.contains('zamtel')) {
      return 'zamtel_money';
    }
    return normalized.replaceAll(' ', '_');
  }
}
