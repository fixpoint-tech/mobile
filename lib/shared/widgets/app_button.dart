import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF50B6DC);
const kNeutralGray = Color(0xFF7B7B7B);

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
    this.width,
    this.height = 48,
    this.radius = 20,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final double? width;
  final double height;
  final double radius;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isBusy ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return kPrimaryColor.withOpacity(0.50);
          }
          if (states.contains(MaterialState.pressed)) {
            return kPrimaryColor.withOpacity(0.90);
          }
          return kPrimaryColor;
        }),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.06)),
        shadowColor: MaterialStateProperty.all(kPrimaryColor.withOpacity(0.12)),
        elevation: MaterialStateProperty.all(2),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        fixedSize: MaterialStateProperty.all(Size.fromHeight(height)),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      child: isBusy
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, height: height, child: button);
    }
    if (width != null) {
      return SizedBox(width: width, height: height, child: button);
    }
    return SizedBox(height: height, child: button);
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
    this.width,
    this.height = 48,
    this.radius = 20,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        foregroundColor: MaterialStateProperty.all(kNeutralGray),
        side: MaterialStateProperty.all(
          const BorderSide(color: kNeutralGray, width: 1.5),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        fixedSize: MaterialStateProperty.all(Size.fromHeight(height)),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: kNeutralGray,
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, height: height, child: button);
    }
    if (width != null) {
      return SizedBox(width: width, height: height, child: button);
    }
    return SizedBox(height: height, child: button);
  }
}
