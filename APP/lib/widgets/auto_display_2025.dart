import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scouting_app/models/match_scouting_2025.dart';
import '../utils.dart';

class AutoDisplay2025 extends StatefulWidget {
  final MatchScouting2025 scoutingData;
  final bool? showTeamNumber, showScoutDetails;
  const AutoDisplay2025(
      {required this.scoutingData,
      Key? key,
      this.showTeamNumber,
      this.showScoutDetails})
      : super(key: key);

  @override
  _AutoDisplay2025State createState() => _AutoDisplay2025State();
}

class _AutoDisplay2025State extends State<AutoDisplay2025> {
  var decodedImage = null;
  late final image;
  static const NOTE_SIZE = 200.0;
  final List<String> pieces = [
    'spike_left',
    'spike_middle',
    'spike_right',
    'halfway_far_left',
    'halfway_middle_left',
    'halfway_middle',
    'halfway_middle_right',
    'halfway_far_right'
  ];
  final List<double> pieceX = [171, 418, 664, 55, 340, 625, 910, 1195];
  final List<double> pieceY = [835, 835, 835, 46, 46, 46, 46, 46];

  @override
  void initState() {
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
    final scoutingData = widget.scoutingData;
    double imageScaleFactor = 1;
    Offset _calculatePosition(double x, double y) {
      final scaledX = x * imageScaleFactor;
      final scaledY = y * imageScaleFactor;
      return Offset(scaledX, scaledY);
    }

    var display = LayoutBuilder(builder: (context, constraints) {
      final naturalWidth = (decodedImage?.width ?? 1);
      final offsetWidth = constraints.maxWidth;
      imageScaleFactor = offsetWidth / naturalWidth * 2;
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Set the corner radius
        ),
        child: Stack(
          children: [
            Image.asset('assets/2024BlankAutoField.png', fit: BoxFit.fitWidth),
            ...pieces.asMap().entries.map((entry) {
              final idx = entry.key;
              // final piece = entry.value;
              final position = _calculatePosition(pieceX[idx], pieceY[idx]);
              // final isSelected =
              //     (scoutingData.data.selectedPieces ?? []).contains(piece);
              // final pieceIndex = isSelected
              //     ? (scoutingData.data.selectedPieces ?? []).indexOf(piece)
              //     : -1;

              return Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Stack(children: [
                    Container(
                        width: NOTE_SIZE * imageScaleFactor,
                        height: NOTE_SIZE * imageScaleFactor,
                        child:
                            Image.asset('assets/Note.png', fit: BoxFit.fill)),
                    // if (pieceIndex >= 0)
                    //   Container(
                    //     width: NOTE_SIZE * imageScaleFactor,
                    //     height: NOTE_SIZE * imageScaleFactor,
                    //     alignment: Alignment.center,
                    //     child: Text(
                    //       '${pieceIndex + 1}',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 100 * imageScaleFactor,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   )
                  ]));
            }).toList(),
          ],
        ),
      );
    });

    return decodedImage != null
        ? Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            child: Padding(
                padding: EdgeInsets.all(isMobile() ? 0 : 16),
                child: Column(
                  children: [
                    if (decodedImage != null)
                      isMobile()
                          ? Tooltip(
                              message: (widget.showTeamNumber ?? true
                                      ? 'Team: ${scoutingData.team_number} | '
                                      : '') +
                                  'Match: ${scoutingData.match_number} | ' +
                                  (widget.showScoutDetails ?? true
                                      ? 'Scout: ${scoutingData.scout_info.first_name != null ? scoutingData.scout_info.first_name : "From Team ${scoutingData.scout_info.team_number}"} | '
                                      : '') +
                                  'Coral: ${scoutingData.data.auto_scoring.l_1 + scoutingData.data.auto_scoring.l_2 + scoutingData.data.auto_scoring.l_3 + scoutingData.data.auto_scoring.l_4}' +
                                  'Net: ${scoutingData.data.auto_scoring.net}' +
                                  'Processor: ${scoutingData.data.auto_scoring.processor}',
                              triggerMode: TooltipTriggerMode.tap,
                              child: display,
                            )
                          : display,
                    if (!isMobile())
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          (widget.showTeamNumber ?? true
                                  ? 'Team: ${scoutingData.team_number} | '
                                  : '') +
                              'Match: ${scoutingData.match_number} | ' +
                              (widget.showScoutDetails ?? true
                                  ? 'Scout: ${scoutingData.scout_info.first_name != null ? scoutingData.scout_info.first_name : "From Team ${scoutingData.scout_info.team_number}"} | '
                                  : '') +
                              'Coral: ${scoutingData.data.auto_scoring.l_1 + scoutingData.data.auto_scoring.l_2 + scoutingData.data.auto_scoring.l_3 + scoutingData.data.auto_scoring.l_4}' +
                              'Net: ${scoutingData.data.auto_scoring.net}' +
                              'Processor: ${scoutingData.data.auto_scoring.processor}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                )))
        : CircularProgressIndicator(color: Colors.blue);
  }
}
