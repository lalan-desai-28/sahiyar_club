import 'package:get/get.dart';
import 'package:sahiyar_club/models/stat.dart';
import 'package:sahiyar_club/repositories/home_repository.dart';

class SubAgentDetailPageController extends GetxController {
  final HomeRepository _homeRepository = HomeRepository();
  final isLoading = false.obs;
  final Rxn<Stat> stats = Rxn<Stat>();

  Future<void> fetchSubAgentDetails(String subAgentId) async {
    try {
      isLoading.value = true;
      final response = await _homeRepository.getMyStats(subAgentId: subAgentId);
      stats.value = response.data;
    } catch (e) {
      // Handle error - you might want to show a snackbar or error state
      print('Error fetching sub agent details: $e');
      Get.snackbar(
        'Error',
        'Failed to load sub agent details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    stats.value = null;
    super.onClose();
  }
}
