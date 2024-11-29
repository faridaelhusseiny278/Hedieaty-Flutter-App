import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final Color color;

  FilterButton({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
