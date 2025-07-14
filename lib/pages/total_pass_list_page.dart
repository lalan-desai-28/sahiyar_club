// TotalPassListPage
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/total_pass_list_controller.dart';
import 'package:sahiyar_club/widgets/pass_card.dart';
import 'package:sahiyar_club/widgets/custom_dropdown.dart';

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
          Text(
            'All Passes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Obx(
            () => Text(
              _controller.filterSummary,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
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
              _controller.selectedStatus.value != null ||
                      _controller.selectedGender.value != null
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildFilters(context),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Spacer(),
        Text(
          'Filter Passes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      children: [
        // Status Dropdown
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: DropdownButton<String>(
                  value: controller.selectedStatus.value,
                  hint: Text(
                    'Select Status',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  items:
                      controller.statusOptions.map((String status) {
                        IconData icon;
                        Color color;

                        switch (status.toLowerCase()) {
                          case 'inrequest':
                            icon = Icons.send;
                            color = Colors.blue[600]!;
                            break;
                          case 'pending':
                            icon = Icons.pending;
                            color = Colors.orange[600]!;
                            break;
                          case 'approved':
                            icon = Icons.check_circle;
                            color = Colors.green[600]!;
                            break;
                          case 'rejectedforquery':
                            icon = Icons.error;
                            color = Colors.red[600]!;
                            break;
                          case 'printed':
                            icon = Icons.print;
                            color = Colors.purple[600]!;
                            break;
                          default:
                            icon = Icons.help_outline;
                            color = Colors.grey[600]!;
                        }

                        return DropdownMenuItem<String>(
                          value: status,
                          child: Row(
                            children: [
                              Icon(icon, color: color, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) => controller.selectedStatus.value = value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Gender Dropdown
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: DropdownButton<String>(
                  value: controller.selectedGender.value,
                  hint: Text(
                    'Select Gender',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  items:
                      controller.genderOptions.map((String gender) {
                        IconData icon;
                        Color color;

                        switch (gender.toLowerCase()) {
                          case 'male':
                            icon = Icons.male;
                            color = Colors.blue[600]!;
                            break;
                          case 'female':
                            icon = Icons.female;
                            color = Colors.pink[600]!;
                            break;
                          case 'kid':
                            icon = Icons.child_care;
                            color = Colors.orange[600]!;
                            break;
                          default:
                            icon = Icons.person;
                            color = Colors.grey[600]!;
                        }

                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Row(
                            children: [
                              Icon(icon, color: color, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                gender.toUpperCase(),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) => controller.selectedGender.value = value,
                ),
              ),
            ],
          ),
        ),
      ],
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
              padding: const EdgeInsets.symmetric(vertical: 16),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
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
