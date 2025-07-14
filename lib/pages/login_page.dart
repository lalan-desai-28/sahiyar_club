import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:sahiyar_club/controllers/login_controller.dart';
import 'package:sahiyar_club/widgets/custom_button.dart';
import 'package:sahiyar_club/widgets/custom_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController loginController = LoginController();

  Widget _buildLogo() {
    return Hero(
      tag: "logo",
      child: Image.asset('assets/images/sc_logo.png', height: 200, width: 200),
    );
  }

  Widget _buildMobileField() {
    return CustomFormField(
      controller: loginController.mobileController,
      label: 'Mobile',
      keyboardType: TextInputType.phone,
      placeholder: "10-digit mobile number",
      maxLength: 10,
    );
  }

  Widget _buildPasswordField() {
    return CustomFormField(
      controller: loginController.passwordController,
      label: 'Password',
      placeholder: "Enter your password",
      obscureText: true,
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => CustomButton(
        label: 'Submit',
        onPressed: () {
          loginController.login();
        },
        isLoading: loginController.isLoading.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // SizedBox.expand(
          //   child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          // ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16.0,
              children: [
                SizedBox(height: 100),
                _buildLogo(),
                _buildMobileField(),
                _buildPasswordField(),
                _buildLoginButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
