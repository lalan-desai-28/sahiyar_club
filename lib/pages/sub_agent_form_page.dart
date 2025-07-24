import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/sub_agent_form_controller.dart';
import 'package:sahiyar_club/widgets/custom_button.dart';
import 'package:sahiyar_club/widgets/custom_form_field.dart';

class SubAgentFormPage extends StatefulWidget {
  const SubAgentFormPage({super.key});

  @override
  State<SubAgentFormPage> createState() => _SubAgentFormPageState();
}

class _SubAgentFormPageState extends State<SubAgentFormPage> {
  final SubAgentFormController controller = Get.find<SubAgentFormController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Sub Agent')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10.0,
          children: [
            CustomFormField(
              controller: controller.fullNameController,
              label: 'Full Name',
              keyboardType: TextInputType.name,
              placeholder: "Name + Surname",
            ),
            CustomFormField(
              controller: controller.nickNameController,
              label: 'Nick Name',
              keyboardType: TextInputType.name,
              placeholder: "Short name (That you can remember)",
            ),
            CustomFormField(
              controller: controller.emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              placeholder: "example@mail.com",
            ),
            CustomFormField(
              controller: controller.mobileController,
              label: 'Mobile',
              keyboardType: TextInputType.phone,
              maxLength: 10,
              placeholder: "10 digit mobile number",
            ),
            CustomFormField(
              controller: controller.passwordController,
              label: 'Password',
              keyboardType: TextInputType.visiblePassword,
              placeholder: "Password",
            ),
            const SizedBox(height: 5),
            Obx(
              () => CustomButton(
                label: 'Create',
                onPressed: controller.createSubAgent,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
