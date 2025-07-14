import 'package:get/get.dart';
import 'package:sahiyar_club/models/user.dart';
import 'package:sahiyar_club/repositories/users_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class SubAgentsListController extends GetxController {
  final RxList<User> subAgents = <User>[].obs;
  final RxBool isLoading = true.obs;
  final UsersRepository usersRepository = UsersRepository();

  @override
  void onInit() {
    super.onInit();
    fetchSubAgents();
  }

  void fetchSubAgents() async {
    isLoading.value = true;
    try {
      final response = await usersRepository.getSubAgents();
      if (response.statusCode == 200) {
        subAgents.value = response.data ?? [];
      } else {
        SnackbarUtil.showErrorSnackbar(
          title: 'Error',
          message: 'Failed to load sub-agents: ${response.statusMessage}',
        );
      }
    } catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message: 'An error occurred while fetching sub-agents',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
