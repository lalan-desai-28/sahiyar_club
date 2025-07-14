import 'package:get/get.dart';
import 'package:sahiyar_club/models/stat.dart';
import 'package:sahiyar_club/repositories/home_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class DashboardController extends GetxController {
  final HomeRepository _homeRepository = HomeRepository();

  final stats = Rxn<Stat>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  // Always fetch fresh data (no caching)
  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final response = await _homeRepository.getMyStats();

      if (response.statusCode == 200 && response.data != null) {
        stats.value = response.data;
      } else {
        _showError('Failed to fetch dashboard statistics');
      }
    } catch (e) {
      _showError('Network error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStats() async {
    await fetchStats();
  }

  void _showError(String message) {
    SnackbarUtil.showErrorSnackbar(title: 'Error', message: message);
  }
}
