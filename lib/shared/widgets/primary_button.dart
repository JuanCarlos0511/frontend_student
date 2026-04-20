/// Reusable primary (red) button following brand guidelines.
import 'package:flutter/material.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primaryRed.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          shadowColor: AppTheme.primaryRed.withOpacity(0.4),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppTheme.white),
              )
            : Text(
                text,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3),
              ),
      ),
    );
  }
}
