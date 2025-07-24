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
  late final CreatePassController _controller;
  late final List<String> _genderItems;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CreatePassController>();
    _genderItems = _buildGenderItems();
  }

  List<String> _buildGenderItems() {
    final items = ['Male', 'Female', 'Kid'];
    if (AppStatics.currentUser?.agentCode == "AGT001") {
      items.add('Guest');
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          _buildProfileAvatar(),
          _buildIdProofField(),
          const SizedBox(height: 14),
          _buildFullNameField(),
          const SizedBox(height: 14),
          _buildMobileField(),
          const SizedBox(height: 14),
          _buildGenderDropdown(),
          const SizedBox(height: 14),
          _buildDateOfBirthField(),
          _buildPaymentSwitch(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Obx(
      () => ProfileAvatarWidget(
        isUploading: _controller.isLoading.value,
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
    );
  }

  Widget _buildIdProofField() {
    return Obx(
      () => FileUploadField(
        label: 'ID Proof',
        placeholder: 'Aadhar Card or Driving License',
        selectedFile: _controller.idProofImage.value,
        onFileSelected: _controller.selectIdProofImage,
        icon: Icons.badge,
      ),
    );
  }

  Widget _buildFullNameField() {
    return CustomFormField(
      controller: _controller.fullNameController,
      label: 'Full Name',
      keyboardType: TextInputType.name,
      placeholder: "Name + Surname",
      allowOnlyAlphabetic: true,
    );
  }

  Widget _buildMobileField() {
    return CustomFormField(
      controller: _controller.mobileController,
      label: 'Mobile Number',
      keyboardType: TextInputType.number,
      maxLength: 10,
      placeholder: "10 digit mobile number",
    );
  }

  Widget _buildGenderDropdown() {
    return Obx(
      () => CustomDropdown(
        label: 'Gender',
        items: _genderItems,
        selectedValue: _controller.gender.value,
        onChanged: (value) => _controller.gender.value = value!,
        itemToString: (item) => item,
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Obx(() {
      if (_controller.gender.value != 'Kid') {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          DatePickerField(
            label: 'Date of Birth',
            selectedDate: _controller.selectedDate.value,
            onDateSelected: (date) => _controller.selectedDate.value = date,
            firstDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
            lastDate: DateTime.now(),
          ),
          const SizedBox(height: 14),
        ],
      );
    });
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => CustomButton(
          isLoading: _controller.isLoading.value,
          label: 'Submit',
          onPressed: _controller.submitForm,
        ),
      ),
    );
  }

  Widget _buildPaymentSwitch() {
    return Obx(() {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final isPaymentDone = _controller.isPaymentDone.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _PaymentIcon(isPaymentDone: isPaymentDone),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentStatus(isPaymentDone: isPaymentDone, theme: theme),
            ),
            _PaymentSwitch(
              isPaymentDone: isPaymentDone,
              onChanged: (value) => _controller.isPaymentDone.value = value,
            ),
          ],
        ),
      );
    });
  }
}

class _PaymentIcon extends StatelessWidget {
  final bool isPaymentDone;

  const _PaymentIcon({required this.isPaymentDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isPaymentDone
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPaymentDone ? Icons.payment : Icons.payment_outlined,
        color: isPaymentDone ? Colors.green[600] : Colors.orange[600],
        size: 20,
      ),
    );
  }
}

class _PaymentStatus extends StatelessWidget {
  final bool isPaymentDone;
  final ThemeData theme;

  const _PaymentStatus({required this.isPaymentDone, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Status',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          isPaymentDone ? 'Paid' : 'Pending',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isPaymentDone ? Colors.green[600] : Colors.orange[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PaymentSwitch extends StatelessWidget {
  final bool isPaymentDone;
  final ValueChanged<bool> onChanged;

  const _PaymentSwitch({required this.isPaymentDone, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: isPaymentDone,
      onChanged: onChanged,
      activeColor: Colors.green[600],
      activeTrackColor: Colors.green.withOpacity(0.3),
      inactiveThumbColor: Colors.grey[400],
      inactiveTrackColor: Colors.grey.withOpacity(0.3),
    );
  }
}

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFile = selectedFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
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
              color: colorScheme.surface,
              border: Border.all(
                color:
                    hasFile
                        ? Colors.green
                        : colorScheme.outline.withOpacity(0.5),
                width: hasFile ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilePreview(
                    selectedFile: selectedFile,
                    icon: icon,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasFile ? 'File selected' : placeholder,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            hasFile
                                ? Colors.green[700]
                                : colorScheme.onSurface.withOpacity(0.6),
                        fontWeight:
                            hasFile ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  _FileStatus(
                    isLoading: isLoading,
                    hasFile: hasFile,
                    icon: icon,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilePreview extends StatelessWidget {
  final dynamic selectedFile;
  final IconData icon;
  final ColorScheme colorScheme;

  const _FilePreview({
    required this.selectedFile,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedFile == null) {
      return Icon(
        icon,
        color: colorScheme.onSurface.withOpacity(0.4),
        size: 24,
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          selectedFile,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Icon(
                Icons.image,
                color: colorScheme.onSurface.withOpacity(0.4),
                size: 16,
              ),
        ),
      ),
    );
  }
}

class _FileStatus extends StatelessWidget {
  final bool isLoading;
  final bool hasFile;
  final IconData icon;
  final ColorScheme colorScheme;

  const _FileStatus({
    required this.isLoading,
    required this.hasFile,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.primary,
        ),
      );
    }

    return Icon(
      hasFile ? Icons.check_circle : icon,
      color: hasFile ? Colors.green : colorScheme.primary,
      size: 24,
    );
  }
}

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDatePicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                ),
                Icon(
                  Icons.calendar_today,
                  color: colorScheme.primary,
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
