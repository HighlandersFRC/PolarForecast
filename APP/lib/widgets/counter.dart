import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Counter extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  Counter({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: '),
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: value > 0
              ? () {
                  onChanged(value - 1);
                  HapticFeedback.lightImpact();
                }
              : null,
        ),
        Text('$value'),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: value < max
              ? () {
                  onChanged(value + 1);
                  HapticFeedback.lightImpact();
                }
              : null,
        ),
      ],
    );
  }
}
