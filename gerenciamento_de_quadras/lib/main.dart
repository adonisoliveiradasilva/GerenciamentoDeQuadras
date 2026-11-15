import 'package:flutter/material.dart';

import 'core/services/auth_service.dart';
import 'features/auth/login_page.dart';
import 'features/client/layout/client_layout.dart';
import 'features/employee/layout/employee_layout.dart';
import 'features/manager/layout/manager_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciamento de Quadras',
      debugShowCheckedModeBanner: false,
      home: const VerificacaoSessaoPage(),
    );
  }
}

class VerificacaoSessaoPage extends StatefulWidget {
  const VerificacaoSessaoPage({super.key});

  @override
  State<VerificacaoSessaoPage> createState() => _VerificacaoSessaoPageState();
}

class _VerificacaoSessaoPageState extends State<VerificacaoSessaoPage> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final token = await _authService.obterToken();

    if (token == null || token.isEmpty) {
      _irPara(const LoginPage());
      return;
    }

    try {
      final usuario = await _authService.buscarUsuarioAtual();
      final perfil = usuario['perfil'];

      if (perfil == 'gerente') {
        _irPara(const ManagerLayout());
      } else if (perfil == 'funcionario') {
        _irPara(const EmployeeLayout());
      } else {
        _irPara(const ClientLayout());
      }
    } catch (_) {
      _irPara(const LoginPage());
    }
  }

  void _irPara(Widget pagina) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pagina),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
