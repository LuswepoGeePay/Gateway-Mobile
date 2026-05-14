import 'package:flutter/material.dart';
// import 'package:gateway_mobile/common/images/app_rounded_image.dart';
import 'package:gateway_mobile/utils/constants/image_strings.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';

class APPLoginHeader extends StatelessWidget {
  const APPLoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = APPHelperFunctions.isDarkMode(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Container for the logo to give it "breathing room"
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: dark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Image(
            height: 100,
            image: AssetImage(
              dark ? APPImages.lightAppLogo : APPImages.darkAppLogo,
            ), // Use themed logo
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Welcome Back",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Log in to your account to continue",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
