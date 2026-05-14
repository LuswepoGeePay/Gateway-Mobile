import 'package:flutter/material.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';

class PaymentDetails extends StatelessWidget {
  final String phone;
  final String currency;
  final String amount;
  final String fee;
  final String netAmount;
  final String operator;
  final String externalReference;
  final String description;
  final String failureReason;
  final String paymentChannel;
  final String transactionId;
  final String txnType;
  final String date;

  const PaymentDetails({
    super.key,
    required this.phone,
    required this.currency,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.operator,
    this.externalReference = "",
    this.description = "",
    this.failureReason = "",
    required this.paymentChannel,
    required this.transactionId,
    required this.txnType,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dark = APPHelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TRANSACTION DETAILS",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(
            color: dark ? APPColors.darkContainer : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? APPColors.darkerGrey : APPColors.grey,
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow(context, "Customer", phone),
              _buildInfoRow(context, "Reference", transactionId, isMono: true),
              if (externalReference.isNotEmpty)
                _buildInfoRow(
                  context,
                  "External Ref",
                  externalReference,
                  isMono: true,
                ),
              _buildInfoRow(context, "Type", txnType),
              _buildInfoRow(context, "Channel", paymentChannel),
              if (description.isNotEmpty)
                _buildInfoRow(context, "Description", description),
              if (failureReason.isNotEmpty)
                _buildInfoRow(
                  context,
                  "Failure Reason",
                  failureReason,
                  isError: true,
                ),
              _buildInfoRow(
                context,
                "Processed By",
                operator.isNotEmpty ? operator : "API / System",
              ),
              _buildInfoRow(context, "Created", date, isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
    bool isMono = false,
    bool isError = false,
  }) {
    final dark = APPHelperFunctions.isDarkMode(context);
    final Color textColor = isError
        ? Colors.red
        : (dark ? Colors.white : Colors.black);
    final Color labelColor = isError
        ? Colors.red.withOpacity(0.7)
        : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: dark ? APPColors.darkerGrey : APPColors.grey,
                  width: 0.5,
                ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: textColor,
              fontFamily: isMono ? 'Courier' : null,
            ),
          ),
        ],
      ),
    );
  }
}
