import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/models/pass_full.dart';
import 'package:sahiyar_club/repositories/pass_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class PassListController extends GetxController {
  final PassRepository _passRepository = PassRepository();
  final ScrollController scrollController = ScrollController();

  final passes = <FullPass>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;

  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
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

  Future<void> fetchMyPasses() async {
    if (isLoading.value) return;

    isLoading.value = true;
    _currentPage = 1;
    hasMoreData.value = true;
    passes.clear();

    try {
      final response = await _passRepository.getMyPasses(
        page: 1,
        limit: _pageSize,
        status: null,
        gender: null,
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
        status: null,
        gender: null,
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
    await fetchMyPasses();
  }

  void _showError(String message) {
    SnackbarUtil.showErrorSnackbar(title: 'Error', message: message);
  }
}
