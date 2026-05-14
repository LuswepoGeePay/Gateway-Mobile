import 'package:flutter/material.dart';
import 'package:gateway_mobile/common/images/app_rounded_image.dart';
import 'package:gateway_mobile/common/text/offline_text.dart';
import 'package:gateway_mobile/features/authentication/screens/setup/widgets/setup_form.dart';
import 'package:gateway_mobile/utils/constants/image_strings.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(APPSizes.defaultSpace),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const OfflineText(),
                const APPRoundedImage(
                  imageUrl: APPImages.lightAppLogo,
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: APPSizes.spaceBtwSections),
                Text(
                  "Device Setup",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: APPSizes.spaceBtwItem),
                const SetupForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
