// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:gateway_mobile/features/Home/screens/home/widgets/sticky_header.dart';
import 'package:gateway_mobile/features/Home/screens/transaction_history/details.dart';
import 'package:gateway_mobile/nav_menu.dart';
import 'package:gateway_mobile/utils/constants/api_constants.dart';
import 'package:gateway_mobile/utils/constants/colors.dart';
import 'package:gateway_mobile/utils/constants/sizes.dart';
import 'package:gateway_mobile/utils/helpers/helper_functions.dart';
import 'package:gateway_mobile/utils/http/http_client.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true; // Track loading state
  bool isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic> dashboardData = {};
  Map<String, dynamic> merchant = {};
  Map<String, dynamic> balances = {};
  Map<String, dynamic> stats = {};
  Map<String, dynamic> disbursementThisMonth = {};
  List<dynamic> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    getDashboardData();
  }

  // Refresh function that simulates reloading
  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        isRefreshing = false;
      });
    }
  }

  Future<void> getDashboardData() async {
    final deviceStorage = GetStorage();

    final token = deviceStorage.read("token");

    final res = await APPHttpHelper.get(APIConstants.dashboardendpoint, token);
    // debugPrint("✅ Server Response: $res");

    if (res['status'] == 'success') {
      final data = res['data'] ?? {};
      final merchantData = data['merchant'] ?? {};
      final balancesData = data['balances'] ?? {};
      final statsData = data['stats'] ?? {};
      final disbursementData = data['disbursement_this_month'] ?? {};
      final transactionsData = data['recent_transactions'] ?? [];

      if (mounted) {
        setState(() {
          merchant = merchantData;
          balances = balancesData;
          stats = statsData;
          disbursementThisMonth = disbursementData;
          recentTransactions = transactionsData;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
      debugPrint("⚠️ Error: ${res['message']}");
      debugPrint("⚠️ Server Error: ${res?['error'] ?? 'Unknown error'}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = APPHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? APPColors.black : APPColors.grey,
      body: _isLoading
          ? _buildLoadingShimmer()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // 1. Sticky Header
                  const SliverToBoxAdapter(child: StickyHeader()),

                  // 2. Main Dashboard Content
                  SliverPadding(
                    padding: EdgeInsets.all(APPSizes.defaultSpace),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                getDashboardData();
                              },
                              label: const Text("Refresh"),
                              icon: const Icon(LucideIcons.refreshCw),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: dark
                                    ? APPColors.white
                                    : APPColors.black,
                                backgroundColor: dark
                                    ? APPColors.darkContainer
                                    : APPColors.lightContainer,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: APPSizes.spaceBtwItem),
                        // --- WALLET BALANCE CARD ---
                        _buildBalanceCard(dark),

                        const SizedBox(height: APPSizes.spaceBtwSections),

                        // --- BUSINESS STATS GRID ---
                        Text(
                          "Business Performance",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: APPSizes.spaceBtwItem),
                        _buildStatsGrid(dark),

                        const SizedBox(height: APPSizes.spaceBtwSections),

                        // --- RECENT TRANSACTIONS SECTION ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Transactions",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            TextButton(
                              onPressed: () {
                                final navController =
                                    Get.find<NavigationController>();
                                navController.selectedIndex.value = 3;
                              },
                              child: const Text("View All"),
                            ),
                          ],
                        ),
                        _buildTransactionList(dark),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- UI COMPONENT: BALANCE CARD ---
  Widget _buildBalanceCard(bool dark) {
    // Extract values with defaults to keep the code clean
    final currency = balances['currency']?.toString() ?? "";
    final disbursement = balances['disbursement']?.toString() ?? "0.00";
    final collection = balances['collection']?.toString() ?? "0.00";
    final monthlyTotal =
        disbursementThisMonth['total_amount']?.toString() ?? "0.00";
    final monthlyCurrency = disbursementThisMonth['currency']?.toString() ?? "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: APPColors.primary,
        borderRadius: BorderRadius.circular(APPSizes.cardRadiusLg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.status_up, color: Colors.white60, size: 14),
              const SizedBox(width: 8),
              Text(
                "MERCHANT OVERVIEW",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Disbursement",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        child: Text(
                          "$currency $disbursement",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(
                  color: Colors.white24,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Collection",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        child: Text(
                          "$currency $collection",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white24, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Monthly Total: ",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                "$monthlyCurrency $monthlyTotal",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENT: STATS GRID ---
  Widget _buildStatsGrid(bool dark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 25,
      crossAxisSpacing: 50,
      childAspectRatio: 2.2,
      children: [
        _buildStatItem(
          "Total",
          (stats['total'] ?? 0).toString(),
          Iconsax.activity,
          Colors.blue,
        ),
        _buildStatItem(
          "Success Rate",
          "${stats['success_rate'] ?? 0}%",
          Iconsax.chart_21,
          Colors.green,
        ),
        _buildStatItem(
          "Failed",
          (stats['failed'] ?? 0).toString(),
          Iconsax.danger,
          Colors.red,
        ),
        _buildStatItem(
          "Pending",
          (stats['pending'] ?? 0).toString(),
          Iconsax.timer,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(APPSizes.md),
      decoration: BoxDecoration(
        color: APPHelperFunctions.isDarkMode(context)
            ? APPColors.darkerGrey
            : Colors.white,
        borderRadius: BorderRadius.circular(APPSizes.cardRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENT: TRANSACTION LIST ---
  Widget _buildTransactionList(bool dark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentTransactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trx = recentTransactions[index] ?? {};
        final status = (trx['status']?.toString() ?? "").toLowerCase();
        final isSuccess =
            status == 'successful' ||
            status == 'success' ||
            status == 'completed';
        final isPending = status == 'pending' || status == 'processing';
        final isFailed =
            status == 'failed' || status == 'error' || status == 'declined';

        final statusColor = isSuccess
            ? Colors.green
            : isPending
            ? Colors.orange
            : Colors.red;

        return Container(
          decoration: BoxDecoration(
            color: dark ? APPColors.darkerGrey : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () => Get.to(
              () => TransactionDetails(
                transactionId:
                    trx['transaction_ref'] ??
                    trx['reference'] ??
                    trx['transaction_id'] ??
                    "",
                isMerchant: true,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(
                isSuccess
                    ? Iconsax.tick_circle
                    : isPending
                    ? Iconsax.timer_1
                    : Iconsax.close_circle,
                color: statusColor,
                size: 18,
              ),
            ),
            title: Text(trx['customer']?.toString() ?? "Unknown Customer"),
            subtitle: Text(
              trx['payment_channel']?.toString() ?? "General Channel",
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${trx['currency'] ?? ''} ${trx['amount'] ?? '0'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isSuccess
                      ? "Success"
                      : isPending
                      ? "Pending"
                      : "Failed",
                  style: TextStyle(color: statusColor, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(APPSizes.defaultSpace),
        child: Column(
          children: [
            // Header shimmer
            _shimmerBox(height: 120),

            const SizedBox(height: 20),

            // Balance card shimmer
            _shimmerBox(height: 160),

            const SizedBox(height: 20),

            // Stats grid shimmer
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (_, __) => _shimmerBox(),
            ),

            const SizedBox(height: 20),

            // Transactions shimmer
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _shimmerBox(height: 70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({double height = 80, double? width}) {
    final dark = APPHelperFunctions.isDarkMode(context);
    // We use explicit hex codes here to avoid the "class null" error
    // that happens when Flutter can't resolve Colors.grey[300]
    final Color baseColor = dark ? APPColors.darkerGrey : Colors.grey[300]!;
    final Color highlightColor = dark
        ? APPColors.darkerGrey
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors
              .white, // Container must have a color to "catch" the shimmer
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
