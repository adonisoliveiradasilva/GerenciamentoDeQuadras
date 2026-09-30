import 'package:flutter/material.dart';

class AuthTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String? footerText;
  final String? footerActionText;
  final VoidCallback? onFooterTap;

  const AuthTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footerText,
    this.footerActionText,
    this.onFooterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/logo.png', height: 120), 
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF0D253F)
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              child, 

              const SizedBox(height: 40),
              if (footerText != null && footerActionText != null) ...[
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: onFooterTap,
                  child: RichText(
                    text: TextSpan(
                      text: footerText,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: footerActionText,
                          style: const TextStyle(color: Color(0xFF1E65D0), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}