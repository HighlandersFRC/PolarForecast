import 'dart:math';

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

  const DeathsForm(
    this.tournament,
    this.teamNumber,
    this.locked,
  );

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

  @override
  void initState() {
    super.initState();
    fetchFollowUpData();
  }

  void fetchFollowUpData() async {
    final api = Provider.of<ApiService>(context, listen: false);
    api
        .fetchFollowUp(
          widget.tournament.page.split('/')[3],
          widget.tournament.page.split('/')[4],
          'frc${widget.teamNumber}',
        )
        .then((fetchedData) => setState(() {
              deaths = fetchedData;
              for (var death in deaths.deaths) {
                controllers
                    .add(TextEditingController(text: death.death_reason));
              }
              loading = false;
              api
                  .fetchTeamMatchScouting(
                      int.parse(widget.tournament.page.split('/')[3]),
                      widget.tournament.page.split('/')[4],
                      'frc${widget.teamNumber.toString()}')
                  .then(
                (value) {
                  setState(() {
                    matchScouting = value.cast<MatchScouting2026>();
                    commentsLoading = false;
                  });
                },
              );
            }));
  }

  void handleSubmit() async {
    final api = Provider.of<ApiService>(context, listen: false);
    final status = await api.postFollowUp(
      deaths,
      widget.tournament.page.split('/')[3],
      widget.tournament.page.split('/')[4],
      'frc${widget.teamNumber}',
    );
    if (status == 200) {
      setState(() {
        formSubmitted = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Submission failed. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void handleEditForm() {
    setState(() {
      formSubmitted = false;
    });
  }

  void handleGoBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator(color: Colors.blue))
        : Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(16.0),
            child: formSubmitted
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Submission Successful',
                          style: TextStyle(fontSize: 24, color: Colors.green),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: handleEditForm,
                          child: Text('Edit Form'),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => handleGoBack(context),
                          child: Text('Go Back'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: (deaths.deaths.isEmpty)
                        ? Text('No Deaths Reported',
                            style: TextStyle(fontSize: 24))
                        : Column(children: [
                            ...deaths.deaths.map((death) {
                              TextEditingController _controller =
                                  controllers[deaths.deaths.indexOf(death)];
                              List<String> comments = matchScouting
                                  .where((element) =>
                                      element.match_number ==
                                          death.match_number &&
                                      element.data.miscellaneous.comments
                                          .isNotEmpty)
                                  .map((e) => e.data.miscellaneous.comments)
                                  .toList();
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Death #${deaths.deaths.indexOf(death) + 1}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 3)),
                                          floatingLabelStyle: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          labelStyle: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          labelText: 'Match Number',
                                          border: OutlineInputBorder(),
                                        ),
                                        style: TextStyle(color: Colors.grey),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) => setState(() {
                                          int index =
                                              deaths.deaths.indexOf(death);
                                          int val = int.tryParse(value) ?? 0;
                                          deaths = deaths.copyWith(deaths: [
                                            ...deaths.deaths.sublist(
                                              0,
                                              min(deaths.deaths.length, index),
                                            ),
                                            death.copyWith(match_number: val),
                                            if (index + 1 !=
                                                deaths.deaths.length)
                                              ...deaths.deaths
                                                  .sublist(index + 1)
                                          ]);
                                        }),
                                        controller: TextEditingController(
                                          text: death.match_number.toString(),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        style: widget.locked
                                            ? TextStyle(color: Colors.grey)
                                            : null,
                                        readOnly: widget.locked,
                                        cursorColor: Colors.blue,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 3)),
                                          floatingLabelStyle: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          labelStyle: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          labelText: 'Reason for Team Death',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) => setState(() {
                                          int index =
                                              deaths.deaths.indexOf(death);
                                          deaths = deaths.copyWith(deaths: [
                                            ...deaths.deaths.sublist(
                                              0,
                                              min(deaths.deaths.length, index),
                                            ),
                                            death.copyWith(death_reason: value),
                                            if (index + 1 !=
                                                deaths.deaths.length)
                                              ...deaths.deaths
                                                  .sublist(index + 1)
                                          ]);
                                        }),
                                        controller: _controller,
                                      ),
                                      SizedBox(height: 10),
                                      DropdownButtonFormField<int>(
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 3)),
                                          floatingLabelStyle: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          labelStyle: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          focusColor: Colors.blue,
                                          labelText: 'Severity',
                                          border: OutlineInputBorder(),
                                        ),
                                        value: death.severity,
                                        onChanged: widget.locked
                                            ? null
                                            : (value) => setState(() {
                                                  int index = deaths.deaths
                                                      .indexOf(death);
                                                  deaths =
                                                      deaths.copyWith(deaths: [
                                                    ...deaths.deaths.sublist(
                                                      0,
                                                      min(deaths.deaths.length,
                                                          index),
                                                    ),
                                                    death.copyWith(
                                                        severity: value ?? -1),
                                                    if (index + 1 !=
                                                        deaths.deaths.length)
                                                      ...deaths.deaths
                                                          .sublist(index + 1)
                                                  ]);
                                                }),
                                        items: [
                                          DropdownMenuItem(
                                            child: Text('Choose...'),
                                            value: -1,
                                          ),
                                          DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                              '1 (One-time error)',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                              '2 (Fixable before elims)',
                                              style: TextStyle(
                                                  color: Colors.yellow),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 3,
                                            child: Text(
                                              '3 (Permanently broken)',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Comments',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      if (commentsLoading)
                                        Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.blue),
                                        )
                                      else if (comments.isNotEmpty)
                                        ...List.generate(
                                          comments.length,
                                          (commentIndex) {
                                            return Card(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              color: Colors.grey[800],
                                              child: ListTile(
                                                title: Text(
                                                  'Match ${death.match_number} - Comment ${commentIndex + 1}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    comments[commentIndex],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        Text('No comments found'),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            if (!widget.locked)
                              Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextButton(
                                    onPressed: handleSubmit,
                                    child: Row(children: [
                                      Text(
                                        'Submit  ',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      Icon(Icons.send, color: Colors.blue)
                                    ]),
                                  )),
                          ])));
  }
}
