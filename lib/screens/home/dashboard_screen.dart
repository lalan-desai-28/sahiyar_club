import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sahiyar_club/controllers/dashboard_controller.dart';
import 'package:sahiyar_club/controllers/home_controller.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/models/stat.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/widgets/animated_counter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = AppStatics.dashboardController;

  @override
  void initState() {
    super.initState();
    _controller.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _controller.refreshStats,
      color: Colors.amber,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Obx(() => _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading.value) {
      return _buildLoadingState();
    }

    return Column(children: [_buildHeader(), _buildMainContent()]);
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Hero(
            tag: "logo",
            child: Image.asset(
              'assets/images/sc_logo.png',
              height: 250,
              width: 250,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(),
          const SizedBox(height: 32),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildGenderBreakdown(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final stats = _controller.stats.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrentFeesCard(stats?.currentFeeBatch),
        const SizedBox(height: 20),
        _buildSectionHeader('Pass Statistics', Icons.analytics, showIcon: true),
        const SizedBox(height: 16),
        _buildTotalPassCard(stats?.totalPasses ?? 0),
        // const SizedBox(height: 16),
        // _buildInclusiveSubAgentsFilter(context),
        const SizedBox(height: 16),
        _buildStatusGrid(stats),
      ],
    );
  }

  Widget _buildCurrentFeesCard(CurrentFeeBatch? feeBatch) {
    if (feeBatch == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A8A), // Deep blue
            const Color(0xFF3B82F6), // Blue
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Pass Price',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (feeBatch.batchName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          feeBatch.batchName!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildFeeItemWithMRP(
                  'Male',
                  feeBatch.maleFee ?? 0,
                  feeBatch.maleMrp ?? feeBatch.maleFee ?? 0,
                  Icons.male,
                  const Color(0xFF60A5FA),
                  feeBatch.maleFee! < feeBatch.maleMrp!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeeItemWithMRP(
                  'Female',
                  feeBatch.femaleFee ?? 0,
                  feeBatch.femaleMrp ?? feeBatch.femaleFee ?? 0,
                  Icons.female,
                  const Color(0xFFF472B6),
                  feeBatch.femaleFee! < feeBatch.femaleMrp!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeeItemWithMRP(
                  'Kid',
                  feeBatch.kidFee ?? 0,
                  feeBatch.kidMrp ?? feeBatch.kidFee ?? 0,
                  Icons.child_care,
                  const Color(0xFFFBBF24),
                  feeBatch.kidFee! < feeBatch.kidMrp!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItemWithMRP(
    String label,
    int currentPrice,
    int mrpPrice,
    IconData icon,
    Color color,
    bool shouldShowMRP,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          // MRP with strike-through
          shouldShowMRP
              ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '₹${_formatAmount(mrpPrice)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.white.withOpacity(0.6),
                    decorationThickness: 1.5,
                    fontSize: 12,
                  ),
                ),
              )
              : const SizedBox.shrink(),
          const SizedBox(height: 2),
          // Current price
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${_formatAmount(currentPrice)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPassCard(int totalPasses) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber[600]!, Colors.orange[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.TOTAL_PASS_LIST),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.badge, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Passes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedCounter(
                    value: totalPasses,
                    duration: const Duration(milliseconds: 1000),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGrid(dynamic stats) {
    final statusItems = [
      _StatusItem(
        'Pending',
        stats?.pendingPasses ?? 0,
        Icons.pending,
        Colors.orange[600]!,
        'Pending',
      ),
      _StatusItem(
        'Approved',
        stats?.approvedPasses ?? 0,
        Icons.check_circle,
        Colors.green[600]!,
        'Approved',
      ),
      _StatusItem(
        'Issued',
        stats?.issuedPasses ?? 0,
        Icons.assignment,
        Colors.purple[600]!,
        'Issued',
      ),
      _StatusItem(
        'Rejected',
        stats?.rejectedPasses ?? 0,
        Icons.cancel,
        Colors.red[600]!,
        'RejectedForQuery',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemCount: statusItems.length,
      itemBuilder: (context, index) {
        final item = statusItems[index];
        return _buildStatusCard(item);
      },
    );
  }

  Widget _buildStatusCard(_StatusItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToFilteredList(item.filterValue),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              const SizedBox(height: 6),
              AnimatedCounter(
                value: item.count,
                duration: const Duration(milliseconds: 800),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderBreakdown() {
    final stats = _controller.stats.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Gender Distribution', Icons.people),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGenderCard(
                icon: Icons.male,
                title: 'Male',
                count: stats?.totalMalePasses ?? 0,
                color: Colors.blue[600]!,
                gender: 'Male',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderCard(
                icon: Icons.female,
                title: 'Female',
                count: stats?.totalFemalePasses ?? 0,
                color: Colors.pink[600]!,
                gender: 'Female',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderCard(
                icon: Icons.child_care,
                title: 'Kids',
                count: stats?.totalKidPasses ?? 0,
                color: Colors.orange[600]!,
                gender: 'Kid',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    required String gender,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToGenderFilteredList(gender),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              AnimatedCounter(
                value: count,
                duration: const Duration(milliseconds: 1000),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Actions', Icons.flash_on),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline,
                title: 'Create Pass',
                subtitle: 'Request new pass',
                color: Colors.green[600]!,
                onTap: () => Get.find<HomeController>().changeTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.list_alt,
                title: 'View All',
                subtitle: 'All passes list',
                color: Colors.blue[600]!,
                onTap: () => Get.toNamed(AppRoutes.PASS_LIST),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInclusiveSubAgentsFilter(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color:
                _controller.inclusiveSubAgents.value
                    ? Colors.amber.withOpacity(0.3)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Include Sub-Agent Passes',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _controller.inclusiveSubAgents.value
                            ? 'Currently showing passes from all sub-agents'
                            : 'Showing only your passes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 1.1,
                  child: Switch(
                    value: _controller.inclusiveSubAgents.value,
                    onChanged: (value) {
                      _controller.inclusiveSubAgents.value = value;
                      _controller.fetchStats();
                    },
                    activeColor: Colors.amber[600],
                    activeTrackColor: Colors.amber.withOpacity(0.3),
                    inactiveThumbColor: Theme.of(context).colorScheme.outline,
                    inactiveTrackColor: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _controller.inclusiveSubAgents.value
                        ? Colors.amber.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _controller.inclusiveSubAgents.value
                        ? Icons.info_outline
                        : Icons.person_outline,
                    size: 16,
                    color:
                        _controller.inclusiveSubAgents.value
                            ? Colors.amber[700]
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.inclusiveSubAgents.value
                          ? 'Default: Includes passes from all your sub-agents along with your own passes'
                          : 'Only your directly created passes will be shown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            _controller.inclusiveSubAgents.value
                                ? Colors.amber[700]
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildSectionHeader(String title, IconData icon, {bool? showIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.2),
                  Colors.amber.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.amber[600], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (showIcon == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _controller.inclusiveSubAgents.value ? 'All' : 'Yours',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFilteredList(String status) {
    Get.toNamed(AppRoutes.TOTAL_PASS_LIST, arguments: {'status': status});
  }

  void _navigateToGenderFilteredList(String gender) {
    Get.toNamed(AppRoutes.TOTAL_PASS_LIST, arguments: {'gender': gender});
  }

  // Helper method to format amount in INR format
  String _formatAmount(int amount) {
    if (amount == 0) return '0';
    return NumberFormat('#,##,###').format(amount);
  }
}

class _StatusItem {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final String filterValue;

  _StatusItem(this.title, this.count, this.icon, this.color, this.filterValue);
}
