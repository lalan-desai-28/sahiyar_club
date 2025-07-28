// TotalPassListController
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/models/pass_full.dart';
import 'package:sahiyar_club/models/user.dart';
import 'package:sahiyar_club/repositories/pass_repository.dart';
import 'package:sahiyar_club/repositories/users_repository.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class TotalPassListController extends GetxController {
  final PassRepository _passRepository = PassRepository();
  final UsersRepository _usersRepository = UsersRepository();
  final ScrollController scrollController = ScrollController();

  final passes = <FullPass>[].obs;
  final subAgents = <User>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final selectedSubAgent = Rxn<User>();

  final selectedStatus = Rxn<String>();
  final selectedGender = Rxn<String>();

  int _currentPage = 1;
  static const int _pageSize = 10;

  // Filter options
  final statusOptions = [
    'InRequest',
    'Pending',
    'Approved',
    'Issued',
    'RejectedForQuery',
  ];

  void getSubAgents() async {
    isLoading.value = true;
    final subagents = await _usersRepository.getSubAgents();
    subAgents.assignAll(subagents.data ?? []);
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);

    // Get initial filters from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedStatus.value = args['status'];
      selectedGender.value = args['gender'];
    }

    fetchPasses();
    if (AppStatics.currentUser?.role == "agent") {
      getSubAgents();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (_shouldLoadMore()) {
      _loadMorePasses();
    }
  }

  bool _shouldLoadMore() {
    return scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore.value &&
        hasMoreData.value;
  }

  Future<void> fetchPasses() async {
    if (isLoading.value) return;

    isLoading.value = true;
    _currentPage = 1;
    hasMoreData.value = true;
    passes.clear();

    try {
      final response = await _passRepository.getMyPasses(
        page: 1,
        limit: _pageSize,
        status: selectedStatus.value,
        gender: selectedGender.value,
        subAgentId: selectedSubAgent.value?.id,
      );

      if (response.statusCode == 200) {
        final newPasses = List<FullPass>.from(response.data ?? []);
        passes.assignAll(newPasses);
        hasMoreData.value = newPasses.length == _pageSize;
      } else {
        _showError('Failed to fetch passes');
      }
    } catch (e) {
      _showError('Network error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMorePasses() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;

    try {
      final response = await _passRepository.getMyPasses(
        page: _currentPage + 1,
        limit: _pageSize,
        status: selectedStatus.value,
        gender: selectedGender.value,
        subAgentId: selectedSubAgent.value?.id,
      );

      if (response.statusCode == 200) {
        final newPasses = List<FullPass>.from(response.data ?? []);

        if (newPasses.isNotEmpty) {
          passes.addAll(newPasses);
          _currentPage++;
          hasMoreData.value = newPasses.length == _pageSize;
        } else {
          hasMoreData.value = false;
        }
      }
    } catch (e) {
      _showError('Failed to load more: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshPasses() async {
    await fetchPasses();
  }

  void applyFilters() {
    fetchPasses();
  }

  void clearFilters() {
    selectedStatus.value = null;
    selectedGender.value = null;
    selectedSubAgent.value = null;
    fetchPasses();
  }

  void _showError(String message) {
    SnackbarUtil.showErrorSnackbar(title: 'Error', message: message);
  }

  String get filterSummary {
    List<String> activeFilters = [];
    if (selectedStatus.value != null) {
      activeFilters.add('Status: ${selectedStatus.value}');
    }
    if (selectedGender.value != null) {
      activeFilters.add('Gender: ${selectedGender.value}');
    }
    if (selectedSubAgent.value != null) {
      activeFilters.add('Sub Agent: ${selectedSubAgent.value?.nickName}');
    }
    return activeFilters.isEmpty ? 'All Passes' : activeFilters.join(' • ');
  }
}
