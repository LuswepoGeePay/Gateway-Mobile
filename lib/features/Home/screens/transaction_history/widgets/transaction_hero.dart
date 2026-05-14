import 'package:flutter/material.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';

class TransactionHeroCard extends StatelessWidget {
  final String status;
  final String amount;
  final String currency;
  final String fee;
  final String netAmount;

  const TransactionHeroCard({
    super.key,
    required this.status,
    required this.amount,
    required this.currency,
    required this.fee,
    required this.netAmount,
  });

  @override
  Widget build(BuildContext context) {
    final dark = APPHelperFunctions.isDarkMode(context);
    final statusColor = _getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? APPColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? APPColors.darkerGrey : APPColors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AMOUNT",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$currency $amount",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(status, statusColor),
            ],
          ),
          if (double.tryParse(fee) != null && double.parse(fee) > 0) ...[
            const SizedBox(height: 8),
            Text(
              "Fee: $currency $fee · Net: $currency $netAmount",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: dark ? APPColors.darkGrey : APPColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('success') || s.contains('complete')) return Colors.green;
    if (s.contains('pending') || s.contains('processing'))
      return APPColors.warning;
    return Colors.red;
  }
}
