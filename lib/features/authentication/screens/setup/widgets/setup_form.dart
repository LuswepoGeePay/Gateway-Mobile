import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:gateway_mobile/features/authentication/controllers/setup/setup_controller.dart';
import 'package:gateway_mobile/utils/constants/api_constants.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/constants/text_string.dart';
import 'package:gateway_mobile/utils/http/http_client.dart';
import 'package:gateway_mobile/utils/validators/validation.dart';

class SetupForm extends StatefulWidget {
  const SetupForm({super.key});

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  final GetStorage storage = GetStorage();
  List<dynamic> terminalTypes = [];

  @override
  void initState() {
    super.initState();
    getTerminalTypes();
  }

  Future<void> getTerminalTypes() async {
    try {
      final response = await APPHttpHelper.getMaster(
        APIConstants.terminaltypesendpoint,
        "",
      );
      if (response['status'] == 'success') {
        setState(() {
          terminalTypes = response['data']?["terminal_types"] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching terminal types: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SetupController());
    return Form(
      key: controller.setupFormKey,
      child: Column(
        children: [
          DropdownButtonFormField(
            items: terminalTypes.map((terminalType) {
              return DropdownMenuItem(
                value: terminalType['id'],
                child: Text(terminalType['name']),
              );
            }).toList(),
            onChanged: (value) {
              controller.terminalTypeId = value.toString();
            },
            decoration: const InputDecoration(
              hintText: "Select Terminal Type",
              hintStyle: TextStyle(
                color: APPColors.darkGrey,
                fontSize: APPSizes.md,
              ),
              prefixIcon: Icon(Iconsax.building),
              labelText: "Terminal Type",
            ),
          ),
          const SizedBox(height: APPSizes.spaceBtwInputFields),
          TextFormField(
            controller: controller.deviceName,
            validator: (value) =>
                APPValidator.validateEmptyText("Device Name", value),
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: "Ex. Geepay POS 1",
              hintStyle: TextStyle(
                color: APPColors.darkGrey,
                fontSize: APPSizes.sm,
              ),
              prefixIcon: Icon(Iconsax.mobile),
              labelText: "Device name",
            ),
          ),
          const SizedBox(height: APPSizes.spaceBtwInputFields),
          TextFormField(
            controller: controller.serialNumber,
            validator: (value) =>
                APPValidator.validateEmptyText("Serial Number", value),
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: "Ex. 1234567890",
              hintStyle: TextStyle(
                color: APPColors.darkGrey,
                fontSize: APPSizes.sm,
              ),
              prefixIcon: Icon(Iconsax.simcard),
              labelText: "Serial Number",
            ),
          ),
          const SizedBox(height: APPSizes.spaceBtwInputFields),
          TextFormField(
            controller: controller.deviceIdentificationNumber,
            validator: (value) => APPValidator.validateEmptyText(
              "Device Identification Number",
              value,
            ),
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: "Ex. S6901234567890",
              hintStyle: TextStyle(
                color: APPColors.darkGrey,
                fontSize: APPSizes.sm,
              ),
              prefixIcon: Icon(Iconsax.archive4),
              labelText: "Device Identification Number",
            ),
          ),
          const SizedBox(height: APPSizes.spaceBtwInputFields),
          TextFormField(
            controller: controller.email,
            validator: (value) => APPValidator.validateEmail(value),
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: "Ex. hello@mygeepay.com",
              hintStyle: TextStyle(
                color: APPColors.darkGrey,
                fontSize: APPSizes.sm,
              ),
              prefixIcon: Icon(Iconsax.direct_right),
              labelText: "Business Email",
            ),
          ),
          const SizedBox(height: APPSizes.spaceBtwInputFields),
          TextFormField(
            controller: controller.phoneNumber1,
            validator: (value) =>
                APPValidator.validateEmptyText("Primary Number", value),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Ex. 09512345678",
              hintStyle: TextStyle(
                color: APPColors.darkGrey,
                fontSize: APPSizes.sm,
              ),
              prefixIcon: Icon(Icons.numbers),
              labelText: "Primary Number",
            ),
          ),
          const SizedBox(height: APPSizes.spaceBtwInputFields),
          TextFormField(
            controller: controller.phoneNumber2,
            validator: (value) =>
                APPValidator.validateEmptyText("Secondary Number", value),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Ex. 09612345678",
              hintStyle: TextStyle(
                color: APPColors.darkGrey,
                fontSize: APPSizes.sm,
              ),
              prefixIcon: Icon(Icons.numbers),
              labelText: "Secondary Number",
            ),
          ),
          const SizedBox(height: APPSizes.spaceBtwInputFields),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.setup(),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: controller.isLoading.value
                      ? APPColors
                            .primary // Keep the same color when disabled
                      : APPColors.primary, // Active button color
                  disabledForegroundColor: APPColors.white,
                ),
                child: controller.isLoading.value
                    ? LoadingAnimationWidget.threeArchedCircle(
                        color: APPColors.white,
                        size: 30,
                      )
                    : const Text(APPTexts.submit),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
