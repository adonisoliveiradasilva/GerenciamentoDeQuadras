import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../quadras/quadras_page.dart';
import '../clientes/clientes_page.dart';
import '../funcionarios/funcionarios_page.dart';
import '../relatorios/relatorios_page.dart';
import '../../auth/login_page.dart'; 

class ManagerLayout extends StatefulWidget {
  const ManagerLayout({super.key});

  @override
  State<ManagerLayout> createState() => _ManagerLayoutState();
}

class _ManagerLayoutState extends State<ManagerLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const QuadrasPage(),
    const ClientesPage(),
    const FuncionariosPage(),
    const RelatoriosPage(),
  ];

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do sistema', style: TextStyle(color: Color(0xFF0D253F), fontWeight: FontWeight.bold)),
        content: const Text('Tem certeza que deseja encerrar sua sessão?', style: TextStyle(color: Colors.blueGrey)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.blueGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false, 
              );
            },
            child: const Text('Sair', style: TextStyle(color: Color(0xFFA65C5C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: _pages[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E65D0),
        unselectedItemColor: const Color(0xFF7A8FA6),
        onTap: (index) {
          if (index == 4) {
            _confirmarLogout();
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: FaIcon(FontAwesomeIcons.tableTennisPaddleBall)),
            label: 'Quadras',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: FaIcon(FontAwesomeIcons.solidUser)),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: FaIcon(FontAwesomeIcons.userTie)),
            label: 'Funcionários',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: FaIcon(FontAwesomeIcons.chartSimple)),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: Color(0xFFA65C5C))),
            label: 'Sair',
          ),
        ],
      ),
    );
  }
}