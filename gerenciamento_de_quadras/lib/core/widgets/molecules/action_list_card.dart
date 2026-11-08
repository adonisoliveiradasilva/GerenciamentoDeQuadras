import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActionListCard extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onView;

  const ActionListCard({
    super.key,
    required this.title,
    this.onEdit,
    this.onDelete,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            margin: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E65D0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (onView != null)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.eye, color: Color(0xFF1E65D0), size: 18),
              onPressed: onView,
            ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_square, color: Color(0xFF1E65D0), size: 20),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFA65C5C), size: 20),
              onPressed: onDelete,
            ),
          if (onEdit == null && onDelete == null && onView == null)
            const SizedBox(height: 48, width: 16),
        ],
      ),
    );
  }
}