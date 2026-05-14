import 'package:flutter/material.dart';
import 'package:gateway_mobile/common/appbar/appbar.dart';
import 'package:gateway_mobile/features/Home/controllers/history_controller.dart';
import 'package:gateway_mobile/features/Home/screens/transaction_history/details.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/formatters/formatter.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    final dark = APPHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const APPAPPBar(title: Text("History"), showBackArrow: false),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextFormField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: "Search by reference or customer…",
                    prefixIcon: Icon(Iconsax.search_normal),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("all", controller),
                      const SizedBox(width: 8),
                      _buildFilterChip("pending", controller),
                      const SizedBox(width: 8),
                      _buildFilterChip("successful", controller),
                      const SizedBox(width: 8),
                      _buildFilterChip("failed", controller),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.transactions.isEmpty) {
                return Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: APPColors.primary,
                    size: 40,
                  ),
                );
              }

              if (controller.error.value != null &&
                  controller.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.danger,
                        size: 48,
                        color: APPColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(controller.error.value!),
                      TextButton(
                        onPressed: () =>
                            controller.loadTransactions(refresh: true),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              if (controller.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.receipt_item,
                        size: 48,
                        color: dark ? APPColors.darkGrey : APPColors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No transactions found.",
                        style: TextStyle(
                          color: dark
                              ? APPColors.darkGrey
                              : APPColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadTransactions(refresh: true),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      controller.transactions.length +
                      (controller.hasNextPage.value ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == controller.transactions.length) {
                      controller.loadMore();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: LoadingAnimationWidget.fourRotatingDots(
                            color: APPColors.primary,
                            size: 20,
                          ),
                        ),
                      );
                    }

                    final tx = controller.transactions[index];
                    return _buildTransactionItem(context, tx, dark);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, HistoryController controller) {
    return Obx(() {
      final isSelected = controller.statusFilter.value == status;
      return GestureDetector(
        onTap: () => controller.setStatusFilter(status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? APPColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? APPColors.primary : APPColors.grey,
            ),
          ),
          child: Text(
            status.capitalizeFirst!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : APPColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Map<String, dynamic> tx,
    bool dark,
  ) {
    final customerName = tx['customer']?.toString() ?? "Unknown";
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final status = tx['status']?.toString().toLowerCase() ?? "pending";
    final dateStr = tx['created_at']?.toString() ?? "";
    final type = tx['type']?.toString() ?? "Transaction";
    final reference = tx['reference']?.toString() ?? "";

    String formattedDate = "N/A";
    if (dateStr.isNotEmpty) {
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('MMM d, h:mm a').format(date);
      } catch (_) {}
    }

    final statusColor = _getStatusColor(status);

    return InkWell(
      onTap: () => Get.to(
        () => TransactionDetails(transactionId: reference, isMerchant: true),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$type · $formattedDate",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: dark
                          ? APPColors.darkGrey
                          : APPColors.textSecondary,
                    ),
                  ),
                  Text(
                    reference,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: dark
                          ? APPColors.darkGrey
                          : APPColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  APPFormatter.formatCurrency(amount),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
      case 'successful':
      case 'completed':
        return APPColors.success;
      case 'failed':
      case 'error':
      case 'declined':
        return APPColors.error;
      case 'pending':
      case 'processing':
        return APPColors.warning;
      default:
        return APPColors.darkGrey;
    }
  }
}
