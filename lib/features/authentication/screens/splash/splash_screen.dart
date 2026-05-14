import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gateway_mobile/features/authentication/auth_wrapper.dart';
import 'package:gateway_mobile/features/authentication/screens/login/login.dart';
import 'package:gateway_mobile/features/authentication/screens/splash/widgets/splash_content.dart';
import 'package:gateway_mobile/nav_menu.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = APPHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: AnimatedSplashScreen(
        duration: 3500,
        splashIconSize: APPHelperFunctions.screenWidth() / 0.5,
        backgroundColor: dark ? APPColors.dark : APPColors.white,
        splash: const SplashContent(),
        nextScreen: AuthenticationWrapper(
          loginPage: const LoginScreen(), //: const LoginScreen(),
          homePage: const NavigationMenu(),
        ),
      ),
    );
  }
}
