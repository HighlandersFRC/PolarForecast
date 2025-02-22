import 'package:flutter/material.dart';
import 'package:scouting_app/models/match_scouting_2025.dart';
import 'package:scouting_app/widgets/auto_pieces_2025.dart';
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
  late final image;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scoutingData = widget.scoutingData;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        child: Padding(
            padding: EdgeInsets.all(isMobile() ? 0 : 16),
            child: Column(
              children: [
                isMobile()
                    ? Tooltip(
                        message: (widget.showTeamNumber ?? true
                                ? 'Team: ${scoutingData.team_number} | '
                                : '') +
                            'Match: ${scoutingData.match_number} | ' +
                            (widget.showScoutDetails ?? true
                                ? 'Scout: ${scoutingData.scout_info.first_name != null ? scoutingData.scout_info.first_name : "From Team ${scoutingData.scout_info.team_number}"} | '
                                : '') +
                            'Coral: ${scoutingData.data.auto_scoring.l_1 + scoutingData.data.auto_scoring.l_2 + scoutingData.data.auto_scoring.l_3 + scoutingData.data.auto_scoring.l_4} | ' +
                            'Net: ${scoutingData.data.auto_scoring.net} | ' +
                            'Processor: ${scoutingData.data.auto_scoring.processor}',
                        triggerMode: TooltipTriggerMode.tap,
                        child:
                            AutoPieces2025(auto: widget.scoutingData.data.auto),
                      )
                    : AutoPieces2025(auto: widget.scoutingData.data.auto),
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
                          'Coral: ${scoutingData.data.auto_scoring.l_1 + scoutingData.data.auto_scoring.l_2 + scoutingData.data.auto_scoring.l_3 + scoutingData.data.auto_scoring.l_4} | ' +
                          'Net: ${scoutingData.data.auto_scoring.net} | ' +
                          'Processor: ${scoutingData.data.auto_scoring.processor}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            )));
  }
}
