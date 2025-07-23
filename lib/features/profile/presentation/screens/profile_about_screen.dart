import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/about_info_item.dart';


class ProfileAboutScreen extends StatefulWidget {
  const ProfileAboutScreen({super.key});

  @override
  State<ProfileAboutScreen> createState() => _ProfileAboutScreenState();
}

class _ProfileAboutScreenState extends State<ProfileAboutScreen> {
  String _updateStatus = 'Check for Updates';
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Logo and Name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'RA',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    children: [
                      TextSpan(text: 'Rifle'),
                      TextSpan(
                        text: 'Axis',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App Information
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const AboutInfoItem(
                  title: 'Version',
                  value: '1.0.0',
                ),
                const Divider(height: 1),
                const AboutInfoItem(
                  title: 'Build Number',
                  value: '100',
                ),
                const Divider(height: 1),
                const AboutInfoItem(
                  title: 'Developer',
                  value: 'RifleAxis Team',
                ),
                const Divider(height: 1),
                AboutInfoItem(
                  title: 'Check for Updates',
                  value: _updateStatus,
                  isButton: true,
                  isLoading: _isChecking,
                  onTap: _checkForUpdates,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legal Information
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              children: [
                AboutInfoItem(
                  title: 'Privacy Policy',
                  value: 'View Privacy Policy',
                  isButton: true,
                ),
                Divider(height: 1),
                AboutInfoItem(
                  title: 'Terms of Service',
                  value: 'View Terms of Service',
                  isButton: true,
                ),
                Divider(height: 1),
                AboutInfoItem(
                  title: 'Open Source Licenses',
                  value: 'View Licenses',
                  isButton: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    setState(() {
      _isChecking = true;
      _updateStatus = 'Checking...';
    });

    // Simulate checking for updates
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _updateStatus = 'You have the latest version';
        });
      }
    });
  }
}