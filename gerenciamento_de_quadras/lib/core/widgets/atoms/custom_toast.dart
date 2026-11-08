import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomToast {
  static void showSuccess(BuildContext context, String message) {
    _show(
      context, 
      message, 
      const Color(0xFF2E7D32), 
      const FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 20),
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context, 
      message, 
      const Color(0xFFA65C5C), 
      const FaIcon(FontAwesomeIcons.circleXmark, color: Colors.white, size: 20),
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context, 
      message, 
      const Color(0xFFF57F17), 
      const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white, size: 20),
    );
  }

  static void _show(BuildContext context, String message, Color color, Widget icon) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -50.0, end: 0.0), 
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                // Efeito de fade-in 
                child: Opacity(
                  opacity: (1 - (value / -50)).clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}