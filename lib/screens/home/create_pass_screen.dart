// create_pass_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/create_pass_controller.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/widgets/custom_button.dart';
import 'package:sahiyar_club/widgets/custom_dropdown.dart';
import 'package:sahiyar_club/widgets/custom_form_field.dart';
import 'package:sahiyar_club/widgets/profile_avatar_widget.dart';
import 'package:intl/intl.dart';

class CreatePassScreen extends StatefulWidget {
  const CreatePassScreen({super.key});

  @override
  State<CreatePassScreen> createState() => _CreatePassScreenState();
}

class _CreatePassScreenState extends State<CreatePassScreen> {
  final CreatePassController _controller = Get.find<CreatePassController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15),

          Obx(
            () => ProfileAvatarWidget(
              isUploading: _controller.isImageUploading.value,
              image:
                  _controller.profileImage.value != null
                      ? Image.file(_controller.profileImage.value!)
                      : null,
              onImageSelected: (file) => _controller.profileImage.value = file,
              placeholderImage: Image.asset(
                'assets/images/user.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ID Proof Field
          Obx(
            () => FileUploadField(
              label: 'ID Proof',
              placeholder: 'Aadhar Card or Driving License',
              selectedFile: _controller.idProofImage.value,
              onFileSelected: _controller.selectIdProofImage,
              icon: Icons.badge,
            ),
          ),
          const SizedBox(height: 14),

          // Full Name Field
          CustomFormField(
            controller: _controller.fullNameController,
            label: 'Full Name',
            keyboardType: TextInputType.name,
            placeholder: "Name + Surname",
          ),
          const SizedBox(height: 14),

          // Mobile Number Field
          CustomFormField(
            controller: _controller.mobileController,
            label: 'Mobile Number',
            keyboardType: TextInputType.number,
            maxLength: 10,
            placeholder: "10 digit mobile number",
          ),
          const SizedBox(height: 14),

          Obx(
            () => CustomDropdown(
              label: 'Gender',
              items: [
                'Male',
                'Female',
                'Kid',
                // add one to item based on condition
                if (AppStatics.currentUser!.agentCode == "AGT001") 'Guest',
              ],
              selectedValue: _controller.gender.value,
              onChanged: (value) => _controller.gender.value = value!,
              itemToString: (item) => item,
            ),
          ),

          const SizedBox(height: 14),

          // Date of Birth (Only for Kids)
          Obx(() {
            if (_controller.gender.value != 'Kid') {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                DatePickerField(
                  label: 'Date of Birth',
                  selectedDate: _controller.selectedDate.value,
                  onDateSelected:
                      (date) => _controller.selectedDate.value = date,
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 365 * 13),
                  ),
                  lastDate: DateTime.now(),
                ),
                const SizedBox(height: 14),
              ],
            );
          }),

          // Payment Switch at the top
          _buildPaymentSwitch(),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => CustomButton(
                isLoading: _controller.isLoading.value,
                label: 'Submit',
                onPressed: _controller.submitForm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSwitch() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    _controller.isPaymentDone.value
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _controller.isPaymentDone.value
                    ? Icons.payment
                    : Icons.payment_outlined,
                color:
                    _controller.isPaymentDone.value
                        ? Colors.green[600]
                        : Colors.orange[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Status',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _controller.isPaymentDone.value ? 'Paid' : 'Pending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          _controller.isPaymentDone.value
                              ? Colors.green[600]
                              : Colors.orange[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _controller.isPaymentDone.value,
              onChanged: (value) => _controller.isPaymentDone.value = value,
              activeColor: Colors.green[600],
              activeTrackColor: Colors.green.withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// File Upload Field Widget with Theme Support
class FileUploadField extends StatelessWidget {
  final String label;
  final String placeholder;
  final dynamic selectedFile;
  final VoidCallback onFileSelected;
  final IconData icon;
  final bool isLoading;

  const FileUploadField({
    super.key,
    required this.label,
    required this.placeholder,
    this.selectedFile,
    required this.onFileSelected,
    this.icon = Icons.upload_file,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isLoading ? null : onFileSelected,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color:
                    selectedFile != null
                        ? Colors.green
                        : Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.5),
                width: selectedFile != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilePreview(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedFile != null ? 'File selected' : placeholder,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            selectedFile != null
                                ? Colors.green[700]
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight:
                            selectedFile != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    Icon(
                      selectedFile != null ? Icons.check_circle : icon,
                      color:
                          selectedFile != null
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
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    if (selectedFile == null) {
      return Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        size: 24,
      );
    }

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
          selectedFile,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Icon(
                Icons.image,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                size: 16,
              ),
        ),
      ),
    );
  }
}

// Date Picker Field Widget with Theme Support
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDatePicker(context),
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
                  DateFormat('dd/MM/yyyy').format(selectedDate),
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
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
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
      onDateSelected(date);
    }
  }
}
