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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          controller.isEditMode ? 'Edit Sub Agent' : 'Create Sub Agent',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Header
              _buildFormHeader(theme, colorScheme),

              const SizedBox(height: 24),

              // Personal Information Section
              _buildSectionHeader('Personal Information', theme),
              const SizedBox(height: 12),

              CustomFormField(
                controller: controller.fullNameController,
                label: 'Full Name',
                keyboardType: TextInputType.name,
                placeholder: "Enter full name",
                validator: controller.validateFullName,
                prefixIcon: Icon(Icons.person_outline),
              ),

              const SizedBox(height: 16),

              CustomFormField(
                controller: controller.nickNameController,
                label: 'Nick Name',
                keyboardType: TextInputType.name,
                maxLength: 10,
                placeholder: "Short name for easy identification",
                validator: controller.validateNickName,
                prefixIcon: Icon(Icons.badge_outlined),
              ),

              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionHeader('Contact Information', theme),
              const SizedBox(height: 12),

              CustomFormField(
                controller: controller.emailController,
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                placeholder: "example@mail.com",
                validator: controller.validateEmail,
                prefixIcon: Icon(Icons.email_outlined),
              ),

              const SizedBox(height: 16),

              CustomFormField(
                controller: controller.mobileController,
                label: 'Mobile Number',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                placeholder: "10 digit mobile number",
                validator: controller.validateMobile,
                prefixIcon: Icon(Icons.phone_outlined),
              ),

              const SizedBox(height: 24),

              // Security Section
              _buildSectionHeader('Security', theme),
              const SizedBox(height: 12),

              CustomFormField(
                controller: controller.passwordController,
                label: controller.isEditMode ? 'New Password' : 'Password',
                keyboardType: TextInputType.visiblePassword,
                placeholder:
                    controller.isEditMode
                        ? "Leave empty to keep current password"
                        : "Minimum 6 characters",
                validator: controller.validatePassword,
                prefixIcon: Icon(Icons.lock_outline),
                obscureText: true,
              ),

              if (controller.isEditMode) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Leave password field empty if you don\'t want to change it.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (controller.isEditMode) ...[
                const SizedBox(height: 24),
                _buildSectionHeader('Status', theme),
                const SizedBox(height: 12),

                Obx(
                  () => Card(
                    child: SwitchListTile(
                      title: const Text('Active Status'),
                      subtitle: Text(
                        controller.isActive.value
                            ? 'Agent is active and can login'
                            : 'Agent is inactive and cannot login',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              controller.isActive.value
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                      value: controller.isActive.value,
                      onChanged: (value) => controller.isActive.value = value,
                      secondary: Icon(
                        controller.isActive.value
                            ? Icons.check_circle_outline
                            : Icons.block,
                        color:
                            controller.isActive.value
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action Buttons
              Obx(
                () => Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label:
                            controller.isEditMode
                                ? 'Update Sub Agent'
                                : 'Create Sub Agent',
                        onPressed: controller.createSubAgent,
                        isLoading: controller.isLoading.value,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            controller.isLoading.value
                                ? null
                                : () => _showCancelDialog(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              controller.isEditMode ? Icons.edit : Icons.person_add,
              color: colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isEditMode
                      ? 'Edit Sub Agent'
                      : 'Create New Sub Agent',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  controller.isEditMode
                      ? 'Update the information below to modify sub agent details'
                      : 'Fill in the information below to create a new sub agent',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Form'),
        content: Text(
          controller.isEditMode
              ? 'Are you sure you want to cancel editing? All unsaved changes will be lost.'
              : 'Are you sure you want to cancel creating the sub agent? All entered data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue Editing'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Close form
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
