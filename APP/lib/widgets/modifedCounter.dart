import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiggerCounter extends StatefulWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final bool locked;

  const BiggerCounter({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    this.locked = false,
  }) : super(key: key);

  @override
  State<BiggerCounter> createState() => _BiggerCounterState();
}

class _BiggerCounterState extends State<BiggerCounter> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant BiggerCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  void _updateValue(int delta) {
    if (widget.locked) return;

    HapticFeedback.lightImpact();
    int newValue = math.max(0, math.min(widget.value + delta, widget.max));
    widget.onChanged(newValue);
  }

  void _submitText(String text) {
    int? parsed = int.tryParse(text);
    if (parsed == null) return;

    parsed = math.max(0, math.min(parsed, widget.max));
    widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 75;
    const double fontSize = 28;

    // Helper to create a button
    Widget buildButton(String label, Color color, VoidCallback? onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              color: onTap == null ? Colors.grey : color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Font'),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        Text(
          widget.label,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
              fontFamily: 'Font'),
        ),
        const SizedBox(height: 6),

        /// EDITABLE VALUE
        TextField(
          controller: _controller,
          readOnly: widget.locked,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Font'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onSubmitted: _submitText,
          onEditingComplete: () => _submitText(_controller.text),
        ),
        const SizedBox(height: 12),

        /// ROW: -1 and +1
        Row(
          children: [
            buildButton(
              "-1",
              Colors.red,
              widget.locked || widget.value == 0
                  ? null
                  : () => _updateValue(-1),
            ),
            const SizedBox(width: 10),
            buildButton(
              "+1",
              Colors.blue,
              widget.locked || widget.value >= widget.max
                  ? null
                  : () => _updateValue(1),
            ),
          ],
        ),
        const SizedBox(height: 10),

        /// ROW: -5 and +5
        Row(
          children: [
            buildButton(
              "-5",
              Colors.red,
              widget.locked || widget.value == 0
                  ? null
                  : () => _updateValue(-5),
            ),
            const SizedBox(width: 10),
            buildButton(
              "+5",
              Colors.blue,
              widget.locked || widget.value >= widget.max
                  ? null
                  : () => _updateValue(5),
            ),
          ],
        ),
      ],
    );
  }
}
