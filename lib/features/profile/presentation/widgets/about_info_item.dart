import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AboutInfoItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isButton;
  final bool isLoading;
  final VoidCallback? onTap;

  const AboutInfoItem({
    super.key,
    required this.title,
    required this.value,
    this.isButton = false,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Text(
        value,
        style: TextStyle(
          color: isButton
              ? AppColors.primary
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          fontWeight: isButton ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      onTap: isButton ? onTap : null,
    );
  }
}