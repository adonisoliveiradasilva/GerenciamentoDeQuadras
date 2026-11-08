import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gerenciamento_de_quadras/features/manager/funcionarios/funcionarios_page.dart';
import 'package:gerenciamento_de_quadras/features/manager/quadras/quadras_page.dart';
import 'package:gerenciamento_de_quadras/features/manager/clientes/clientes_page.dart';
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
    const Center(child: Text("Página de Relatórios em construção")),
  ];

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
          setState(() {
            _selectedIndex = index;
          });
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
        ],
      ),
    );
  }
}