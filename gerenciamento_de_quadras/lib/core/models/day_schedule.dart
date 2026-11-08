import 'package:flutter/material.dart';

class TimeInterval {
  TimeOfDay? start;
  TimeOfDay? end;

  TimeInterval({this.start, this.end});

  Map<String, String?> toJson() {
    return {
      "start": start != null ? "${start!.hour.toString().padLeft(2, '0')}:${start!.minute.toString().padLeft(2, '0')}" : null,
      "end": end != null ? "${end!.hour.toString().padLeft(2, '0')}:${end!.minute.toString().padLeft(2, '0')}" : null,
    };
  }
}

class DaySchedule {
  final String name;
  bool isSelected;
  List<TimeInterval> intervals;

  DaySchedule({
    required this.name,
    this.isSelected = false,
    List<TimeInterval>? intervals,
  }) : intervals = intervals ?? [TimeInterval(start: const TimeOfDay(hour: 8, minute: 0), end: const TimeOfDay(hour: 12, minute: 0))];
}