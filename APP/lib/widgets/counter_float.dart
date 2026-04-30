import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleCounter extends StatefulWidget {
  final String label;
  final double value;
  final double max;
  final double min;
  final ValueChanged<double> onChanged;
  final bool locked;
  final double step;
  final int decimalPlaces;

  const DoubleCounter({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
    this.min = 0,
    required this.onChanged,
    this.locked = false,
    this.step = 0.5,
    this.decimalPlaces = 2,
  }) : super(key: key);

  @override
  _DoubleCounterState createState() => _DoubleCounterState();
}

class _DoubleCounterState extends State<DoubleCounter> {
  Timer? _holdTimer;
  late TextEditingController _controller;
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);
    _controller = TextEditingController(
      text: _currentValue.toStringAsFixed(widget.decimalPlaces),
    );
  }

  @override
  void didUpdateWidget(DoubleCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value.clamp(widget.min, widget.max);
      _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startHoldTimer(double step) {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _updateValue(step * 5);
    });
  }

  void _stopHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _updateValue(double delta) {
    HapticFeedback.lightImpact();
    final newValue = (widget.value + delta).clamp(widget.min, widget.max);
    final rounded =
        double.parse(newValue.toStringAsFixed(widget.decimalPlaces));
    widget.onChanged(rounded);
  }

  void _onTextChanged(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);
      if (clamped != parsed) {
        _controller.text = clamped.toStringAsFixed(widget.decimalPlaces);
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
      setState(() => _currentValue = clamped);
      widget.onChanged(_currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final atMin = widget.value <= widget.min;
    final atMax = widget.value >= widget.max;

    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: widget.locked,
            style: const TextStyle(fontFamily: 'Font'),
            decoration: InputDecoration(
              floatingLabelStyle:
                  const TextStyle(fontFamily: 'Font', color: Colors.blue),
              labelStyle:
                  const TextStyle(fontFamily: 'Font', color: Colors.blue),
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            textAlign: TextAlign.center,
            controller: _controller,
            onChanged: _onTextChanged,
            onSubmitted: _onTextChanged,
            onEditingComplete: () => _onTextChanged(_controller.text),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap:
              widget.locked || atMin ? null : () => _updateValue(-widget.step),
          onLongPressStart: widget.locked || atMin
              ? null
              : (_) => _startHoldTimer(-widget.step),
          onLongPressEnd: (_) => _stopHoldTimer(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: atMin || widget.locked ? Colors.grey : Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.remove, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap:
              widget.locked || atMax ? null : () => _updateValue(widget.step),
          onLongPressStart: widget.locked || atMax
              ? null
              : (_) => _startHoldTimer(widget.step),
          onLongPressEnd: (_) => _stopHoldTimer(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: atMax || widget.locked ? Colors.grey : Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
