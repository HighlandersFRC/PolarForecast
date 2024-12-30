import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  List<dynamic> deaths = [];
  bool formSubmitted = false;
  bool loading = true;

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
              deaths = fetchedData['deaths'] ?? [];
              loading = false;
            }));
  }

  void handleChange(String field, int index, dynamic value) {
    setState(() {
      deaths[index][field] = value;
    });
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
                    child: (deaths.isEmpty)
                        ? Text('No Deaths Found',
                            style: TextStyle(fontSize: 24))
                        : Column(children: [
                            ...deaths.map((death) => Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Death #${deaths.indexOf(death) + 1}',
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
                                          onChanged: (value) => handleChange(
                                              'match_number',
                                              deaths.indexOf(death),
                                              int.tryParse(value) ?? 0),
                                          controller: TextEditingController(
                                            text: death['match_number']
                                                .toString(),
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
                                          onChanged: (value) => handleChange(
                                              'death_reason',
                                              deaths.indexOf(death),
                                              value),
                                          controller: TextEditingController(
                                            text: death['death_reason'],
                                          ),
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
                                          value: int.tryParse(
                                              death['severity'].toString()),
                                          onChanged: widget.locked
                                              ? null
                                              : (value) => handleChange(
                                                  'severity',
                                                  deaths.indexOf(death),
                                                  value),
                                          items: [
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
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
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
