import 'package:flutter/material.dart';
import 'package:gateway_mobile/common/appbar/appbar.dart';
import 'package:gateway_mobile/features/Home/controllers/disburse_controller.dart';
import 'package:gateway_mobile/features/Home/screens/disburse/disburse_status.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/formatters/formatter.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DisburseScreen extends StatelessWidget {
  const DisburseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DisburseController());
    final dark = APPHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const APPAPPBar(title: Text("Send Money"), showBackArrow: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(APPSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            _buildHeroCard(context, dark),

            const SizedBox(height: APPSizes.spaceBtwSections),

            // Balance Card
            _buildBalanceCard(context, controller, dark),

            const SizedBox(height: APPSizes.spaceBtwItem),

            // Recipient Card
            _buildRecipientCard(context, controller, dark),

            const SizedBox(height: APPSizes.spaceBtwItem),

            // Amount Card
            _buildAmountCard(context, controller, dark),

            const SizedBox(height: APPSizes.spaceBtwSections),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: APPColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.submitting.value
                      ? null
                      : () => _showConfirmationDialog(context, controller),
                  child: controller.submitting.value
                      ? LoadingAnimationWidget.fourRotatingDots(
                          color: APPColors.warning,
                          size: 30,
                        )
                      : const Text("Send Money"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? APPColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? APPColors.darkerGrey : APPColors.grey),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: APPColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: APPColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Iconsax.send_1,
                  color: APPColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Controlled Payouts",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Balance checks and confirmation protect every transfer.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark
                            ? APPColors.darkGrey
                            : APPColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    DisburseController controller,
    bool dark,
  ) {
    return Obx(() {
      final amt = double.tryParse(controller.amountController.text) ?? 0.0;
      final exceeds =
          controller.balance.value != null && amt > controller.balance.value!;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? APPColors.darkContainer : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dark ? APPColors.darkerGrey : APPColors.grey,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AVAILABLE BALANCE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: dark ? APPColors.darkGrey : APPColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                if (controller.loadingBalance.value)
                  LoadingAnimationWidget.fourRotatingDots(
                    color: APPColors.primary,
                    size: 20,
                  )
                else
                  Text(
                    controller.balance.value != null
                        ? APPFormatter.formatCurrency(controller.balance.value!)
                        : "—",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: exceeds
                          ? APPColors.error
                          : (dark ? Colors.white : APPColors.textPrimary),
                    ),
                  ),
              ],
            ),
            if (controller.balanceError.value != null)
              TextButton(
                onPressed: () => controller.loadBalance(),
                child: const Text("Retry"),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildRecipientCard(
    BuildContext context,
    DisburseController controller,
    bool dark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? APPColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? APPColors.darkerGrey : APPColors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "RECIPIENT",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: dark ? APPColors.darkGrey : APPColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextFormField(
              controller: controller.phoneController,
              onChanged: controller.onPhoneChanged,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Text(
                    "+260",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                hintText: "9-digit number",
                errorText: controller.phoneError.value,
              ),
            ),
          ),
          Obx(() {
            if (controller.lookingUp.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    LoadingAnimationWidget.fourRotatingDots(
                      color: dark ? APPColors.darkGrey : APPColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Looking up name…",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            } else if (controller.customerName.value != null) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: APPColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: APPColors.success.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.user_tick,
                      color: APPColors.success,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "VERIFIED NAME",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: APPColors.success,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            controller.customerName.value!,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: APPColors.success,
                      size: 20,
                    ),
                  ],
                ),
              );
            } else if (controller.phoneController.text.length == 9) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Name not found",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: APPColors.error),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildAmountCard(
    BuildContext context,
    DisburseController controller,
    bool dark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? APPColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? APPColors.darkerGrey : APPColors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PAYMENT DETAILS",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: dark ? APPColors.darkGrey : APPColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextFormField(
              controller: controller.amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: "Amount",
                prefixText: "ZMW ",
                prefixStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                hintText: "0.00",
                errorText: controller.amountError.value,
              ),
              onChanged: (_) {
                // Trigger UI update for balance check
                controller.amountError.value = null;
              },
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.narrationController,
            decoration: const InputDecoration(
              labelText: "Narration (optional)",
              hintText: "e.g. Payout, Salary...",
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.shieldCheck,
                size: 14,
                color: APPColors.darkGrey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "You will confirm the beneficiary and amount before dispatch.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? APPColors.darkGrey : APPColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    DisburseController controller,
  ) {
    if (!controller.validate()) return;

    final dark = APPHelperFunctions.isDarkMode(context);
    final amount = double.tryParse(controller.amountController.text) ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: dark ? APPColors.dark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Confirm Disbursement",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "This action cannot be undone once confirmed.",
                      style: TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildConfirmRow(
              context,
              "Recipient",
              controller.customerName.value ?? "N/A",
            ),
            _buildConfirmRow(
              context,
              "Phone",
              "+260${controller.phoneController.text}",
            ),
            _buildConfirmRow(
              context,
              "Amount",
              APPFormatter.formatCurrency(amount),
              bold: true,
            ),
            if (controller.narrationController.text.isNotEmpty)
              _buildConfirmRow(
                context,
                "Narration",
                controller.narrationController.text,
              ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final res = await controller.submitDisbursement();
                      if (res != null) {
                        final data = res['data'] ?? res;
                        Get.to(
                          () => DisburseStatusScreen(
                            reference:
                                data['transaction_reference'] ??
                                data['transaction_ref'] ??
                                data['reference'] ??
                                "",
                            amount: controller.amountController.text,
                            phone: "260${controller.phoneController.text}",
                            customerName: controller.customerName.value ?? "",
                            initialStatus: data['status'] ?? "pending",
                            initialMessage: data['message'] ?? "",
                          ),
                        );
                      }
                    },
                    child: const Text("Confirm & Send"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmRow(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
  }) {
    final dark = APPHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? APPColors.darkGrey : APPColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: dark ? Colors.white : APPColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
