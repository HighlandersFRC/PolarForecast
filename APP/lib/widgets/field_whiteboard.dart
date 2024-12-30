import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';

class FieldWhiteboard extends StatefulWidget {
  final ScribbleNotifier? notifier;
  const FieldWhiteboard({super.key, this.notifier});

  @override
  State<FieldWhiteboard> createState() => _FieldWhiteboardState();
}

class _FieldWhiteboardState extends State<FieldWhiteboard> {
  late ScribbleNotifier notifier;
  late ScrollController toolbarScrollController;
  late ScrollController colorScrollController;
  var decodedImage = null;
  @override
  void initState() {
    toolbarScrollController = ScrollController();
    colorScrollController = ScrollController();
    notifier = widget.notifier ?? ScribbleNotifier();
    super.initState();
    rootBundle.load('assets/2024GameField.png').then((value) {
      decodeImageFromList(value.buffer.asUint8List())
          .then((data) => setState(() {
                decodedImage = (data);
              }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double minWidth = 500;
      minWidth = min(constraints.maxWidth, minWidth);
      double maxWidth = constraints.maxWidth;
      double maxHeight = constraints.maxHeight - 180;
      if (decodedImage != null) {
        maxWidth = max(
            minWidth,
            min(decodedImage.width / decodedImage.height * maxHeight,
                maxWidth));
        maxHeight = decodedImage.height / decodedImage.width * maxWidth;
      }
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: constraints.maxWidth,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Scrollbar(
                  controller: toolbarScrollController,
                  thumbVisibility: true, // Makes the scrollbar always visible
                  child: SingleChildScrollView(
                    controller: toolbarScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(children: _buildActions(context)),
                  ),
                ),
              ),
            ),
            decodedImage == null
                ? Image.asset('assets/2024GameField.png')
                : Container(
                    width: maxWidth,
                    height: maxHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset('assets/2024GameField.png'),
                        Scribble(
                          notifier: notifier,
                        ),
                      ],
                    ),
                  ),
            Container(
              width: constraints.maxWidth,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Scrollbar(
                    controller: colorScrollController,
                    thumbVisibility: true, // Makes the scrollbar always visible
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: colorScrollController,
                      child: Row(
                        children: [
                          _buildColorToolbar(context),
                          _buildStrokeToolbar(context),
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildActions(context) {
    return [
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: Icon(Icons.undo,
              color: notifier.canUndo ? Colors.blue : Colors.grey),
          tooltip: 'Undo',
          onPressed: notifier.canUndo ? notifier.undo : null,
        ),
      ),
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: Icon(Icons.redo,
              color: notifier.canRedo ? Colors.blue : Colors.grey),
          tooltip: 'Redo',
          onPressed: notifier.canRedo ? notifier.redo : null,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.refresh, color: Colors.red),
        tooltip: 'Clear',
        onPressed: notifier.clear,
      ),
      if (!kIsWeb)
        IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          tooltip: 'Download Image',
          onPressed: () => _showImage(context),
        ),
      IconButton(
        icon: const Icon(Icons.data_object, color: Colors.blue),
        tooltip: 'Show JSON',
        onPressed: () => _showJson(context),
      ),
    ];
  }

  void _showImage(BuildContext context) async {
    if (decodedImage == null) return;

    // Render the drawing as an image
    var drawingImage = await decodeImageFromList(
        (await notifier.renderImage(pixelRatio: 1)).buffer.asUint8List());
    var ratio = decodedImage.width / drawingImage.width;
    drawingImage = await decodeImageFromList(
        (await notifier.renderImage(pixelRatio: ratio)).buffer.asUint8List());
    // Combine the background and drawing
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Draw the background image
    final backgroundPaint = Paint();
    canvas.drawImage(decodedImage!, Offset.zero, backgroundPaint);

    // Draw the drawing on top
    final drawingPaint = Paint();
    canvas.drawImage(
      drawingImage,
      Offset.zero,
      drawingPaint,
    );

    // Convert the canvas to an image
    final combinedImage = await pictureRecorder
        .endRecording()
        .toImage(decodedImage!.width, decodedImage!.height);
    final byteData =
        await combinedImage.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    downloadImage(pngBytes);
  }

