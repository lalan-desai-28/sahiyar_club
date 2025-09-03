import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/controllers/sub_agent_detail_page_controller.dart';
import 'package:sahiyar_club/models/user.dart';
import 'package:sahiyar_club/widgets/animated_counter.dart';

class SubAgentDetailPage extends StatefulWidget {
  const SubAgentDetailPage({super.key});

  @override
  State<SubAgentDetailPage> createState() => _SubAgentDetailPageState();
}

class _SubAgentDetailPageState extends State<SubAgentDetailPage> {
  final SubAgentDetailPageController controller =
      Get.find<SubAgentDetailPageController>();
  final User subAgent = Get.arguments as User;
  final NumberFormat currencyFormatter = NumberFormat('#,##,##0', 'en_IN');

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding.instance.addPostFrameCallback to ensure the fetch happens after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSubAgentDetails(subAgent.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${subAgent.fullName ?? 'Sub Agent'} Details'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // redirect to edit page
              Get.toNamed(AppRoutes.SUB_AGENT_FORM_PAGE, arguments: subAgent);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchSubAgentDetails(subAgent.id!);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading statistics...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final stats = controller.stats.value;
        if (stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No data available',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
            controller.fetchSubAgentDetails(subAgent.id!);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agent Info Card
                _buildAgentInfoCard(colorScheme, theme),

                const SizedBox(height: 16),

                // Pass Statistics Section
                _buildSectionCard(
                  title: 'Pass Statistics',
                  colorScheme: colorScheme,
                  theme: theme,
                  children: [
                    _buildStatRow(
                      'Total Passes',
                      stats.totalPasses,
                      Icons.assignment,
                      colorScheme,
                      theme,
                    ),
                    _buildStatRow(
                      'Pending',
                      stats.pendingPasses,
                      Icons.schedule,
                      colorScheme,
                      theme,
                      color: Colors.orange,
                    ),
                    _buildStatRow(
                      'Issued',
                      stats.issuedPasses,
                      Icons.card_membership,
                      colorScheme,
                      theme,
                      color: Colors.purple,
                    ),
                    _buildStatRow(
                      'Approved',
                      stats.approvedPasses,
                      Icons.check_circle,
                      colorScheme,
                      theme,
                      color: Colors.green,
                    ),
                    _buildStatRow(
                      'Rejected',
                      stats.rejectedPasses,
                      Icons.cancel,
                      colorScheme,
                      theme,
                      color: Colors.red,
                    ),
                    _buildStatRow(
                      'Cancelled',
                      stats.cancelledPasses,
                      Icons.block,
                      colorScheme,
                      theme,
                      color: Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Gender-wise Pass Count Section
                _buildSectionCard(
                  title: 'Gender-wise Pass Count',
                  colorScheme: colorScheme,
                  theme: theme,
                  children: [
                    _buildStatRow(
                      'Male Passes',
                      stats.totalMalePasses,
                      Icons.male,
                      colorScheme,
                      theme,
                      color: Colors.blue,
                    ),
                    _buildStatRow(
                      'Female Passes',
                      stats.totalFemalePasses,
                      Icons.female,
                      colorScheme,
                      theme,
                      color: Colors.pink,
                    ),
                    _buildStatRow(
                      'Kid Passes',
                      stats.totalKidPasses,
                      Icons.child_care,
                      colorScheme,
                      theme,
                      color: Colors.amber,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Revenue Section
                _buildSectionCard(
                  title: 'Collected Fees',
                  colorScheme: colorScheme,
                  theme: theme,
                  children: [
                    _buildCurrencyRow(
                      'Male Fees',
                      stats.totalMaleCollectedFees,
                      Icons.currency_rupee,
                      colorScheme,
                      theme,
                      color: Colors.blue,
                    ),
                    _buildCurrencyRow(
                      'Female Fees',
                      stats.totalFemaleCollectedFees,
                      Icons.currency_rupee,
                      colorScheme,
                      theme,
                      color: Colors.pink,
                    ),
                    _buildCurrencyRow(
                      'Kid Fees',
                      stats.totalKidCollectedFees,
                      Icons.currency_rupee,
                      colorScheme,
                      theme,
                      color: Colors.amber,
                    ),
                    const Divider(height: 24),
                    _buildCurrencyRow(
                      'Total Collected',
                      (stats.totalMaleCollectedFees ?? 0) +
                          (stats.totalFemaleCollectedFees ?? 0) +
                          (stats.totalKidCollectedFees ?? 0),
                      Icons.account_balance_wallet,
                      colorScheme,
                      theme,
                      color: Colors.green,
                      isTotal: true,
                    ),
                  ],
                ),

                // Add some bottom padding
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAgentInfoCard(ColorScheme colorScheme, ThemeData theme) {
    return Card(
      elevation: 2,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  subAgent.fullName?.substring(0, 1).toUpperCase() ?? 'S',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subAgent.fullName ?? 'Unknown Agent',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (subAgent.agentCode != null)
                    Text(
                      'Code: ${subAgent.agentCode}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  if (subAgent.mobile != null)
                    Text(
                      'Mobile: ${subAgent.mobile}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required ColorScheme colorScheme,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    int? value,
    IconData icon,
    ColorScheme colorScheme,
    ThemeData theme, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color ?? colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          AnimatedCounter(
            value: value ?? 0,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(
    String label,
    int? value,
    IconData icon,
    ColorScheme colorScheme,
    ThemeData theme, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color ?? colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '₹${currencyFormatter.format(value ?? 0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? colorScheme.primary,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
