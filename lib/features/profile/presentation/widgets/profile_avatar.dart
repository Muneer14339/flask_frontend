import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.size = 60,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.borderColorDark : AppColors.borderColor,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? Image.network(
            avatarUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildInitials(isDark),
          )
              : _buildInitials(isDark),
        ),
      ),
    );
  }

  Widget _buildInitials(bool isDark) {
    final initials = fullName.split(' ').map((name) => name[0]).take(2).join();

    return Container(
      color: isDark ? AppColors.primaryDark : AppColors.primary,
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}