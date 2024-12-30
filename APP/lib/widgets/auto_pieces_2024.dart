import 'package:flutter/material.dart';

class AutoPieces2024 extends StatefulWidget {
  final List<String> selectedPieces;
  final Function(List<String>) onChanged;
  const AutoPieces2024(
      {Key? key, required this.selectedPieces, required this.onChanged})
      : super(key: key);

  @override
  _AutoPieces2024State createState() => _AutoPieces2024State();
}

class _AutoPieces2024State extends State<AutoPieces2024> {
  bool isFlipped = false;

  void handlePieceClick(String piece) {
    setState(() {
      if (widget.selectedPieces.contains(piece)) {
        widget.selectedPieces.remove(piece);
      } else {
        widget.selectedPieces.add(piece);
      }
      widget.onChanged(widget.selectedPieces);
    });
  }

  void flipImage() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    const List<String> pieces = [
      'spike_left',
      'spike_middle',
      'spike_right',
      'halfway_far_left',
      'halfway_middle_left',
      'halfway_middle',
      'halfway_middle_right',
      'halfway_far_right'
    ];
    const List<double> pieceX = [186, 433, 679, 108, 394, 679, 965, 1251];
    const List<double> pieceY = [978, 978, 978, 61, 61, 61, 61, 61];
    const double fieldWidth = 1425;
    const double noteSize = 75;
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate the image scale factor based on the real width
      double imageScaleFactor = 1.0;
      imageScaleFactor = constraints.maxWidth / fieldWidth;
      return Column(
        children: [
          Stack(
            children: [
              ColorFiltered(
                colorFilter: isFlipped
                    ? const ColorFilter.matrix([
                        // Red to Blue filter matrix
                        0, 0, 1, 0, 0, // R channel
                        0, 1, 0, 0, 0, // G channel
                        1, 0, 0, 0, 0, // B channel
                        0, 0, 0, 1, 0, // A channel
                      ])
                    : const ColorFilter.matrix([
                        // Blue to Red filter matrix
                        1, 0, 0, 0, 0, // R channel
                        0, 1, 0, 0, 0, // G channel
                        0, 0, 1, 0, 0, // B channel
                        0, 0, 0, 1, 0, // A channel
                      ]),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(isFlipped ? -1.0 : 1.0, 1.0),
                  child: Image.asset(
                    'assets/AutosGameField.png',
                    fit: BoxFit.fitWidth,
                    width: constraints.maxWidth,
                  ),
                ),
              ),
              for (int idx = 0; idx < pieces.length; idx++)
                Positioned(
                  left: (isFlipped
                          ? (fieldWidth - pieceX[idx]) - (noteSize)
                          : pieceX[idx]) *
                      imageScaleFactor,
                  top: pieceY[idx] * imageScaleFactor,
                  child: GestureDetector(
                    onTap: () => handlePieceClick(pieces[idx]),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: noteSize * imageScaleFactor,
                          height: noteSize * imageScaleFactor,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                              image: AssetImage('assets/Note.png'),
                              fit: BoxFit.cover,
                              colorFilter:
                                  widget.selectedPieces.contains(pieces[idx])
                                      ? null
                                      : const ColorFilter.mode(
                                          Colors.grey, BlendMode.saturation),
                            ),
                          ),
                        ),
                        if (widget.selectedPieces.contains(pieces[idx]))
                          Text(
                            (widget.selectedPieces.indexOf(pieces[idx]) + 1)
                                .toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: noteSize * 0.75 * imageScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: flipImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFlipped ? Colors.blue : Colors.red,
            ),
            child: Text(isFlipped ? 'Flip to Blue' : 'Flip to Red'),
          ),
        ],
      );
    });
  }
}
