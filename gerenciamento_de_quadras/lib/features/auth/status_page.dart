import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/widgets/atoms/primary_button.dart';
import '../../core/widgets/templates/auth_template.dart';
import 'login_page.dart';

class StatusPage extends StatelessWidget {
  final String? mensagem;

  const StatusPage({super.key, this.mensagem});

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: 'Email enviado!',
      subtitle:
          mensagem ?? 'Complete seu cadastro seguindo as instruções do email',
      child: PrimaryButton(
        text: 'Login',
        icon: const FaIcon(
          FontAwesomeIcons.arrowRight,
          size: 18,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        },
      ),
    );
  }
}
