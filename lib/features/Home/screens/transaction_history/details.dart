import 'package:flutter/material.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:gateway_mobile/common/appbar/appbar.dart';
import 'package:gateway_mobile/common/text/offline_text.dart';
import 'package:gateway_mobile/features/Home/controllers/transactions/details_controller.dart';
import 'package:gateway_mobile/features/Home/screens/transaction_history/widgets/basic_payment_details.dart';
import 'package:gateway_mobile/features/Home/screens/transaction_history/widgets/loading_card.dart';
import 'package:gateway_mobile/features/Home/screens/transaction_history/widgets/transaction_hero.dart';

class TransactionDetails extends StatelessWidget {
  final String transactionId;
  final bool isMerchant;

  const TransactionDetails({
    super.key,
    required this.transactionId,
    this.isMerchant = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TransactionController(
        transactionId: transactionId,
        isMerchant: isMerchant,
      ),
      tag: transactionId,
    );
    final dark = APPHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: APPAPPBar(
        showBackArrow: true,
        title: Text(
          "Transaction",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingDetailsCard());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTransactionData(quiet: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(APPSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OfflineText(),

                // Refresh Status Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => controller.checkTransactionStatus(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Check Status"),
                    style: TextButton.styleFrom(
                      foregroundColor: APPColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Hero Card (Amount & Status)
                TransactionHeroCard(
                  status: controller.status.value,
                  amount: controller.amount.value,
                  currency: controller.currency.value,
                  fee: controller.fee.value,
                  netAmount: controller.netAmount.value,
                ),

                const SizedBox(height: 24),

                // Detail Card (The rest)
                PaymentDetails(
                  phone: controller.phone.value,
                  currency: controller.currency.value,
                  amount: controller.amount.value,
                  fee: controller.fee.value,
                  netAmount: controller.netAmount.value,
                  operator: controller.operatorName.value,
                  externalReference: controller.externalReference.value,
                  description: controller.description.value,
                  failureReason: controller.failureReason.value,
                  paymentChannel: controller.paymentChannel.value,
                  transactionId: transactionId,
                  txnType: controller.txnType.value,
                  date: controller.date.value,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
}
