import 'package:flutter/material.dart';

class StatusData {
  final Color color;
  final IconData icon;
  final Color textColor;
  final bool hasBorder;

  StatusData({
    required this.color,
    required this.icon,
    required this.textColor,
    this.hasBorder = false,
  });
}