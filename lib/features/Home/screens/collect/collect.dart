import 'package:flutter/material.dart';
import 'package:gateway_mobile/common/appbar/appbar.dart';
import 'package:gateway_mobile/features/Home/controllers/collect_controller.dart';
import 'package:gateway_mobile/features/Home/screens/collect/collection_status.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CollectScreen extends StatelessWidget {
  const CollectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CollectController());
    final dark = APPHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const APPAPPBar(
        title: Text("Request Payment"),
        showBackArrow: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(APPSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            _buildHeroCard(context, dark),

            const SizedBox(height: APPSizes.spaceBtwSections),

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
                      : () async {
                          final res = await controller.submitCollection();
                          if (res != null) {
                            final data = res['data'] ?? res;
                            Get.to(
                              () => CollectStatusScreen(
                                reference:
                                    data['transaction_reference'] ??
                                    data['transaction_ref'] ??
                                    data['reference'] ??
                                    "",
                                amount: controller.amountController.text,
                                phone: "260${controller.phoneController.text}",
                                customerName:
                                    controller.customerName.value ?? "",
                                initialStatus: data['status'] ?? "pending",
                                initialMessage: data['message'] ?? "",
                              ),
                            );
                          }
                        },
                  child: controller.submitting.value
                      ? LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 30,
                        )
                      : const Text("Request Payment"),
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
          // Background "Orb" effect
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: APPColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: APPColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Iconsax.arrow_circle_down,
                  color: APPColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fast Collection",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Recipient details and amount are validated before sending.",
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

  Widget _buildRecipientCard(
    BuildContext context,
    CollectController controller,
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
    CollectController controller,
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
            "AMOUNT",
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
                labelText: "Collection amount",
                prefixText: "ZMW ",
                prefixStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                hintText: "0.00",
                errorText: controller.amountError.value,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.info, size: 14, color: APPColors.darkGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Customer will confirm on their mobile wallet PIN prompt.",
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
}
