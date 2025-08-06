// lib/controllers/pass_list_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/models/pass_full.dart';
import 'package:sahiyar_club/repositories/pass_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class PassListController extends GetxController {
  final PassRepository _passRepository = PassRepository();

  // Scrolling & search
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // State
  final passes = <FullPass>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final isSearching = false.obs;

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 10;

  // Debounce
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void onInit() {
    super.onInit();

    // 1) Scroll listener for infinite scroll
    scrollController.addListener(_onScroll);

    // 2) Wire up searchController → searchQuery
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });

    // 3) Debounce searchQuery changes
    debounce<String>(searchQuery, (val) {
      _currentPage = 1;
      hasMoreData.value = true;
      passes.clear();
      isSearching.value = val.isNotEmpty;
      _fetchPasses();
    }, time: _debounceDuration);

    // 4) Initial load (no search)
    _fetchPasses();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.8 &&
        !isLoadingMore.value &&
        hasMoreData.value &&
        !isSearching.value) {
      _loadMorePasses();
    }
  }

  Future<void> _fetchPasses() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final resp = await _passRepository.getMyPasses(
        page: _currentPage,
        limit: _pageSize,
        status: null,
        gender: null,
        subAgentId: null,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (resp.statusCode == 200) {
        final List<FullPass> fetched = List<FullPass>.from(resp.data ?? []);
        passes.assignAll(fetched);
        hasMoreData.value = fetched.length == _pageSize;
      } else {
        _showError('Failed to fetch passes');
      }
    } catch (e) {
      _showError('Network error: $e');
    } finally {
      isLoading.value = false;
      isSearching.value = false;
    }
  }

  Future<void> _loadMorePasses() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;

    try {
      final nextPage = _currentPage + 1;
      final resp = await _passRepository.getMyPasses(
        page: nextPage,
        limit: _pageSize,
        status: null,
        gender: null,
        subAgentId: null,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (resp.statusCode == 200) {
        final List<FullPass> more = List<FullPass>.from(resp.data ?? []);
        if (more.isNotEmpty) {
          passes.addAll(more);
          _currentPage = nextPage;
          hasMoreData.value = more.length == _pageSize;
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
    _currentPage = 1;
    hasMoreData.value = true;
    passes.clear();
    await _fetchPasses();
  }

  void clearSearch() {
    if (searchController.text.isEmpty) return;
    searchController.clear();
    // Debounce will trigger a fresh fetch.
  }

  void _showError(String msg) {
    SnackbarUtil.showErrorSnackbar(title: 'Error', message: msg);
  }
}
