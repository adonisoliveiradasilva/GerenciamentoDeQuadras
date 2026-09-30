import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/atoms/custom_text_field.dart';
import '../../core/widgets/atoms/primary_button.dart';
import '../../core/widgets/templates/auth_template.dart';
import 'cadastro_page.dart';
import 'esqueceu_senha_page.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: 'Bem vindo',
      subtitle: 'Acesse sua conta para agendar ou gerenciar quadras',
      footerText: 'Novo jogador? ',
      footerActionText: 'Cadastre-se',
      onFooterTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroPage()));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomTextField(
            label: 'Email',
            prefixIcon: FaIcon(FontAwesomeIcons.envelope, size: 20, color: Colors.blueGrey),
          ),
          CustomTextField(
            label: 'Senha',
            prefixIcon: FaIcon(FontAwesomeIcons.lock, size: 20, color: Colors.blueGrey),
            isPassword: true,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EsqueceuSenhaPage()));
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text('Esqueceu a senha', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ),
          ),
          PrimaryButton(
            text: 'Entrar',
            icon: FaIcon(FontAwesomeIcons.arrowRight, size: 18, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}