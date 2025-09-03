import 'package:get/get.dart';
import 'package:sahiyar_club/models/stat.dart';
import 'package:sahiyar_club/repositories/home_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  final HomeRepository _homeRepository = HomeRepository();

  final stats = Rxn<Stat>();
  final isLoading = false.obs;
  final inclusiveSubAgents = true.obs;

  Future<void> getInclusiveSubAgentsFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    inclusiveSubAgents.value = prefs.getBool('inclusiveSubAgents') ?? true;
    print('Inclusive Sub-Agents: ${inclusiveSubAgents.value}');
  }

  // Always fetch fresh data (no caching)
  Future<void> fetchStats() async {
    try {
      await getInclusiveSubAgentsFromSharedPref();

      isLoading.value = true;
      final response = await _homeRepository.getMyStats(
        inclusiveSubAgents: inclusiveSubAgents.value,
      );

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
