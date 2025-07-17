import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:sahiyar_club/controllers/update_pass_controller.dart';
import 'package:sahiyar_club/models/pass_full.dart';
import 'package:sahiyar_club/widgets/custom_button.dart';
import 'package:sahiyar_club/widgets/custom_form_field.dart';
import 'package:sahiyar_club/widgets/profile_avatar_widget.dart';
import 'package:intl/intl.dart';

class UpdatePassPage extends StatefulWidget {
  const UpdatePassPage({super.key, required this.fullPass});

  final FullPass fullPass;

  @override
  State<UpdatePassPage> createState() => _UpdatePassPageState();
}

class _UpdatePassPageState extends State<UpdatePassPage> {
  final UpdatePassController controller = UpdatePassController();

  @override
  void initState() {
    super.initState();
    controller.init();
    controller.loadPassData(widget.fullPass);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Pass',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Avatar
            _buildProfileAvatar(),

            // ID Proof Field
            _buildIdProofImageField(),
            const SizedBox(height: 16),

            // Full Name Field (Combined)
            _buildFullNameField(),
            const SizedBox(height: 16),

            // Mobile Number Field
            _buildMobileField(),
            const SizedBox(height: 16),

            // Gender Field
            if (widget.fullPass.gender != "kid") ...[
              _buildGenderField(),
              const SizedBox(height: 16),
            ] else ...[
              // Date of Birth (Only for Kids)
              _buildDatePicker(),
              const SizedBox(height: 24),

              // Submit Button
            ],
            SizedBox(width: double.infinity, child: _buildSubmitButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Obx(
      () => ProfileAvatarWidget(
        isUploading: controller.isImageUploading.value,
        progress: controller.uploadProgress.value,
        image:
            controller.profileImage.value != null
                ? Image.file(controller.profileImage.value!)
                : controller.profileNetworkImage.value.isNotEmpty
                ? Image.network(controller.profileNetworkImage.value)
                : null,
        onImageSelected: (file) {
          if (file != null) {
            controller.profileImage.value = file;
          }
        },
        placeholderImage: Image.asset(
          'assets/images/user.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return CustomFormField(
      controller: controller.fullNameController,
      label: 'Full Name',
      keyboardType: TextInputType.name,
      placeholder: "Name + Surname",
    );
  }

  Widget _buildMobileField() {
    return CustomFormField(
      controller: controller.mobileController,
      label: 'Mobile Number',
      keyboardType: TextInputType.number,
      maxLength: 10,
      placeholder: "10 digit mobile number",
    );
  }

  Widget _buildGenderField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: DropdownButton<String>(
              value:
                  controller.gender.value.isEmpty
                      ? null
                      : controller.gender.value,
              hint: Text(
                'Select Gender',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: [
                DropdownMenuItem(
                  value: 'Male',
                  child: Row(
                    children: [
                      Icon(Icons.male, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Male',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Row(
                    children: [
                      Icon(Icons.female, color: Colors.pink[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Female',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                // DropdownMenuItem(
                //   value: 'Kid',
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.child_care,
                //         color: Colors.orange[600],
                //         size: 20,
                //       ),
                //       const SizedBox(width: 8),
                //       Text(
                //         'Kid',
                //         style: TextStyle(
                //           color: Theme.of(context).colorScheme.onSurface,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.gender.value = value;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdProofImageField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID Proof',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => controller.selectIdProofImage(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color:
                      (controller.idProofImage.value != null ||
                              controller.idProofNetworkImage.value.isNotEmpty)
                          ? Colors.green
                          : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.5),
                  width:
                      (controller.idProofImage.value != null ||
                              controller.idProofNetworkImage.value.isNotEmpty)
                          ? 2
                          : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildIdProofPreview(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        (controller.idProofImage.value != null ||
                                controller.idProofNetworkImage.value.isNotEmpty)
                            ? 'File selected'
                            : 'Aadhar Card or Driving License',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              (controller.idProofImage.value != null ||
                                      controller
                                          .idProofNetworkImage
                                          .value
                                          .isNotEmpty)
                                  ? Colors.green[700]
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight:
                              (controller.idProofImage.value != null ||
                                      controller
                                          .idProofNetworkImage
                                          .value
                                          .isNotEmpty)
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(
                      (controller.idProofImage.value != null ||
                              controller.idProofNetworkImage.value.isNotEmpty)
                          ? Icons.check_circle
                          : Icons.badge,
                      color:
                          (controller.idProofImage.value != null ||
                                  controller
                                      .idProofNetworkImage
                                      .value
                                      .isNotEmpty)
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdProofPreview() {
    return Obx(() {
      if (controller.idProofImage.value != null) {
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              controller.idProofImage.value!,
              fit: BoxFit.cover,
            ),
          ),
        );
      } else if (controller.idProofNetworkImage.value.isNotEmpty) {
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: controller.idProofNetworkImage.value,
              fit: BoxFit.cover,
              errorWidget:
                  (context, url, error) => Icon(
                    Icons.image,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                    size: 16,
                  ),
            ),
          ),
        );
      } else {
        return Icon(
          Icons.badge,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          size: 24,
        );
      }
    });
  }

  Widget _buildDatePicker() {
    return Obx(() {
      if (controller.gender.value != 'Kid') {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date of Birth',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showDatePicker(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(controller.selectedDate.value),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.amber[600]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      controller.selectedDate.value = date;
    }
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => CustomButton(
        label: 'Update Pass',
        isLoading: controller.isLoading.value,
        onPressed: () {
          if (controller.isLoading.value) return;
          controller.submitForm(widget.fullPass.sId ?? '');
        },
      ),
    );
  }
}
