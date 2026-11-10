import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gerenciamento_de_quadras/core/services/auth_service.dart';
import 'package:gerenciamento_de_quadras/features/client/layout/client_layout.dart';
import 'package:gerenciamento_de_quadras/features/employee/layout/employee_layout.dart';
import 'package:gerenciamento_de_quadras/features/manager/layout/manager_layout.dart';

import '../../core/widgets/atoms/custom_text_field.dart';
import '../../core/widgets/atoms/primary_button.dart';
import '../../core/widgets/templates/auth_template.dart';
import 'cadastro_page.dart';
import 'esqueceu_senha_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha email e senha.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final resposta = await _authService.login(email: email, senha: senha);
      final usuario = resposta['usuario'];
      final perfil = usuario?['perfil'];

      if (!mounted) return;

      Widget paginaDestino;
      if (perfil == 'GERENTE') {
        paginaDestino = const ManagerLayout();
      } else if (perfil == 'FUNCIONARIO') {
        paginaDestino = const EmployeeLayout();
      } else {
        paginaDestino = const ClientLayout();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => paginaDestino),
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
      subtitle: 'Acesse sua conta para agendar ou gerenciar quadras',
      footerText: 'Novo jogador? ',
      footerActionText: 'Cadastre-se',
      onFooterTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CadastroPage()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
          CustomTextField(
            controller: _senhaController,
            label: 'Senha',
            prefixIcon: const FaIcon(
              FontAwesomeIcons.lock,
              size: 20,
              color: Colors.blueGrey,
            ),
            isPassword: true,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EsqueceuSenhaPage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Esqueceu a senha',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ),
          PrimaryButton(
            text: _isLoading ? 'Carregando...' : 'Entrar',
            icon: _isLoading
                ? null
                : const FaIcon(
                    FontAwesomeIcons.arrowRight,
                    size: 18,
                    color: Colors.white,
                  ),
            onPressed: _isLoading ? () {} : _fazerLogin,
          ),
        ],
      ),
    );
  }
}
