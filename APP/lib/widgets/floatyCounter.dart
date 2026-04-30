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

  void _manualSubmit(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null) {
      setState(() {
        _currentValue = parsed.clamp(widget.min, widget.max);
        _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
      });
      widget.onChanged(_currentValue);
    } else {
      _controller.text = _currentValue.toStringAsFixed(widget.decimalPlaces);
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
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              readOnly: widget.locked,
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: '${widget.min} – ${widget.max}',
                labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              onChanged: _manualSubmit,
              onSubmitted: _manualSubmit,
              onEditingComplete: () => _manualSubmit(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}
