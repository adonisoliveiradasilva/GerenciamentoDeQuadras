import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/atoms/primary_button.dart';
import '../../core/widgets/templates/auth_template.dart';
import 'login_page.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: 'Email enviado!',
      subtitle: 'Complete seu cadastro seguindo as intruções do email',
      child: PrimaryButton(
        text: 'Login',
        icon: FaIcon(FontAwesomeIcons.arrowRight, size: 18, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        },
      ),
    );
  }
}