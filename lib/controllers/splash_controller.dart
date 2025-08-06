import 'package:get/get.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/models/user.dart';
import 'package:sahiyar_club/repositories/users_repository.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/utils/hive_database.dart';

class SplashController extends GetxController {
  final HiveDatabase hiveDatabase = Get.find<HiveDatabase>();
  final UsersRepository usersRepository = UsersRepository();

  @override
  void onInit() {
    super.onInit();
    // Initialize any necessary resources here
    checkUserAuthentication();
  }

  Future<User?> getUserFromToken(String token) async {
    if (token.isEmpty) {
      return null;
    }
    final response = await usersRepository.me(token: token);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return null;
    }
  }

  void checkUserAuthentication() async {
    await hiveDatabase.init(); // Ensure Hive is initialized
    final token = hiveDatabase.getToken();
    if (token != null && token.isNotEmpty) {
      final user = await getUserFromToken(token);
      if (user != null) {
        AppStatics.currentUser = user; // Set the current user
        Get.offNamed(AppRoutes.AUTHENTICATION, arguments: user);
        // Get.offNamed(
        //   '/home',
        //   arguments: user,
        // ); // Navigate to home page with user data,
      } else {
        Get.offNamed('/login'); // Navigate to login page if no token
      }
    } else {
      Get.offNamed('/login'); // Navigate to login page if no token
    }
  }
}
