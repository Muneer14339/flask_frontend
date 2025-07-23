import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PasswordRequirements extends StatelessWidget {
  final bool hasLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecialChar;

  const PasswordRequirements({
    super.key,
    required this.hasLength,
    required this.hasUppercase,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('At least 8 characters', hasLength),
          _buildRequirement('Contains uppercase letter', hasUppercase),
          _buildRequirement('Contains number', hasNumber),
          _buildRequirement('Contains special character', hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isValid ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? AppColors.success : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}