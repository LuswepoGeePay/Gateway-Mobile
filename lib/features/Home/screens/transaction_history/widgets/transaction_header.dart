import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/constants/text_string.dart';

class TransactionHeader extends StatelessWidget {
  final String status;
  final String? failureReason;

  const TransactionHeader({
    super.key,
    required this.status,
    this.failureReason,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                status == APPTexts.successStatus
                    ? APPTexts.successfulPayment
                    : status == APPTexts.pendingStatus
                    ? APPTexts.pendingPayment
                    : APPTexts.failedPayment,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: APPSizes.spaceBtwItem),
            Icon(
              status == APPTexts.successStatus
                  ? LucideIcons.badgeCheck
                  : status == APPTexts.pendingStatus
                  ? LucideIcons.badgeInfo
                  : LucideIcons.badgeX,
              color: status == APPTexts.successStatus
                  ? Colors.green
                  : status == APPTexts.pendingStatus
                  ? APPColors.warning
                  : Colors.red,
            ),
          ],
        ),
        if (status.toLowerCase().contains("failed") &&
            failureReason != null &&
            failureReason!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: APPSizes.spaceBtwItem / 2),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    failureReason!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall!.apply(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
