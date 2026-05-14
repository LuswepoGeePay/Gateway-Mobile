import 'package:flutter/material.dart';
import 'package:gateway_mobile/common/appbar/appbar.dart';
import 'package:gateway_mobile/features/Home/controllers/collect_controller.dart';
import 'package:gateway_mobile/features/Home/controllers/collect_status_controller.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/formatters/formatter.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CollectStatusScreen extends StatelessWidget {
  final String reference;
  final String amount;
  final String phone;
  final String customerName;
  final String initialStatus;
  final String initialMessage;

  const CollectStatusScreen({
    super.key,
    required this.reference,
    required this.amount,
    required this.phone,
    required this.customerName,
    required this.initialStatus,
    required this.initialMessage,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CollectStatusController(reference: reference),
      tag: reference, // Use reference as tag to avoid collisions
    );

    // Set initial values from params if provided
    if (initialStatus.isNotEmpty) {
      final normalized = initialStatus.toLowerCase();
      if (normalized == "success" ||
          normalized == "successful" ||
          normalized == "completed") {
        controller.status.value = "successful";
      } else if (normalized == "failed" ||
          normalized == "error" ||
          normalized == "declined") {
        controller.status.value = "failed";
      }
    }
    if (initialMessage.isNotEmpty) {
      controller.message.value = initialMessage;
    }

    final dark = APPHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: APPAPPBar(
        title: const Text("Collection Status"),
        // subtitle: Text(reference.isNotEmpty ? reference : "Reference unavailable"),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(APPSizes.defaultSpace),
        child: Column(
          children: [
            // Status Hero Card
            Obx(() {
              final status = controller.status.value;
              final isSuccess = status == "successful";
              final isFailed = status == "failed";
              final isPending = status == "pending";

              final statusColor = isSuccess
                  ? APPColors.success
                  : isFailed
                  ? APPColors.error
                  : APPColors.warning;

              final statusIcon = isSuccess
                  ? Iconsax.tick_circle
                  : isFailed
                  ? Iconsax.close_circle
                  : Iconsax.timer_1;

              final statusLabel = isSuccess
                  ? "Payment Successful"
                  : isFailed
                  ? "Payment Failed"
                  : "Awaiting PIN Confirmation";

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(statusIcon, size: 64, color: statusColor),
                    const SizedBox(height: 12),
                    Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.message.value.isNotEmpty
                          ? controller.message.value
                          : (isPending
                                ? "The customer will receive a prompt on their phone to enter their PIN."
                                : ""),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark
                            ? APPColors.darkGrey
                            : APPColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isPending && !controller.pollWindowEnded.value)
                      Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: APPColors.warning,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: APPSizes.spaceBtwItem),

            // Customer Summary Card
            if (customerName.isNotEmpty || phone.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: dark ? APPColors.darkContainer : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: dark ? APPColors.darkerGrey : APPColors.grey,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: APPColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (customerName.isNotEmpty ? customerName : phone)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: APPColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (customerName.isNotEmpty)
                      Text(
                        customerName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    Text(
                      phone,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark
                            ? APPColors.darkGrey
                            : APPColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: APPSizes.spaceBtwItem),

            // Details Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: dark ? APPColors.darkContainer : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dark ? APPColors.darkerGrey : APPColors.grey,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    "Amount",
                    APPFormatter.formatCurrency(double.tryParse(amount) ?? 0.0),
                    accent: APPColors.primary,
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    context,
                    "Reference",
                    reference.isEmpty ? "-" : reference,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: APPSizes.spaceBtwSections),

            // Actions
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: controller.checking.value
                      ? null
                      : () => controller.manualCheck(),
                  child: controller.checking.value
                      ? LoadingAnimationWidget.fourRotatingDots(
                          color: APPColors.warning,
                          size: 20,
                        )
                      : const Text("Check Now"),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Obx(() {
              if (controller.status.value != "pending") {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final collectController =
                              Get.find<CollectController>();
                          collectController.clearForm();
                          Get.back();
                        },
                        child: const Text("New Collection"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Optional: View Transactions button could be added here if there's a route for it
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
    Color? accent,
  }) {
    final dark = APPHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: dark ? APPColors.darkGrey : APPColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      accent ?? (dark ? Colors.white : APPColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
