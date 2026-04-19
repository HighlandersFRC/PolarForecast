import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PercentCounter extends StatefulWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final bool locked;

  const PercentCounter({
    Key? key,
    required this.label,
    required this.value,
    this.max = 100000000000000000,
    required this.onChanged,
    this.locked = false,
  }) : super(key: key);

  @override
  State<PercentCounter> createState() => _PercentCounterState();
}

class _PercentCounterState extends State<PercentCounter> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant PercentCounter oldWidget) {
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
    const double buttonHeight = 50;
    const double fontSize = 32;

    final bool atMax = widget.value >= widget.max;
    final bool disabled = widget.locked;

    Color primary = Colors.blue;

    // buildButton no longer wraps itself in Expanded —
    // callers decide how to size it (Expanded inside a Row, or SizedBox, etc.)
    Widget buildButton({
      required String label,
      required Color color,
      required VoidCallback? onTap,
    }) {
      final bool isDisabled = onTap == null;

      return Material(
        color:
            isDisabled ? Colors.grey.withOpacity(0.2) : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            height: buttonHeight,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDisabled ? Colors.grey : color,
                fontFamily: 'Font',
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primary,
                fontFamily: 'Font',
              ),
            ),
            const SizedBox(height: 12),

            /// VALUE FIELD
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                readOnly: disabled,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Font',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  suffixText: '%',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
                onSubmitted: _submitText,
                onEditingComplete: () => _submitText(_controller.text),
              ),
            ),

            const SizedBox(height: 18),

            /// BUTTONS — all in one Column of Rows so every button
            /// lives inside a Row and can safely use Expanded.
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: -10% spanning full width
                Row(
                  children: [
                    Expanded(
                      child: buildButton(
                        label: '-10%',
                        color: Colors.red,
                        onTap: disabled || widget.value <= 0
                            ? null
                            : () => _updateValue(-10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Bottom row: +10%, +60%, +80%, +100%
                Row(
                  children: [
                    Expanded(
                      child: buildButton(
                        label: '+10%',
                        color: primary,
                        onTap:
                            disabled || atMax ? null : () => _updateValue(10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildButton(
                        label: '+60%',
                        color: primary,
                        onTap:
                            disabled || atMax ? null : () => _updateValue(60),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildButton(
                        label: '+80%',
                        color: primary,
                        onTap:
                            disabled || atMax ? null : () => _updateValue(80),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildButton(
                        label: '+100%',
                        color: primary,
                        onTap:
                            disabled || atMax ? null : () => _updateValue(100),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
