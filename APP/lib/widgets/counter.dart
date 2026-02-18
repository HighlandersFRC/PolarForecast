import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Counter extends StatefulWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final bool locked;

  const Counter({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    this.locked = false,
  }) : super(key: key);

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  Timer? _holdTimer;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(Counter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startHoldTimer(int step) {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
      _updateValue(step * 5); // increment/decrement by 5 while holding
    });
  }

  void _stopHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _updateValue(int delta) {
    HapticFeedback.lightImpact();
    int newValue = math.max(0, math.min(widget.value + delta, widget.max));
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: widget.locked,
            style: TextStyle(fontFamily: 'Font'),
            decoration: InputDecoration(
              floatingLabelStyle:
                  TextStyle(fontFamily: 'Font', color: Colors.blue),
              labelStyle: TextStyle(fontFamily: 'Font', color: Colors.blue),
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            controller: _controller,
            onSubmitted: (newValue) {
              int? newInt = int.tryParse(newValue);
              if (newInt != null) {
                widget.onChanged(math.max(0, math.min(newInt, widget.max)));
              }
            },
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: widget.locked || widget.value == 0
              ? null
              : () => _updateValue(-1),
          onLongPressStart: widget.locked || widget.value == 0
              ? null
              : (_) => _startHoldTimer(-1),
          onLongPressEnd: (_) => _stopHoldTimer(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: widget.value == 0 || widget.locked
                  ? Colors.grey
                  : Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove, color: Colors.white),
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: widget.locked || widget.value >= widget.max
              ? null
              : () => _updateValue(1),
          onLongPressStart: widget.locked || widget.value >= widget.max
              ? null
              : (_) => _startHoldTimer(1),
          onLongPressEnd: (_) => _stopHoldTimer(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: widget.value >= widget.max || widget.locked
                  ? Colors.grey
                  : Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
