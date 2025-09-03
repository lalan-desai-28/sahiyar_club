// TotalPassListPage
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/total_pass_list_controller.dart';
import 'package:sahiyar_club/models/fee_batch.dart';
import 'package:sahiyar_club/models/user.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/widgets/custom_dropdown.dart';
import 'package:sahiyar_club/widgets/pass_card.dart';

class TotalPassListPage extends StatefulWidget {
  const TotalPassListPage({super.key});

  @override
  State<TotalPassListPage> createState() => _TotalPassListPageState();
}

class _TotalPassListPageState extends State<TotalPassListPage> {
  final TotalPassListController _controller = Get.put(
    TotalPassListController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildBody(context)),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'All Passes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '( Total ${_controller.totalPassCount.value} )',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => _buildFilterChips(context)),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: _showFilterDialog,
        ),
        Obx(
          () =>
              _controller.hasActiveFilters
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: _controller.clearFilters,
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final activeFilters = _controller.getActiveFilters();

    if (activeFilters.isEmpty) {
      return Text(
        'All Passes',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.normal,
        ),
      );
    }

    return Container(
      height: 32,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = activeFilters[index];
          return Text(
            filter,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.amber[700],
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading.value) {
      return _buildLoadingState(context);
    }

    if (_controller.passes.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildPassList(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 64, color: Colors.amber[600]),
            ),
            const SizedBox(height: 24),
            Text(
              'No Passes Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No passes match your current filters.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _controller.clearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber[600],
                      side: BorderSide(color: Colors.amber[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.fetchPasses,
                    icon: const Icon(
                      Icons.refresh,
                      size: 20,
                      color: Colors.black,
                    ),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[600],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildPassList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _controller.refreshPasses,
      color: Colors.amber[600],
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        controller: _controller.scrollController,
        itemCount:
            _controller.passes.length + (_controller.hasMoreData.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _controller.passes.length) {
            return PassCard(fullPass: _controller.passes[index]);
          }
          return _buildLoadMoreIndicator(context);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    if (!_controller.isLoadingMore.value) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more passes...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(controller: _controller),
    );
  }
}

// Filter Bottom Sheet Widget with Theme Support
class _FilterBottomSheet extends StatelessWidget {
  final TotalPassListController controller;

  const _FilterBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildFilters(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Filter Passes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    final genderOptions = [
      'Male',
      'Female',
      'Kid',
      if (AppStatics.currentUser?.agentCode == "AGT001") 'Guest',
    ];

    return Column(
      children: [
        // Fee Dropdown
        _buildCompactDropdown(
          context: context,
          label: 'Fee Batch',
          child: Obx(
            () => DropdownButtonFormField<FeeBatch>(
              value: controller.selectedFeeBatch.value,
              decoration: _getInputDecoration(context, 'Fee Batch'),
              items:
                  controller.feeBatches.map((batch) {
                    return DropdownMenuItem<FeeBatch>(
                      value: batch,
                      child: Text(batch.batchName ?? "Fee Batch"),
                    );
                  }).toList(),
              onChanged: (value) {
                controller.selectedFeeBatch.value = value;
                controller.applyFilters();
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Status Dropdown
        _buildCompactDropdown(
          context: context,
          label: 'Status',
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedStatus.value,
              decoration: _getInputDecoration(context, 'Status'),
              items:
                  controller.statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
              onChanged: (value) {
                controller.selectedStatus.value = value;
                controller.applyFilters();
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Gender Dropdown
        _buildCompactDropdown(
          context: context,
          label: 'Gender',
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedGender.value,
              decoration: _getInputDecoration(context, 'Gender'),
              items:
                  genderOptions.map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
              onChanged: (value) {
                controller.selectedGender.value = value;
                controller.applyFilters();
              },
            ),
          ),
        ),

        if (AppStatics.currentUser!.role == "agent" &&
            controller.subAgents.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildCompactDropdown(
            context: context,
            label: 'Sub Agent',
            child: Obx(
              () => DropdownButtonFormField<User>(
                value: controller.selectedSubAgent.value,
                decoration: _getInputDecoration(context, 'Sub Agent'),
                items:
                    controller.subAgents.map((agent) {
                      return DropdownMenuItem<User>(
                        value: agent,
                        child: Text(agent.toString()),
                      );
                    }).toList(),
                onChanged: (value) {
                  controller.selectedSubAgent.value = value;
                  // Set includeSubAgents to null when specific sub agent is selected
                  if (value != null) {
                    controller.includeSubAgents.value = null;
                  }
                  controller.applyFilters();
                },
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Include Sub Agents Checkbox
        Obx(
          () => _buildCheckboxTile(
            context: context,
            title: 'Include Sub Agents',
            subtitle: 'Show passes from all sub agents',
            value: controller.includeSubAgents.value,
            onChanged: (value) {
              controller.includeSubAgents.value = value;
              // Clear specific sub agent when including all
              if (value == true) {
                controller.selectedSubAgent.value = null;
              }
              controller.applyFilters();
            },
          ),
        ),

        const SizedBox(height: 8),

        // Payment Status Checkbox
        Obx(
          () => _buildCheckboxTile(
            context: context,
            title: 'Amount Paid',
            subtitle: 'Show only passes where amount is paid',
            value: controller.isAmountPaid.value,
            onChanged: (value) {
              controller.isAmountPaid.value = value;
              controller.applyFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDropdown({
    required BuildContext context,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  InputDecoration _getInputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.amber[600]!),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildCheckboxTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        value: value,
        tristate: true,
        onChanged: onChanged,
        activeColor: Colors.amber[600],
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        dense: true,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              controller.clearFilters();
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.amber[600]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: Colors.amber[600],
            ),
            child: Text(
              'Clear All',
              style: TextStyle(
                color: Colors.amber[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              controller.applyFilters();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
