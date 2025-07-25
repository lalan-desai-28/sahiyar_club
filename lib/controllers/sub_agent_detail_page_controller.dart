import 'package:get/get.dart';
import 'package:sahiyar_club/models/stat.dart';
import 'package:sahiyar_club/repositories/home_repository.dart';

class SubAgentDetailPageController extends GetxController {
  final HomeRepository _homeRepository = HomeRepository();
  final isLoading = false.obs;
  final Rxn<Stat> stats = Rxn<Stat>();

  void fetchSubAgentDetails(String subAgentId) async {
    isLoading.value = true;
    stats.value =
        (await _homeRepository.getMyStats(subAgentId: subAgentId)).data;
    isLoading.value = false;
  }
}