  Future<void> downloadImage(Uint8List pngBytes) async {
    final directory = await getDownloadsDirectory();
    final fileName = await _showFileNameDialog(context);

    if (fileName != null && fileName.isNotEmpty) {
      final filePath = '${directory?.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to ${directory?.path}/${fileName}.png'),
        ),
      );
      Navigator.of(context).pop();
    } else {
      print('User canceled the file name input or provided no name');
    }
  }

  Future<String?> _showFileNameDialog(BuildContext context) async {
    String fileName = '';
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter File Name'),
          content: TextField(
            onChanged: (value) => fileName = value,
            cursorColor: Colors.blue,
            decoration: InputDecoration(
                hintText: 'File name (without extension)',
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2))),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(fileName),
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _showJson(BuildContext context) {
    final TextEditingController jsonController = TextEditingController(
      text: jsonEncode(notifier.currentSketch.toJson()),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sketch as JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Copy the JSON to save it. Then Paste to import it again'),
            TextField(
              controller: jsonController,
              clipBehavior: Clip.hardEdge,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                border: OutlineInputBorder(),
                hintText: 'Paste JSON here...',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON copied to clipboard!')),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.copy, color: Colors.blue),
          ),
          TextButton(
            onPressed: () {
              try {
                final pastedJson = jsonDecode(jsonController.text);
                notifier.setSketch(sketch: Sketch.fromJson(pastedJson));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON imported successfully!')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid JSON format!')),
                );
              }
            },
            child:
                const Text('Import JSON', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stroke Size'),
            SliderTheme(
              data: SliderThemeData(
                thumbShape: AppSliderShape(thumbRadius: state.selectedWidth),
                activeTrackColor: state.map(
                  drawing: (s) => Color(s.selectedColor).withAlpha(200),
                  erasing: (_) => Colors.grey,
                ),
              ),
              child: Slider(
                thumbColor: state.map(
                  drawing: (s) => Color(s.selectedColor),
                  erasing: (_) => Colors.transparent,
                ),
                value: state.selectedWidth,
                min: 1,
                max: notifier.widths.last,
                label: state.selectedWidth.toStringAsFixed(1),
                onChanged: (value) => notifier.setStrokeWidth(value),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorToolbar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildColorButton(context, color: Colors.black),
        _buildColorButton(context, color: Colors.red),
        _buildColorButton(context, color: Colors.green),
        _buildColorButton(context, color: Colors.blue),
        _buildColorButton(context, color: Colors.yellow),
        _buildEraserButton(context),
      ],
    );
  }

  Widget _buildEraserButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier.select((value) => value is Erasing),
      builder: (context, value, child) => ColorButton(
        color: Colors.transparent,
        outlineColor: Colors.black,
        isActive: value,
        onPressed: () => notifier.setEraser(),
        child: const Icon(Icons.cleaning_services),
      ),
    );
  }

  Widget _buildColorButton(
    BuildContext context, {
    required Color color,
  }) {
    return ValueListenableBuilder(
      valueListenable: notifier.select(
          (value) => value is Drawing && value.selectedColor == color.value),
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ColorButton(
          color: color,
          isActive: value,
          onPressed: () => notifier.setColor(color),
        ),
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.outlineColor,
    this.child,
    super.key,
  });

  final Color color;

  final Color? outlineColor;

  final bool isActive;

  final VoidCallback onPressed;

  final Icon? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: isActive ? outlineColor ?? color : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: IconButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          side: isActive
              ? const BorderSide(color: Colors.white, width: 2)
              : const BorderSide(color: Colors.transparent),
        ),
        onPressed: onPressed,
        icon: child ?? const SizedBox(),
      ),
    );
  }
}

class AppSliderShape extends SliderComponentShape {
  final double thumbRadius;

  const AppSliderShape({required this.thumbRadius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = sliderTheme.thumbColor ?? Colors.blue;

    // Draw circle thumb shape with border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white // White border color
      ..strokeWidth = 2.0; // Border thickness

    canvas.drawCircle(center, thumbRadius, paint);
    canvas.drawCircle(center, thumbRadius + 2, borderPaint); // Draw border
  }
}
