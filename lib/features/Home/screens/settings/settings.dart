import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gateway_mobile/common/appbar/appbar.dart';
import 'package:gateway_mobile/features/authentication/screens/login/login.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final dark = APPHelperFunctions.isDarkMode(context);

    // Fetch user/merchant data
    final name = storage.read("name") ?? "User";
    final email = storage.read("email") ?? "";
    final phone = storage.read("phone") ?? "";
    final merchantName = storage.read("merchantName") ?? "Business Name";
    final merchantNumber = storage.read("merchantNumber") ?? "";
    final kycStatus = storage.read("kycStatus") ?? "Pending";
    final businessStatus = storage.read("businessStatus") ?? "Active";

    return Scaffold(
      appBar: const APPAPPBar(title: Text("Profile"), showBackArrow: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(APPSizes.defaultSpace),
          child: Column(
            children: [
              // --- Header Section ---
              _buildProfileHeader(context, name, email, dark),

              const SizedBox(height: APPSizes.spaceBtwSections),

              // --- Business Details Section ---
              _buildSectionTitle(context, "Business Details"),
              const SizedBox(height: APPSizes.spaceBtwItem),
              _buildDetailCard(dark, [
                _buildInfoRow(
                  context,
                  Iconsax.shop,
                  "Business Name",
                  merchantName,
                ),
                _buildInfoRow(
                  context,
                  Iconsax.personalcard,
                  "Merchant Number",
                  merchantNumber,
                ),
                _buildInfoRow(
                  context,
                  Iconsax.verify,
                  "KYC Status",
                  kycStatus,
                  valueColor: _getStatusColor(kycStatus),
                ),
                _buildInfoRow(
                  context,
                  Iconsax.status,
                  "Business Status",
                  businessStatus,
                  valueColor: _getStatusColor(businessStatus),
                  isLast: true,
                ),
              ]),

              const SizedBox(height: APPSizes.spaceBtwSections),

              // --- Contact Info Section ---
              _buildSectionTitle(context, "Contact Information"),
              const SizedBox(height: APPSizes.spaceBtwItem),
              _buildDetailCard(dark, [
                _buildInfoRow(context, Iconsax.call, "Phone", phone),
                _buildInfoRow(
                  context,
                  Iconsax.direct,
                  "Email",
                  email,
                  isLast: true,
                ),
              ]),

              const SizedBox(height: APPSizes.spaceBtwSections * 1.5),

              // --- Logout Button ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _handleLogout(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.logout, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Logout Account",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: APPSizes.spaceBtwItem),
              Text(
                "App Version 1.0.0",
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String email,
    bool dark,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: APPColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: APPColors.primary, width: 2),
          ),
          child: const Center(
            child: Icon(Iconsax.user, size: 40, color: APPColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDetailCard(bool dark, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark ? APPColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? APPColors.darkerGrey : APPColors.grey),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: APPColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('active') || s.contains('verified') || s.contains('success'))
      return Colors.green;
    if (s.contains('pending')) return Colors.orange;
    return Colors.red;
  }

  void _handleLogout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout of your account?",
      textConfirm: "Logout",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        final storage = GetStorage();
        storage.remove("token");
        Get.offAll(() => const LoginScreen());
      },
    );
  }
}
