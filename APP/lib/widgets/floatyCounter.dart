import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatyCounter extends StatefulWidget {
  final String label;
  final double value;
  final double max;
  final double min;
  final ValueChanged<double> onChanged;
  final int decimalPlaces;

  const FloatyCounter({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
    this.min = 10,
    required this.onChanged,
    this.decimalPlaces = 2,
  }) : super(key: key);

  @override
  State<FloatyCounter> createState() => _FloatyCounterState();
}

class _FloatyCounterState extends State<FloatyCounter> {
  late double _currentValue;
  late TextEditingController _controller;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = TextEditingController(
      text: _currentValue.toStringAsFixed(widget.decimalPlaces),
    );
  }

  @override
  void didUpdateWidget(FloatyCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
      _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
    }
  }

  void _toggleTimer() {
    if (_running) {
      // STOP
      HapticFeedback.selectionClick();
      _stopwatch.stop();
      _timer?.cancel();
      _running = false;

      setState(() {
        _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
      });
    } else {
      // START
      HapticFeedback.mediumImpact();
      _stopwatch.start();
      _running = true;

      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        final seconds = _stopwatch.elapsedMilliseconds / 1000;

        final clamped = seconds.clamp(widget.min, widget.max);

        setState(() {
          _currentValue = clamped;
        });

        widget.onChanged(_currentValue);

        if (seconds >= widget.max) {
          _toggleTimer();
        }
      });
    }

    setState(() {});
  }

  void _reset() {
    HapticFeedback.lightImpact();
    _stopwatch
      ..stop()
      ..reset();
    _timer?.cancel();

    setState(() {
      _running = false;
      _currentValue = widget.min;
      _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
    });

    widget.onChanged(_currentValue);
  }

  void _manualSubmit(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);

      setState(() {
        _currentValue = clamped;
        _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
      });

      widget.onChanged(_currentValue);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Label
            Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            /// Timer Display + Toggle Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentValue.toStringAsFixed(widget.decimalPlaces)} s',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _running ? Icons.timer : Icons.timer_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _toggleTimer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Reset + Manual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
                Row(
                  children: [
                    const Text(
                      'Manual:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.end,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          isDense: true,
                          suffixText: 's',
                        ),
                        onSubmitted: _manualSubmit,
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
