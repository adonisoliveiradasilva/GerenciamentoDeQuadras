import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/atoms/custom_text_field.dart';
import '../../core/widgets/atoms/primary_button.dart';
import '../../core/widgets/templates/auth_template.dart';
import 'status_page.dart';
import 'login_page.dart';

class EsqueceuSenhaPage extends StatelessWidget {
  const EsqueceuSenhaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: 'Esqueceu a senha',
      subtitle: 'Preencha as informações do seu email abaixo',
      footerText: 'Já possui uma conta? ',
      footerActionText: 'Login',
      onFooterTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      },
      child: Column(
        children: [
          CustomTextField(
            label: 'Email',
            prefixIcon: FaIcon(FontAwesomeIcons.envelope, size: 20, color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Enviar email para criar nova senha',
            icon: FaIcon(FontAwesomeIcons.envelope, size: 18, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StatusPage()));
            },
          ),
        ],
      ),
    );
  }
}