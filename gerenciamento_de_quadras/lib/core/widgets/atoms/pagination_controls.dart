import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final ValueChanged<int?> onItemsPerPageChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.onItemsPerPageChanged,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Itens por página: ', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
            DropdownButton<int>(
              value: itemsPerPage,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7A8FA6)),
              underline: Container(height: 1, color: Colors.blueGrey.shade200),
              style: const TextStyle(color: Color(0xFF1E65D0), fontWeight: FontWeight.bold, fontSize: 14),
              onChanged: onItemsPerPageChanged,
              items: const [
                DropdownMenuItem(value: 5, child: Text('5')),
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 20, child: Text('20')),
                DropdownMenuItem(value: 50, child: Text('50')),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_circle_left, color: Color(0xFF7A8FA6), size: 32),
              onPressed: onPrevious,
            ),
            Text(
              '$currentPage de $totalPages', 
              style: const TextStyle(color: Color(0xFF7A8FA6), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_circle_right, color: Color(0xFF7A8FA6), size: 32),
              onPressed: onNext,
            ),
          ],
        ),
      ],
    );
  }
}