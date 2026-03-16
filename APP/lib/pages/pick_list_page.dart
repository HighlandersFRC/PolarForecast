import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/group.dart';
import '../models/team_stats_2026.dart';
import '../models/match_scouting_2026.dart';
import '../models/tournament.dart';

class PicklistPage extends StatefulWidget {
  final String groupName;
  final String eventCode;
  final String picklistID;

  const PicklistPage({
    super.key,
    required this.groupName,
    required this.eventCode,
    required this.picklistID,
  });

  @override
  State<PicklistPage> createState() => _PicklistPageState();
}

class _PicklistPageState extends State<PicklistPage> {
  List<Picklist2026> picklists = [];
  String currentPicklistId = "";
  ApiService get api => Provider.of<ApiService>(context, listen: false);

  List<Picks> currentPicklist = [];
  String picklistName = "";

  void addTeam(TeamStats2026 team) {
    setState(() {
      currentPicklist.add(
        Picks(
          number: team.team_number,
          comments: "",
        ),
      );
    });
  }

  void removeTeam(Picks pick) {
    setState(() {
      currentPicklist.remove(pick);
    });
  }

  late List<TeamStats2026> rankings = [];
  late Tournament? tournament =
      Tournament(key: '', display: '', page: '', start: '', end: '');
  late List<MatchScouting2026> scouting = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void loadPicklist(Picklist2026 picklist) {
    setState(() {
      currentPicklistId = picklist.picklist_id;
      picklistName = picklist.name;
      currentPicklist = List.from(picklist.picks);
    });
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final String fullEventCode = widget.eventCode;

      // Extract year if first 4 chars are digits
      int year = 0;
      String code = fullEventCode;

      if (fullEventCode.length >= 4 &&
          int.tryParse(fullEventCode.substring(0, 4)) != null) {
        year = int.parse(fullEventCode.substring(0, 4));
        code = fullEventCode.substring(4); // everything after year
      } else {
        // Default to 2026 if no valid year prefix
        year = 2026;
      }

      // Fetch data using the extracted year and code
      final fetchedRankings = await apiService.fetchEventRankings(year, code);
      final fetchedScouting = await apiService.fetchEventScouting(year, code);
      final fetchedPicklists =
          await apiService.getPicklists(widget.groupName, fullEventCode);

      if (!mounted) return;

      setState(() {
        rankings = fetchedRankings;
        scouting = fetchedScouting;
        picklists = fetchedPicklists;

        // Load picklist if editing one
        if (widget.picklistID.isNotEmpty) {
          final selected = picklists.firstWhere(
            (p) => p.picklist_id == widget.picklistID,
            orElse: () => picklists.first,
          );
          currentPicklistId = selected.picklist_id;
          currentPicklist = List<Picks>.from(selected.picks);
          picklistName = selected.name;
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updatePicklist() async {
    final picklist = Picklist2026(
      picklist_id: currentPicklistId,
      name: picklistName,
      picks: currentPicklist
          .map((p) => Picks(number: p.number, comments: p.comments))
          .toList(),
    );

    await api.updatePicklist(
      widget.groupName,
      widget.eventCode,
      currentPicklistId,
      picklist,
    );

    Navigator.pop(context);
  }

  Future<void> deletePicklist() async {
    await api.deletePicklist(
        widget.groupName, widget.eventCode, currentPicklistId);

    Navigator.pop(context);
  }

  Future<void> submitPicklist() async {
    final picklist = Picklist2026(
      picklist_id: "", // backend can auto-generate
      name: picklistName,
      picks: currentPicklist
          .map((p) => Picks(number: p.number, comments: p.comments))
          .toList(),
    );

    await api.addPicklist(
      widget.groupName,
      widget.eventCode,
      picklist, // Freezed handles the JSON key mapping
    );

    Navigator.pop(context);
  }

  void openCreateDialog() {
    currentPicklist = [];

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();

        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Create Picklist"),
            content: SizedBox(
              width: 700,
              height: 500,
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Picklist Name",
                    ),
                    onChanged: (v) => picklistName = v,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Selected Teams",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentPicklist.length,
                      itemBuilder: (context, i) {
                        final pick = currentPicklist[i];

                        return ListTile(
                          title: Text(pick.number),
                          subtitle: TextField(
                            decoration:
                                const InputDecoration(labelText: "Comments"),
                            onChanged: (v) {
                              setStateDialog(() {
                                currentPicklist[i] = pick.copyWith(comments: v);
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setStateDialog(() {
                                currentPicklist.removeAt(i);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  const Text(
                    "Available Teams",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rankings.length,
                      itemBuilder: (context, i) {
                        final team = rankings[i];

                        return ListTile(
                          title: Text(team.team_number),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setStateDialog(() {
                                currentPicklist.add(
                                  Picks(
                                    number: team.team_number,
                                    comments: "",
                                  ),
                                );
                              });
                            },
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text("Submit"),
                onPressed: submitPicklist,
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = rankings
        .map(
          (team) => DataGridRow(
            cells: [
              DataGridCell(columnName: 'team', value: team.team_number),
              DataGridCell(columnName: 'rank', value: team.rank),
            ],
          ),
        )
        .toList();

    final dataSource = _TeamDataSource(
      rows,
      {},
      {},
      {},
      context,
      tournament!,
      scouting,
      rankings,
    );

    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Picklist for ${widget.eventCode}',
      ),
      body: Row(
        children: [
          /// Rankings Table
          Expanded(
            flex: 2,
            child: SfDataGrid(
              source: dataSource,
              columns: [
                GridColumn(
                  columnName: "team",
                  label: const Center(child: Text("Team")),
                ),
                GridColumn(
                  columnName: "rank",
                  label: const Center(child: Text("Rank")),
                ),
              ],
            ),
          ),

          /// Picklist Builder
          Expanded(
            child: Column(
              children: [
                /// PICKLIST SELECTOR
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Saved Picklists",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: picklists.length,
                    itemBuilder: (context, i) {
                      final picklist = picklists[i];

                      return GestureDetector(
                        onTap: () => loadPicklist(picklist),
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                picklist.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Current Picklist",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: currentPicklist.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;

                        final item = currentPicklist.removeAt(oldIndex);
                        currentPicklist.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final pick = currentPicklist[index];

                      Map<String, TextEditingController> _controllers = {};

                      // Create controller if it doesn't exist yet

                      return Card(
                        key: ValueKey(pick.number),
                        child: ListTile(
                          title: Text("${index + 1}. ${pick.number}"),
                          subtitle: TextField(
                            controller: _controllers.putIfAbsent(
                              pick.number,
                              () => TextEditingController(text: pick.comments),
                            ),
                            readOnly: true, // <<< makes it non-editable
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: "Comments",
                              border: InputBorder
                                  .none, // optional: removes the border
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                currentPicklist.removeAt(index);
                                // Clean up the controller
                                _controllers[pick.number]?.dispose();
                                _controllers.remove(pick.number);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: updatePicklist,
                    child: const Text("Update Picklist"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: deletePicklist,
                    child: const Text("Delete Picklist"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: openCreateDialog,
                    child: const Text("Create Picklist"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamDataSource extends DataGridSource {
  _TeamDataSource(this.rows, this.minValues, this.maxValues, this.heatMap,
      this.context, this.tournament, this.scouting, this.rankings);
  final Map<String, dynamic> minValues, maxValues, heatMap;
  final List<DataGridRow> rows;
  final BuildContext context;
  final Tournament tournament;
  final List<MatchScouting2026> scouting;
  final List<TeamStats2026> rankings;
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        int rowNumber = rows.indexOf(row);
        bool even = rowNumber % 2 == 0;
        final color = heatMap[e.columnName] != null && heatMap[e.columnName]!
            ? _getGradientColor(
                e.value,
                minValues[e.columnName],
                maxValues[e.columnName],
                e.columnName == 'rank' ||
                    e.columnName == 'simulated_rank' ||
                    e.columnName == 'death_rate' ||
                    e.columnName == 'defense_rate')
            : even
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0);

        return GestureDetector(
          onTap: () {
            final teamNumber = row.getCells()[0].value;
            final team =
                rankings.firstWhere((t) => t.team_number == teamNumber);

            if (!context.mounted) return;

            final state = context.findAncestorStateOfType<_PicklistPageState>();
            state?.addTeam(team);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            color: color,
            child: Text(
              '${_formatValue(e.value)}',
              style: const TextStyle(color: Colors.white, fontFamily: 'Font'),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getGradientColor(num value, num minValue, num maxValue, bool flip) {
    double normalizedValue = (value - minValue) / (maxValue - minValue);
    normalizedValue = normalizedValue.clamp(0.0, 1.0);
    if (flip) normalizedValue = 1 - normalizedValue;
    if (normalizedValue > 0.5) {
      return Color.lerp(Colors.yellow[700], Colors.green.shade800,
              (normalizedValue - 0.5) * 2) ??
          Colors.green.shade700;
    } else {
      return Color.lerp(
              Colors.red.shade700, Colors.yellow[700], normalizedValue * 2) ??
          Colors.red.shade700;
    }
  }

  double _roundToTenths(double value) {
    return (value * 10).roundToDouble() / 10;
  }

  dynamic _formatValue(dynamic value) {
    if (value is double) {
      return _roundToTenths(value).toStringAsFixed(1);
    }
    return value;
  }
}
