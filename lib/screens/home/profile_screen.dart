import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/controllers/theme_controller.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/utils/hive_database.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController _themeController = Get.find<ThemeController>();

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
      children: [_buildThemeToggle()],
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
    required VoidCallback onTap,
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
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
