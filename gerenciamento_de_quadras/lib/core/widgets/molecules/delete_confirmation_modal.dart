import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../atoms/primary_button.dart';

class DeleteConfirmationModal extends StatelessWidget {
  final String title;
  final String subtitle;
  final String itemName;

  const DeleteConfirmationModal({
    super.key,
    required this.title,
    required this.subtitle,
    required this.itemName,
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
                    Text(subtitle, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: const FaIcon(FontAwesomeIcons.circleXmark, color: Colors.blueGrey, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Deseja remover a seguinte quadra?', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
            const SizedBox(height: 16),
            Text(itemName, style: const TextStyle(color: Colors.blueGrey, fontSize: 22, fontWeight: FontWeight.w400)),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Cancelar ação',
              icon: const FaIcon(FontAwesomeIcons.circleArrowLeft, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context, false),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Remover',
              backgroundColor: const Color(0xFFA65C5C),
              icon: const FaIcon(FontAwesomeIcons.trashCan, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
  }
}