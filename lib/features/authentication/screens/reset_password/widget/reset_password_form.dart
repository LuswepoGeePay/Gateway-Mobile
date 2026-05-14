import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gateway_mobile/features/authentication/controllers/resetPassword/reset_password_controller.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/constants/text_string.dart';
import 'package:gateway_mobile/utils/validators/validation.dart';

class ResetPasswordForm extends StatelessWidget {
  const ResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetPasswordController());
    return Form(
      key: controller.resetPasswordFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: APPSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            Obx(
              () => TextFormField(
                controller: controller.currentPassword,
                validator: (value) => APPValidator.validatePassword(value),
                obscureText: controller.hideCurrentPassword.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.password_check),
                  labelText: APPTexts.cPassword,
                  suffixIcon: IconButton(
                    onPressed: () => controller.hideCurrentPassword.value =
                        !controller.hideCurrentPassword.value,
                    icon: Icon(
                      controller.hideCurrentPassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: APPSizes.spaceBtwSections),
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) => APPValidator.validatePassword(value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.password_check),
                  labelText: APPTexts.password,
                  suffixIcon: IconButton(
                    onPressed: () => controller.hidePassword.value =
                        !controller.hidePassword.value,
                    icon: Icon(
                      controller.hidePassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: APPSizes.spaceBtwSections),
            Obx(
              () => TextFormField(
                controller: controller.confirmPassword,
                validator: (value) => APPValidator.validatePassword(value),
                obscureText: controller.hideConfirmPassword.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.password_check),
                  labelText: APPTexts.confirmPassword,
                  suffixIcon: IconButton(
                    onPressed: () => controller.hideConfirmPassword.value =
                        !controller.hideConfirmPassword.value,
                    icon: Icon(
                      controller.hideConfirmPassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: APPSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.resetPassword(),
                child: const Text(APPTexts.signIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
