import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/helpers/network_manager.dart';

class OfflineText extends StatelessWidget {
  const OfflineText({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connectivityStatus = NetworkManager.instance.connectionStatus;
      if (connectivityStatus == ConnectivityResult.none) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: APPSizes.spaceBtwItem),
          padding: const EdgeInsets.symmetric(
            vertical: APPSizes.sm,
            horizontal: APPSizes.md,
          ),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(APPSizes.cardRadiusSm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 20),
              const SizedBox(width: APPSizes.spaceBtwItem / 2),
              Expanded(
                child: Text(
                  'No Internet Connection. Some features may be unavailable.',
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                    color: Colors.white,
                    fontWeightDelta: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox(); // Placeholder when online
      }
    });
  }
}
