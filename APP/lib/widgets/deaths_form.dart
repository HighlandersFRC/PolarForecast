import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/deaths_form.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:scouting_app/models/scout_info.dart';
import '../api_service.dart';
import '../models/tournament.dart';

class DeathsForm extends StatefulWidget {
  final Tournament tournament;
  final int teamNumber;
  final bool locked;

  const DeathsForm(this.tournament, this.teamNumber, this.locked, {super.key});

  @override
  _DeathsFormState createState() => _DeathsFormState();
}

class _DeathsFormState extends State<DeathsForm> {
  late Deaths deaths = Deaths(
      average: 0,
      scout_info: ScoutInfo(user_id: '', team_number: 0),
      event_code: widget.tournament.key,
      team_key: widget.teamNumber.toString(),
      total: 0,
      time: 0);

  List<MatchScouting2026> matchScouting = [];
  List<TextEditingController> controllers = [];
  bool formSubmitted = false;
  bool loading = true, commentsLoading = true;

  // --- Dark Theme Constants ---
  final Color accentBlue = const Color(0xFF448AFF); // Bright Blue
  final Color darkBackground = const Color(0xFF121212); // Deep Black/Grey
  final Color surfaceColor = const Color(0xFF1E1E1E); // Elevated Dark Grey
  final TextStyle fontStyle =
      const TextStyle(fontFamily: 'Font', color: Colors.white);

  @override
  void initState() {
    super.initState();
    fetchFollowUpData();
  }

  void fetchFollowUpData() async {
    final api = Provider.of<ApiService>(context, listen: false);
    final eventParts = widget.tournament.page.split('/');

    try {
      final fetchedData = await api.fetchFollowUp(
        eventParts[3],
        eventParts[4],
        'frc${widget.teamNumber}',
      );

      setState(() {
        deaths = fetchedData;
        controllers = deaths.deaths
            .map((d) => TextEditingController(text: d.death_reason))
            .toList();
        loading = false;
      });

      final matchData = await api.fetchTeamMatchScouting(
          int.parse(eventParts[3]), eventParts[4], 'frc${widget.teamNumber}');

      setState(() {
        matchScouting = matchData.cast<MatchScouting2026>();
        commentsLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  void handleSubmit() async {
    final api = Provider.of<ApiService>(context, listen: false);
    final eventParts = widget.tournament.page.split('/');
    final status = await api.postFollowUp(
      deaths,
      eventParts[3],
      eventParts[4],
      'frc${widget.teamNumber}',
    );

    if (status == 200) {
      setState(() => formSubmitted = true);
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text('Error', style: fontStyle),
        content: Text('Submission failed.',
            style: fontStyle.copyWith(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: accentBlue))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackground,
        colorScheme:
            ColorScheme.dark(primary: accentBlue, surface: surfaceColor),
      ),
      child: Scaffold(
        body: loading
            ? Center(child: CircularProgressIndicator(color: accentBlue))
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: formSubmitted ? _buildSuccessView() : _buildFormView(),
              ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.greenAccent[400], size: 100),
          const SizedBox(height: 20),
          Text('REPORT SENT',
              style: fontStyle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => setState(() => formSubmitted = false),
            style: ElevatedButton.styleFrom(
                backgroundColor: accentBlue, foregroundColor: Colors.white),
            child: const Text('EDIT ENTRIES'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('RETURN TO LIST',
                style: TextStyle(color: accentBlue.withOpacity(0.7))),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    if (deaths.deaths.isEmpty) {
      return Center(
          child: Text('No Deaths Found',
              style: fontStyle.copyWith(color: Colors.white38, fontSize: 18)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          ...deaths.deaths
              .asMap()
              .entries
              .map((entry) => _buildDeathCard(entry.value, entry.key)),
          if (!widget.locked) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: handleSubmit,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text('SUBMIT FOLLOW-UP',
                    style: fontStyle.copyWith(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ]
        ],
      ),
    );
  }

  Widget _buildDeathCard(dynamic death, int index) {
    List<String> comments = matchScouting
        .where((m) =>
            m.match_number == death.match_number &&
            m.data.miscellaneous.comments.isNotEmpty)
        .map((e) => e.data.miscellaneous.comments)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                    backgroundColor: accentBlue,
                    radius: 14,
                    child: Text('${index + 1}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white))),
                const SizedBox(width: 12),
                Text('Match ${death.match_number}',
                    style: fontStyle.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.bolt, color: Colors.amber, size: 18),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDarkField('Reason', controllers[index], (val) {
                  setState(() {
                    deaths = deaths.copyWith(
                      deaths: deaths.deaths
                          .asMap()
                          .map((i, d) => MapEntry(i,
                              i == index ? d.copyWith(death_reason: val) : d))
                          .values
                          .toList(),
                    );
                  });
                }),
                const SizedBox(height: 20),
                _buildSeverityDropdown(death, index),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white10)),
                _buildScoutComments(comments),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkField(String label, TextEditingController controller,
      Function(String) onChanged) {
    return TextField(
      controller: controller,
      readOnly: widget.locked,
      onChanged: onChanged,
      style: fontStyle,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accentBlue),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white12),
            borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentBlue),
            borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSeverityDropdown(dynamic death, int index) {
    return DropdownButtonFormField<int>(
      value: death.severity,
      dropdownColor: surfaceColor,
      decoration: InputDecoration(
        labelText: 'Severity',
        labelStyle: TextStyle(color: accentBlue),
        border: const OutlineInputBorder(),
      ),
      onChanged: widget.locked
          ? null
          : (val) {
              setState(() {
                deaths = deaths.copyWith(
                  deaths: deaths.deaths
                      .asMap()
                      .map((i, d) => MapEntry(
                          i, i == index ? d.copyWith(severity: val ?? -1) : d))
                      .values
                      .toList(),
                );
              });
            },
      items: [
        const DropdownMenuItem(value: -1, child: Text('Choose...')),
        DropdownMenuItem(
            value: 1,
            child: Text('1 - One Time Incident',
                style: TextStyle(color: Colors.greenAccent[400]))),
        const DropdownMenuItem(
            value: 2,
            child: Text('2 - Fixable Before Elims',
                style: TextStyle(color: Colors.orangeAccent))),
        DropdownMenuItem(
            value: 3,
            child: Text('3 - Permanent/Unfixable',
                style: TextStyle(color: Colors.redAccent[200]))),
      ],
    );
  }

  Widget _buildScoutComments(List<String> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SCOUT OBSERVATIONS',
            style: fontStyle.copyWith(
                fontSize: 12,
                color: Colors.white38,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (commentsLoading)
          const LinearProgressIndicator()
        else if (comments.isEmpty)
          const Text('No observations.',
              style: TextStyle(color: Colors.white24, fontSize: 13))
        else
          ...comments.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(c,
                    style: fontStyle.copyWith(
                        fontSize: 13, color: Colors.white70)),
              )),
      ],
    );
  }
}
