import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/constants/api_config_constants.dart';
import 'package:sahiyar_club/models/pass.dart';
import 'package:sahiyar_club/models/pass_full.dart';
import 'package:sahiyar_club/pages/update_pass_page.dart';
import 'package:sahiyar_club/repositories/pass_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class PassCard extends StatefulWidget {
  final Pass? pass;
  final FullPass? fullPass;
  final bool isEnabled;

  const PassCard({super.key, this.pass, this.fullPass, this.isEnabled = true});

  @override
  State<PassCard> createState() => _PassCardState();
}

class _PassCardState extends State<PassCard> {
  final PassRepository _passRepository = PassRepository();
  bool _paymentStatusUpdating = false;
  late dynamic _currentPass;

  @override
  void initState() {
    super.initState();
    _currentPass = widget.pass ?? widget.fullPass;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPass == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.isEnabled ? () => _navigateToUpdatePass() : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile Avatar
              _buildProfileAvatar(),
              const SizedBox(width: 16),

              // Pass Details
              Expanded(child: _buildPassDetails()),

              // Trailing - Switch or Loading or Status Badge
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final String imageUrl = _getImageUrl();

    return Hero(
      tag: "${_currentPass.sId ?? 'unknown'}_avatar",
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipOval(
          child:
              imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                  )
                  : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildPassDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(
          _getFullName(),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Pass Code
        if (_currentPass.passCode?.isNotEmpty == true) ...[
          Row(
            children: [
              Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _currentPass.passCode!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        // Mobile Number
        if (_currentPass.mobile?.isNotEmpty == true) ...[
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _currentPass.mobile!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        // Status
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    // Show loading indicator when payment status is updating
    if (_paymentStatusUpdating) {
      return _buildLoadingIndicator();
    }

    // Only show switch when status is "inrequest" or "pending"
    final status = _currentPass.status?.toLowerCase().trim();
    if (status == 'inrequest' || status == 'pending') {
      return _buildStatusToggle();
    }

    // Hide toggle for other statuses
    return const SizedBox.shrink();
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Updating...',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _updatePaymentStatus(bool isPaid) async {
    setState(() {
      _paymentStatusUpdating = true;
    });

    try {
      final response =
          isPaid
              ? await _passRepository.changeToPending(_currentPass.sId!)
              : await _passRepository.changeToInRequest(_currentPass.sId!);

      if (response.statusCode == 200) {
        // Update local pass state based on the action
        setState(() {
          if (isPaid) {
            // Payment done: change to pending
            _currentPass.status = 'pending';
            _currentPass.isAmountPaid = true;
          } else {
            // Payment not done: change to inrequest
            _currentPass.status = 'inrequest';
            _currentPass.isAmountPaid = false;
          }
        });
      } else {
        _showError('Failed to update payment status');
      }
    } catch (e) {
      _showError('Network error: ${e.toString()}');
    } finally {
      setState(() {
        _paymentStatusUpdating = false;
      });
    }
  }

  void _showError(String message) {
    SnackbarUtil.showErrorSnackbar(title: 'Error', message: message);
  }

  Widget _buildStatusToggle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: _isPaymentDone(),
          onChanged: (value) {
            _updatePaymentStatus(value);
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.grey,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          _isPaymentDone() ? 'Paid' : 'Pending',
          style: TextStyle(
            fontSize: 11,
            color: _isPaymentDone() ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getImageUrl() {
    final profilePhotoUrl = _currentPass.profilePhotoUrl;

    if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
      return '';
    }

    // Handle both relative and absolute URLs
    if (profilePhotoUrl.startsWith('http')) {
      return profilePhotoUrl;
    }

    return '${ApiConstants.imageBaseUrl}$profilePhotoUrl';
  }

  String _getFullName() {
    final fullName = _currentPass.fullName?.trim() ?? '';

    if (fullName.isEmpty) {
      return 'Unknown User';
    }

    return fullName;
  }

  String _getStatusText() {
    final status = _currentPass.status?.trim();
    if (status == null || status.isEmpty) {
      return 'Unknown Status';
    }

    // Capitalize first letter of each word
    return status
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }

  Color _getStatusColor() {
    final status = _currentPass.status?.toLowerCase().trim();
    switch (status) {
      case 'inrequest':
        return Colors.amber;
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'issued':
        return Colors.blue;
      case 'printed':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _isPaymentDone() {
    // Payment is done when status is "pending"
    // Payment is not done when status is "inrequest"
    return _currentPass.status?.toLowerCase().trim() == 'pending';
  }

  void _navigateToUpdatePass() {
    String passStatus = widget.fullPass?.status?.toLowerCase().trim() ?? "";
    if (passStatus != "inrequest" &&
        passStatus != "pending" &&
        passStatus != "rejectedforquery") {
      SnackbarUtil.showErrorSnackbar(
        title: 'Action Not Allowed',
        message: 'You can not update this pass at this time.',
      );
      return;
    }
    // Navigate with the appropriate pass type
    if (widget.fullPass != null) {
      Get.to(
        () => UpdatePassPage(fullPass: widget.fullPass!),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    }
  }
}
