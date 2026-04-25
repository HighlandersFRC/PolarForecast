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
    this.max = 1000,
    required this.onChanged,
    this.locked = false,
  }) : super(key: key);

  @override
  State<PercentCounter> createState() => _PercentCounterState();
}

class _PercentCounterState extends State<PercentCounter> {
  late TextEditingController _controller;
  late int _sanitizedValue;

  @override
  void initState() {
    super.initState();
    _sanitizedValue = _sanitizeValue(widget.value);
    _controller = TextEditingController(text: _sanitizedValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PercentCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _sanitizedValue = _sanitizeValue(widget.value);
      _controller.text = _sanitizedValue.toString();
    }
  }

  int _sanitizeValue(int value) {
    return value.clamp(0, widget.max);
  }

  void _updateValue(int delta) {
    if (widget.locked) return;
    HapticFeedback.lightImpact();
    _sanitizedValue = (_sanitizedValue + delta).clamp(0, widget.max);
    widget.onChanged(_sanitizedValue);
    _controller.text = _sanitizedValue.toString();
  }

  void _submitText(String text) {
    int? parsed = int.tryParse(text);
    if (parsed == null) return;
    _sanitizedValue = parsed.clamp(0, widget.max);
    widget.onChanged(_sanitizedValue);
    _controller.text = _sanitizedValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 54;
    final bool atMax = widget.value >= widget.max;
    final bool disabled = widget.locked;

    // Modern Dark Theme Colors
    const Color cardBackground = Color(0xFF1A1A1A);
    const Color inputBackground = Color(0xFF2D2D2D);
    const Color accentColor = Colors.blue; // Indigo accent
    const Color textColor = Colors.white;
    const Color subTextColor = Colors.white70;

    Widget buildButton({
      required String label,
      required Color color,
      required VoidCallback? onTap,
    }) {
      final bool isDisabled = onTap == null;

      return Material(
        color: isDisabled
            ? Colors.white.withOpacity(0.05)
            : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: buttonHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDisabled ? Colors.transparent : color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.white24 : color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: subTextColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (widget.locked)
                    const Icon(Icons.lock_outline,
                        size: 16, color: Colors.orangeAccent),
                ],
              ),
              const SizedBox(height: 16),

              /// VALUE FIELD
              Container(
                decoration: BoxDecoration(
                  color: inputBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: TextField(
                  controller: _controller,
                  readOnly: disabled,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    suffixIcon: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('%',
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    suffixIconConstraints: const BoxConstraints(minWidth: 40),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  onSubmitted: _submitText,
                  onEditingComplete: () => _submitText(_controller.text),
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTONS
              Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: buildButton(
                          label: '+60%',
                          color: accentColor,
                          onTap:
                              disabled || atMax ? null : () => _updateValue(60),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildButton(
                          label: '+80%',
                          color: accentColor,
                          onTap:
                              disabled || atMax ? null : () => _updateValue(80),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: buildButton(
                          label: '+100%',
                          color: accentColor,
                          onTap: disabled || atMax
                              ? null
                              : () => _updateValue(100),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
