import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatyCounter extends StatefulWidget {
  final String label;
  final double value;
  final double max;
  final double min;
  final ValueChanged<double> onChanged;
  final int decimalPlaces;
  final bool locked;
  final double step;

  const FloatyCounter({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
    this.min = 0,
    required this.onChanged,
    this.decimalPlaces = 2,
    this.locked = false,
    this.step = 0.1,
  }) : super(key: key);

  @override
  State<FloatyCounter> createState() => _FloatyCounterState();
}

class _FloatyCounterState extends State<FloatyCounter> {
  late double _currentValue;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);
    _controller = TextEditingController(
      text: _currentValue.toStringAsFixed(widget.decimalPlaces),
    );
  }

  @override
  void didUpdateWidget(FloatyCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value.clamp(widget.min, widget.max);
      _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
    }
  }

  void _increment() {
    if (widget.locked) return;
    setState(() {
      _currentValue =
          (_currentValue + widget.step).clamp(widget.min, widget.max);
      _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
    });
    widget.onChanged(_currentValue);
  }

  void _decrement() {
    if (widget.locked) return;
    setState(() {
      _currentValue =
          (_currentValue - widget.step).clamp(widget.min, widget.max);
      _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
    });
    widget.onChanged(_currentValue);
  }

  void _manualSubmit(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null) {
      setState(() {
        _currentValue = parsed.clamp(widget.min, widget.max);
        _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
      });
      widget.onChanged(_currentValue);
    }
  }

  @override
  void dispose() {
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
            // Label
            Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            // Value Display + Increment/Decrement Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: _decrement,
                ),
                Text(
                  _currentValue.toStringAsFixed(widget.decimalPlaces),
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: _increment,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Slider for intuitive adjustment
            Slider(
              value: _currentValue,
              min: widget.min,
              max: widget.max,
              divisions: ((widget.max - widget.min) / widget.step).round(),
              label: _currentValue.toStringAsFixed(widget.decimalPlaces),
              onChanged: widget.locked
                  ? null
                  : (value) {
                      setState(() {
                        _currentValue = value;
                        _controller.text =
                            _currentValue.toStringAsFixed(widget.decimalPlaces);
                      });
                      widget.onChanged(_currentValue);
                    },
            ),

            // Manual Input
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Manual:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: TextField(
                    readOnly: widget.locked,
                    controller: _controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.end,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                    ),
                    onSubmitted: _manualSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
