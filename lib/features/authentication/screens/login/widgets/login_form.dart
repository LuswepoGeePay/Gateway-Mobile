import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:gateway_mobile/features/authentication/controllers/sign_in/sign_in_controller.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/constants/text_string.dart';
import 'package:gateway_mobile/utils/validators/validation.dart';

class APPLoginForm extends StatelessWidget {
  const APPLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SigninController>();
    return Form(
      key: controller.signinFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: APPSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            Obx(
              () => TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: controller.email,
                validator: (value) => APPValidator.validateEmail(value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.direct_right),
                  labelText: APPTexts.email,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: controller.emailError.value
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: controller.emailError.value
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: APPSizes.spaceBtwInputFields),
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) => APPValidator.validatePassword(value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password_outlined),
                  labelText: APPTexts.password,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: controller.passwordError.value
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: controller.passwordError.value
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
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
            Obx(() {
              if (controller.emailError.value ||
                  controller.passwordError.value) {
                return Text(
                  'Invalid email or password. Please try again.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.apply(color: Colors.red),
                );
              }
              return const SizedBox.shrink(); // Empty space when there's no error
            }),
            const SizedBox(height: APPSizes.spaceBtwSections),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: controller.isLoading.value
                        ? APPColors
                              .primary // Keep the same color when disabled
                        : APPColors.primary, // Active button color
                    disabledForegroundColor: APPColors.white,
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.signin();
                        },
                  child: controller.isLoading.value
                      ? LoadingAnimationWidget.threeArchedCircle(
                          color: APPColors.white,
                          size: 30,
                        )
                      : const Text(APPTexts.signIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
