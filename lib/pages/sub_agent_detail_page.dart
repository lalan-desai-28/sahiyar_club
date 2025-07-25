import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    controller.fetchSubAgentDetails(subAgent.id!);
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
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final stats = controller.stats.value;
        if (stats == null) {
          return Center(
            child: Text(
              'No data available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    'In Request',
                    stats.inRequestPasses,
                    Icons.hourglass_empty,
                    colorScheme,
                    theme,
                    color: Colors.blue,
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
                ],
              ),
            ],
          ),
        );
      }),
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
          Text(
            '₹${currencyFormatter.format(value ?? 0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
