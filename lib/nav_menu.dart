import 'package:flutter/material.dart';
import 'package:gateway_mobile/features/Home/screens/collect/collect.dart';
import 'package:gateway_mobile/features/Home/screens/disburse/disburse.dart';
import 'package:gateway_mobile/features/Home/screens/history/history.dart';
import 'package:gateway_mobile/features/Home/screens/home/home.dart';
import 'package:gateway_mobile/features/Home/screens/settings/settings.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = APPHelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          backgroundColor: darkMode ? APPColors.black : Colors.white,
          indicatorColor: darkMode
              ? APPColors.white.withValues(alpha: 0.1)
              : APPColors.black.withValues(alpha: 0.1),
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: controller.destinations,
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  void resetIndex() => selectedIndex.value = 0;
  final deviceStorage = GetStorage();

  late List<Widget> screens;
  late List<NavigationDestination> destinations;

  @override
  void onInit() {
    super.onInit();

    // final userType = deviceStorage.read("userType");

    // Initialize screens list
    screens = [
      const HomeScreen(),
      const CollectScreen(),
      const DisburseScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    // // Initialize destinations list
    destinations = [
      const NavigationDestination(
        icon: Icon(LucideIcons.layoutDashboard),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Iconsax.arrow_circle_down),
        label: 'Collect',
      ),
      const NavigationDestination(
        icon: Icon(Iconsax.arrow_circle_up),
        label: 'Disburse',
      ),
      const NavigationDestination(
        icon: Icon(LucideIcons.list),
        label: 'History',
      ),
      const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }
}
