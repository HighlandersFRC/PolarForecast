import 'package:flutter/material.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:scouting_app/widgets/auto_pieces_2026.dart';
import '../utils.dart';

class AutoDisplay2026 extends StatefulWidget {
  final MatchScouting2026 scoutingData;
  final bool? showTeamNumber, showScoutDetails;
  const AutoDisplay2026(
      {required this.scoutingData,
      Key? key,
      this.showTeamNumber,
      this.showScoutDetails})
      : super(key: key);

  @override
  _AutoDisplay2025State createState() => _AutoDisplay2025State();
}

class _AutoDisplay2025State extends State<AutoDisplay2026> {
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
                                : ''),
                        triggerMode: TooltipTriggerMode.tap,
                        child: AutoPieces2026(
                          auto: widget.scoutingData.data.auto,
                          matchScouting: true,
                        ),
                      )
                    : AutoPieces2026(
                        auto: widget.scoutingData.data.auto,
                        matchScouting: true,
                      ),
                if (!isMobile())
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text((widget.showTeamNumber ?? true
                            ? 'Team: ${scoutingData.team_number} | '
                            : '') +
                        'Match: ${scoutingData.match_number} | ' +
                        (widget.showScoutDetails ?? true
                            ? 'Scout: ${scoutingData.scout_info.first_name != null ? scoutingData.scout_info.first_name : "From Team ${scoutingData.scout_info.team_number}"} | '
                            : '')),
                  ),
              ],
            )));
  }
}
