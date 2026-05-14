import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gateway_mobile/common/images/app_rounded_image.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/image_strings.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/constants/text_string.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(APPSizes.defaultSpace),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const APPRoundedImage(
            backgroundColor: Colors.transparent,
            height: 70,
            width: 100,
            imageUrl: APPImages.lightAppLogo,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                APPTexts.loginSubTitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.apply(color: APPColors.primary),
              ),
              Text(
                APPTexts.loginSubtitle2,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.apply(color: APPColors.secondary),
              ),
            ],
          ),
          LottieBuilder.asset(
            "assets/images/animations/loading.json",
            width: 100,
            height: 100,
          ),
          // const SizedBox(
          //   height: APPSizes.spaceBtwItem,
          // ),
          // LoadingAnimationWidget.threeArchedCircle(
          //     color: APPColors.primary, size: 30)
        ],
      ),
    );
  }
}
