import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TapeMeasurePicker extends StatefulWidget {
  final String label;
  final double value;
  final double max;
  final double min;
  final double step; // e.g., 0.01
  final int decimalPlaces;
  final ValueChanged<double> onChanged;
  final bool locked; // <-- added

  const TapeMeasurePicker({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
    this.min = 0.0,
    this.step = 0.01,
    this.decimalPlaces = 2,
    required this.onChanged,
    required this.locked,
  }) : super(key: key);

  @override
  State<TapeMeasurePicker> createState() => _TapeMeasurePickerState();
}

class _TapeMeasurePickerState extends State<TapeMeasurePicker> {
  late double _currentValue;
  late ScrollController _controller;
  late TextEditingController _textController;
  final double _itemHeight = 24;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _textController = TextEditingController(
        text: _currentValue.toStringAsFixed(widget.decimalPlaces));
    _controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialIndex = ((_currentValue - widget.min) / widget.step).round();
      _controller.jumpTo(initialIndex * _itemHeight);
    });

    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.locked) return; // <-- prevent scrolling when locked

    final index = (_controller.offset / _itemHeight).round();
    final int minInt = (widget.min * 100).round();
    final int stepInt = (widget.step * 100).round();

    final value = (minInt + index * stepInt) / 100.0;

    if (value != _currentValue) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentValue = value;
        _textController.text =
            _currentValue.toStringAsFixed(widget.decimalPlaces);
      });
      widget.onChanged(value);
    }
  }

  void _manualSubmit(String val) {
    if (widget.locked) return; // <-- prevent manual entry when locked

    final parsed = double.tryParse(val);
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);
      setState(() {
        _currentValue = clamped;
        _textController.text = clamped.toStringAsFixed(widget.decimalPlaces);
        final index = ((clamped - widget.min) / widget.step).round();
        _controller.jumpTo(index * _itemHeight);
      });
      widget.onChanged(clamped);
    }
  }

  @override
  void didUpdateWidget(TapeMeasurePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
      _textController.text =
          _currentValue.toStringAsFixed(widget.decimalPlaces);
      final index = ((_currentValue - widget.min) / widget.step).round();
      if (!widget.locked) _controller.jumpTo(index * _itemHeight);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = ((widget.max - widget.min) / widget.step).round() + 1;

    return Column(
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

        // Selected value + manual input
        Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  '${_currentValue.toStringAsFixed(widget.decimalPlaces)} in',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                readOnly: widget.locked,
                controller: _textController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.end,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  suffixText: 'in',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _manualSubmit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Vertical Tape Measure
        SizedBox(
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListView.builder(
                physics: widget.locked
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                controller: _controller,
                scrollDirection: Axis.vertical,
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final value = widget.min + index * widget.step;
                  final isMajor = ((value / 1).roundToDouble() == value);

                  return SizedBox(
                    height: _itemHeight,
                    child: Row(
                      children: [
                        Container(
                          width: isMajor ? 30 : 15,
                          height: 2,
                          color: Colors.blue,
                        ),
                        if (isMajor)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              // Center indicator
              Positioned(
                top: 150,
                child: Container(
                  width: 60,
                  height: 3,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
