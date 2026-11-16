import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/services/auth_service.dart';
import '../../core/widgets/atoms/custom_text_field.dart';
import '../../core/widgets/atoms/primary_button.dart';
import '../../core/widgets/templates/auth_template.dart';
import 'login_page.dart';
import 'status_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    if (nome.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha nome e email.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final mensagem = await _authService.cadastrarCliente(
        nome: nome,
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
      title: 'Bem vindo',
      subtitle: 'Preencha as informações abaixo para criar sua conta',
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
            controller: _nomeController,
            label: 'Nome',
            prefixIcon: const FaIcon(
              FontAwesomeIcons.solidUser,
              size: 20,
              color: Colors.blueGrey,
            ),
          ),
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
            text: 'Enviar email para criar senha',
            icon: const FaIcon(
              FontAwesomeIcons.envelope,
              size: 18,
              color: Colors.white,
            ),
            isLoading: _isLoading,
            onPressed: _cadastrar,
          ),
        ],
      ),
    );
  }
}
