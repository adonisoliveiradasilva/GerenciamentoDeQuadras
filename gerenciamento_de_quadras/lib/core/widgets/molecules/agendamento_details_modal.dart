import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../atoms/primary_button.dart';

class AgendamentoDetailsModal extends StatelessWidget {
  final String cliente;
  final String data;
  final String horario;
  final String quadra;

  const AgendamentoDetailsModal({
    super.key,
    required this.cliente,
    required this.data,
    required this.horario,
    required this.quadra,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Detalhes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const FaIcon(FontAwesomeIcons.circleXmark, color: Colors.blueGrey, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(FontAwesomeIcons.solidUser, 'Cliente', cliente),
            const Divider(height: 24, color: Colors.black12),
            _buildInfoRow(FontAwesomeIcons.calendarDay, 'Data', data),
            const Divider(height: 24, color: Colors.black12),
            _buildInfoRow(FontAwesomeIcons.clock, 'Horário', horario),
            const Divider(height: 24, color: Colors.black12),
            _buildInfoRow(FontAwesomeIcons.tableTennisPaddleBall, 'Quadra', quadra),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Fechar',
              icon: const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(FaIconData icon, String label, String value) {
    return Row(
      children: [
        FaIcon(icon, color: const Color(0xFF1E65D0), size: 16),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
            Text(value, style: const TextStyle(color: Color(0xFF0D253F), fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}