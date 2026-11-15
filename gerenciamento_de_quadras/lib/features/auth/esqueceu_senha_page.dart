import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/services/auth_service.dart';
import '../../core/widgets/atoms/custom_text_field.dart';
import '../../core/widgets/atoms/primary_button.dart';
import '../../core/widgets/templates/auth_template.dart';
import 'login_page.dart';
import 'status_page.dart';

class EsqueceuSenhaPage extends StatefulWidget {
  const EsqueceuSenhaPage({super.key});

  @override
  State<EsqueceuSenhaPage> createState() => _EsqueceuSenhaPageState();
}

class _EsqueceuSenhaPageState extends State<EsqueceuSenhaPage> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Preencha o email.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final mensagem = await _authService.solicitarRedefinicaoSenha(
        email: email,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StatusPage(mensagem: mensagem)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: 'Esqueceu a senha',
      subtitle: 'Preencha as informações do seu email abaixo',
      footerText: 'Já possui uma conta? ',
      footerActionText: 'Login',
      onFooterTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: const FaIcon(
              FontAwesomeIcons.envelope,
              size: 20,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Enviar email para criar nova senha',
            icon: const FaIcon(
              FontAwesomeIcons.envelope,
              size: 18,
              color: Colors.white,
            ),
            isLoading: _isLoading,
            onPressed: _enviarEmail,
          ),
        ],
      ),
    );
  }
}
