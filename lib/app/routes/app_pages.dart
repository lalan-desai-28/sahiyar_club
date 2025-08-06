import 'package:get/get.dart';
import 'package:sahiyar_club/app/bindings/authentication_bindings.dart';
import 'package:sahiyar_club/app/bindings/sub_agent_detail_page_bindings.dart';
import 'package:sahiyar_club/app/bindings/subagent_form_binding.dart';
import 'package:sahiyar_club/app/bindings/home_bindings.dart';
import 'package:sahiyar_club/app/bindings/login_binding.dart';
import 'package:sahiyar_club/app/bindings/otp_binding.dart';
import 'package:sahiyar_club/app/bindings/pass_list_bindings.dart';
import 'package:sahiyar_club/app/bindings/splash_bindings.dart';
import 'package:sahiyar_club/app/bindings/sub_agents_list_binding.dart';
import 'package:sahiyar_club/app/bindings/total_pass_list_bindings.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/pages/authentication_page.dart';
import 'package:sahiyar_club/pages/home_page.dart';
import 'package:sahiyar_club/pages/login_page.dart';
import 'package:sahiyar_club/pages/otp_page.dart';

import 'package:sahiyar_club/pages/pass_list_page.dart';
import 'package:sahiyar_club/pages/splash_page.dart';
import 'package:sahiyar_club/pages/sub_agent_detail_page.dart';
import 'package:sahiyar_club/pages/sub_agent_form_page.dart';
import 'package:sahiyar_club/pages/sub_agents_list_page.dart';
import 'package:sahiyar_club/pages/total_pass_list_page.dart';

class AppPages {
  static const INITIAL = AppRoutes.AUTHENTICATION;

  static final routes = [
    // Splash
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBindings(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // Auth Routes
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 800),
    ),

    GetPage(
      name: AppRoutes.OTP,
      page: () => const OtpPage(),
      binding: OtpBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Main App Routes
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomePage(),
      binding: HomeBindings(),
      transition: Transition.fade,
    ),

    // Pass Management Routes
    GetPage(
      name: AppRoutes.PASS_LIST,
      page: () => const PassListPage(),
      binding: PassListBindings(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.TOTAL_PASS_LIST,
      page:
          () =>
              const TotalPassListPage(), // Placeholder, replace with actual details page
      binding: TotalPassListBindings(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.SUB_AGENTS_LIST,
      page:
          () =>
              const SubAgentsListPage(), // Placeholder, replace with actual details page
      binding: SubAgentsListBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.SUB_AGENT_FORM_PAGE,
      page:
          () =>
              const SubAgentFormPage(), // Placeholder, replace with actual form page
      binding: SubagentFormBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.SUB_AGENT_DETAIL_PAGE,
      page:
          () =>
              const SubAgentDetailPage(), // Placeholder, replace with actual detail page
      binding: SubAgentDetailPageBindings(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.AUTHENTICATION,
      page: () => AuthenticationPage(),
      transition: Transition.fade,
      binding: AuthenticationBinding(),
    ),
  ];
}
