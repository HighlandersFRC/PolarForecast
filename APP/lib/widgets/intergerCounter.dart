import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegerCounter extends StatefulWidget {
  final String label;
  final int value;
  final int max;
  final int min;
  final ValueChanged<int> onChanged;
  final bool locked;
  final int step;

  const IntegerCounter({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
    this.min = 0,
    required this.onChanged,
    this.locked = false,
    this.step = 1,
  }) : super(key: key);

  @override
  State<IntegerCounter> createState() => _IntegerCounterState();
}

class _IntegerCounterState extends State<IntegerCounter> {
  late int _currentValue;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);
    _controller = TextEditingController(text: _currentValue.toString());
  }

  @override
  void didUpdateWidget(IntegerCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value.clamp(widget.min, widget.max);
      _controller.text = _currentValue.toString();
    }
  }

  void _manualSubmit(String val) {
    final parsed = int.tryParse(val);
    if (parsed != null) {
      setState(() {
        _currentValue = parsed.clamp(widget.min, widget.max);
        _controller.text = _currentValue.toString();
      });
      widget.onChanged(_currentValue);
    } else {
      _controller.text = _currentValue.toString();
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
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: '${widget.min} – ${widget.max}',
                labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              onSubmitted: _manualSubmit,
              onEditingComplete: () => _manualSubmit(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}
