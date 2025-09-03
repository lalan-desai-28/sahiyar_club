import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/controllers/theme_controller.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/utils/hive_database.dart';
import 'package:sahiyar_club/repositories/pass_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController _themeController = Get.find<ThemeController>();
  final PassRepository _passRepository = PassRepository();
  final RxBool isExporting = false.obs;
  final RxBool inclusiveSubAgents = false.obs;

  @override
  void initState() {
    super.initState();
    _loadInclusiveSubAgentsPreference();
  }

  Future<void> _loadInclusiveSubAgentsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    inclusiveSubAgents.value = prefs.getBool('inclusiveSubAgents') ?? true;
  }

  Future<void> _saveInclusiveSubAgentsPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('inclusiveSubAgents', value);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppStatics.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildUserInfo(),
          const SizedBox(height: 24),
          _buildSettings(),
          if (user?.role == 'agent') ...[
            const SizedBox(height: 24),
            _buildAgentSection(),
          ],
          const SizedBox(height: 24),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildLogoutSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        _buildInfoTile(
          icon: Icons.person_outline,
          title: 'Full Name',
          subtitle:
              '${AppStatics.currentUser?.firstName ?? ""} ${AppStatics.currentUser?.lastName ?? ""}',
          color: Colors.blue[600]!,
        ),
        _buildInfoTile(
          icon: Icons.phone_outlined,
          title: 'Mobile Number',
          subtitle: AppStatics.currentUser?.mobile ?? "No Mobile",
          color: Colors.green[600]!,
        ),
        _buildInfoTile(
          icon: Icons.email_outlined,
          title: 'Email Address',
          subtitle: AppStatics.currentUser?.email ?? "No Email",
          color: Colors.purple[600]!,
        ),
        _buildInfoTile(
          icon: Icons.numbers_outlined,
          title: 'Agent Code',
          subtitle: AppStatics.currentUser?.agentCode ?? "No Agent Code",
          color: Colors.orange[600]!,
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return _buildSection(
      title: 'Preferences',
      icon: Icons.settings,
      children: [_buildThemeToggle(), _buildInclusiveSubAgentsToggle()],
    );
  }

  Widget _buildThemeToggle() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  _themeController.isDarkMode.value
                      ? Colors.indigo[100]
                      : Colors.amber[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _themeController.isDarkMode.value
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color:
                  _themeController.isDarkMode.value
                      ? Colors.indigo[600]
                      : Colors.amber[600],
              size: 24,
            ),
          ),
          title: Text(
            'Dark Mode',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            _themeController.isDarkMode.value ? 'Enabled' : 'Disabled',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Switch(
            value: _themeController.isDarkMode.value,
            onChanged: (value) => _themeController.toggleTheme(),
            activeColor: Colors.amber,
          ),
        ),
      ),
    );
  }

  Widget _buildInclusiveSubAgentsToggle() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              inclusiveSubAgents.value ? Icons.group : Icons.person,
              color: Colors.teal[600],
              size: 24,
            ),
          ),
          title: Text(
            'Include Sub Agents',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            inclusiveSubAgents.value
                ? 'Show all passes including sub agents in dashboard screen.'
                : 'Show only your passes in dashboard screen.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Checkbox(
            value: inclusiveSubAgents.value,
            onChanged: (value) {
              inclusiveSubAgents.value = value ?? false;
              _saveInclusiveSubAgentsPreference(inclusiveSubAgents.value);
            },
            activeColor: Colors.teal[600],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentSection() {
    return _buildSection(
      title: 'Agent Tools',
      icon: Icons.work,
      children: [
        _buildActionTile(
          icon: Icons.people_outline,
          title: 'Sub Agents',
          subtitle: 'Manage your sub agents',
          color: Colors.teal[600]!,
          onTap: () => Get.toNamed(AppRoutes.SUB_AGENTS_LIST),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: 'Data & Reports',
      icon: Icons.analytics,
      children: [
        Obx(
          () => _buildActionTile(
            icon: Icons.download,
            title: 'Export Passes',
            subtitle:
                isExporting.value
                    ? 'Exporting passes data...'
                    : 'Download all passes in Excel',
            color: Colors.cyan[600]!,
            onTap: isExporting.value ? null : _exportPassesCsv,
            isLoading: isExporting.value,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return _buildSection(
      title: 'Account',
      icon: Icons.account_circle,
      children: [
        _buildActionTile(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          color: Colors.red[600]!,
          onTap: _showLogoutDialog,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.amber[700], size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              isLoading
                  ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                  : Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color:
                onTap == null
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                    : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing:
            isLoading
                ? null
                : Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(
                    onTap == null ? 0.3 : 0.5,
                  ),
                  size: 16,
                ),
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }

  Future<void> _exportPassesCsv() async {
    try {
      isExporting.value = true;

      // Handle permissions based on platform and Android version
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // For Android 13+ (API 33+), we need different permissions
        if (sdkInt >= 33) {
          // Android 13+ uses granular media permissions
          var status = await Permission.photos.request();
          if (!status.isGranted) {
            status = await Permission.manageExternalStorage.request();
            if (!status.isGranted) {
              SnackbarUtil.showErrorSnackbar(
                title: 'Permission Denied',
                message:
                    'Storage permission is required to save files to Downloads.',
              );
              return;
            }
          }
        } else if (sdkInt >= 30) {
          // Android 11-12 (API 30-32)
          var status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              SnackbarUtil.showErrorSnackbar(
                title: 'Permission Denied',
                message:
                    'Storage permission is required to save files to Downloads.',
              );
              return;
            }
          }
        } else {
          // Android 10 and below (API <= 29)
          var status = await Permission.storage.request();
          if (!status.isGranted) {
            SnackbarUtil.showErrorSnackbar(
              title: 'Permission Denied',
              message:
                  'Storage permission is required to save files to Downloads.',
            );
            return;
          }
        }
      }

      final response = await _passRepository.dioClient.get(
        '/passes/export',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;

        Directory? downloadDir;
        String dirType = '';

        if (Platform.isAndroid) {
          try {
            // Try to get external storage Downloads directory
            downloadDir = Directory('/storage/emulated/0/Download');
            if (!await downloadDir.exists()) {
              // Fallback to getDownloadsDirectory()
              downloadDir = await getDownloadsDirectory();
              dirType = 'App Downloads';
            } else {
              dirType = 'Downloads';
            }
          } catch (e) {
            // Final fallback to external storage directory
            final externalDir = await getExternalStorageDirectory();
            downloadDir = Directory('${externalDir?.path}/Download');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
            dirType = 'Downloads';
          }
        } else if (Platform.isIOS) {
          // iOS: Use Documents directory as Downloads concept doesn't exist
          downloadDir = await getApplicationDocumentsDirectory();
          dirType = 'Files App';
        }

        if (downloadDir == null) {
          SnackbarUtil.showErrorSnackbar(
            title: 'Export Error',
            message: 'Unable to access storage directory',
          );
          return;
        }

        final dateTime = DateTime.now();
        final formattedDateTime =
            '${dateTime.day.toString().padLeft(2, '0')}-'
            '${dateTime.month.toString().padLeft(2, '0')}-'
            '${dateTime.year}_'
            '${dateTime.hour.toString().padLeft(2, '0')}-'
            '${dateTime.minute.toString().padLeft(2, '0')}-'
            '${dateTime.second.toString().padLeft(2, '0')}';

        final fileName = 'sahiyar_passes_$formattedDateTime.csv';
        final file = File('${downloadDir.path}/$fileName');

        await file.writeAsBytes(bytes);

        SnackbarUtil.showSuccessSnackbar(
          title: 'Export Successful',
          message:
              Platform.isIOS
                  ? 'CSV saved to Files App: $fileName'
                  : 'CSV saved to $dirType: $fileName',
        );

        print('CSV file exported successfully: ${file.path}');
      } else {
        SnackbarUtil.showErrorSnackbar(
          title: 'Export Failed',
          message: 'Server error: ${response.statusMessage ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Export Error',
        message: 'Failed to export CSV: ${e.toString()}',
      );
      print('Error exporting CSV file: $e');
    } finally {
      isExporting.value = false;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.red[600]),
                const SizedBox(width: 12),
                const Text('Logout'),
              ],
            ),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.find<HiveDatabase>().removeUser();
                  Get.offAllNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
