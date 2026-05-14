import 'package:flutter/material.dart';
import 'package:gateway_mobile/features/authentication/screens/login/widgets/login_form.dart';
import 'package:gateway_mobile/features/authentication/screens/login/widgets/login_header.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/image_strings.dart';
// Assuming you have a colors file
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = APPHelperFunctions.isDarkMode(context);
    return Scaffold(
      // Use a background color that contrasts with the form card
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              // Header
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                color: Theme.of(context).primaryColor,
                child: const Center(child: APPLoginHeader()),
              ),

              // Form section fills remaining space
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(APPSizes.defaultSpace),
                  decoration: BoxDecoration(
                    color: dark ? APPColors.dark : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: APPSizes.spaceBtwSections),

                      const APPLoginForm(),

                      const Image(
                        height: 40,
                        image: AssetImage(APPImages.poweredBy),
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
