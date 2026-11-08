import 'package:flutter/material.dart';
import '../../models/day_schedule.dart';

class ScheduleCard extends StatelessWidget {
  final DaySchedule daySchedule;
  final VoidCallback onAddInterval;
  final Function(int, bool, TimeOfDay) onTimeChanged;
  final Function(int) onRemoveInterval;

  const ScheduleCard({
    super.key,
    required this.daySchedule,
    required this.onAddInterval,
    required this.onTimeChanged,
    required this.onRemoveInterval,
  });

  Widget _buildTimeField(BuildContext context, String label, TimeOfDay? time, ValueChanged<TimeOfDay> onChanged) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final selected = await showTimePicker(
            context: context,
            initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
          );
          if (selected != null) onChanged(selected);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}h' : label,
            style: TextStyle(color: time != null ? Colors.blueGrey : Colors.grey.shade400, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.blueGrey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(8, -26),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFF0F4FA),
              child: Text(daySchedule.name, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
            ),
          ),
          
          ...daySchedule.intervals.asMap().entries.map((entry) {
            int index = entry.key;
            TimeInterval interval = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  _buildTimeField(context, 'Início', interval.start, (t) => onTimeChanged(index, true, t)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('-', style: TextStyle(color: Colors.blueGrey)),
                  ),
                  _buildTimeField(context, 'Fim', interval.end, (t) => onTimeChanged(index, false, t)),
                  
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFA65C5C)),
                    onPressed: () => onRemoveInterval(index),
                  )
                ],
              ),
            );
          }),

          GestureDetector(
            onTap: onAddInterval,
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.blueGrey.shade200)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: const [
                      Text('Novo intervalo', style: TextStyle(color: Color(0xFF1E65D0), fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.add_circle, color: Color(0xFF1E65D0), size: 16),
                    ],
                  ),
                ),
                Expanded(child: Divider(color: Colors.blueGrey.shade200)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}