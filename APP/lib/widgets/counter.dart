import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Counter extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final bool locked;

  Counter({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: locked,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            controller: TextEditingController(text: '$value'),
            onSubmitted: (newValue) {
              int? newIntValue = int.tryParse(newValue);
              if (newIntValue != null) {
                onChanged(math.max(math.min(newIntValue, max), 0));
              }
            },
          ),
        ),
        SizedBox(width: 8),
        IconButton.filled(
          style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                side: BorderSide(style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              fixedSize: Size(50, 50)),
          icon: Icon(Icons.remove),
          onPressed: value > 0
              ? locked
                  ? null
                  : () {
                      onChanged(value - 1);
                      HapticFeedback.lightImpact();
                    }
              : null,
        ),
        SizedBox(width: 8),
        IconButton.filled(
          style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                side: BorderSide(style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              fixedSize: Size(50, 50)),
          icon: Icon(Icons.add),
          onPressed: value < max
              ? locked
                  ? null
                  : () {
                      onChanged(value + 1);
                      HapticFeedback.lightImpact();
                    }
              : null,
        ),
      ],
    );
  }
}
