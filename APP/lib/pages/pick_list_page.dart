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
  List<TeamStats2026> rankings = [];
  List<Picklist2026> picklists = [];
  Picklist2026? selectedPicklist;
  List<Picks> picks = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    final fullEventCode = widget.eventCode;
    int year = 2026;
    String code = fullEventCode;

    if (fullEventCode.length >= 4 &&
        int.tryParse(fullEventCode.substring(0, 4)) != null) {
      year = int.parse(fullEventCode.substring(0, 4));
      code = fullEventCode.substring(4);
    }

    final fetchedRankings = await apiService.fetchEventRankings(year, code);
    final fetchedPicklists =
        await apiService.getPicklists(widget.groupName, fullEventCode);

    setState(() {
      rankings = fetchedRankings;
      picklists = fetchedPicklists;
      if (widget.picklistID.isNotEmpty) {
        selectedPicklist = picklists.firstWhere(
            (p) => p.picklist_id == widget.picklistID,
            orElse: () => picklists.first);
        picks = List.from(selectedPicklist!.picks);
      } else if (picklists.isNotEmpty) {
        selectedPicklist = picklists.first;
        picks = List.from(selectedPicklist!.picks);
      } else {
        picks = rankings
            .map((t) => Picks(number: t.team_number, comments: ""))
            .toList();
      }
    });
  }

  void selectPicklist(Picklist2026 picklist) {
    setState(() {
      selectedPicklist = picklist;
      picks = List.from(picklist.picks);
    });
  }

  void createPicklist(String name) {
    final newPicklist = Picklist2026(
      picklist_id: "", // backend can generate ID
      name: name,
      picks: rankings
          .map((t) => Picks(number: t.team_number, comments: ""))
          .toList(),
    );

    setState(() {
      picklists.add(newPicklist);
      selectedPicklist = newPicklist;
      picks = List.from(newPicklist.picks);
    });
  }

  Future<void> savePicklist() async {
    if (selectedPicklist == null) return;

    final updatedPicklist = Picklist2026(
      picklist_id: selectedPicklist!.picklist_id,
      name: selectedPicklist!.name,
      picks: picks,
    );

    final apiService = Provider.of<ApiService>(context, listen: false);

    if (selectedPicklist!.picklist_id.isEmpty) {
      await apiService.addPicklist(
          widget.groupName, widget.eventCode, updatedPicklist);
    } else {
      await apiService.updatePicklist(widget.groupName, widget.eventCode,
          selectedPicklist!.picklist_id, updatedPicklist);
    }

    // Refresh picklists
    await fetchData();
  }

  Future<void> deletePicklist(Picklist2026 picklist) async {
    if (picklist.picklist_id.isEmpty) {
      setState(() {
        picklists.remove(picklist);
        if (selectedPicklist == picklist) {
          selectedPicklist = picklists.isNotEmpty ? picklists.first : null;
          picks = selectedPicklist?.picks ?? [];
        }
      });
      return;
    }

    final apiService = Provider.of<ApiService>(context, listen: false);
    await apiService.deletePicklist(
        widget.groupName, widget.eventCode, picklist.picklist_id);

    setState(() {
      picklists.remove(picklist);
      if (selectedPicklist == picklist) {
        selectedPicklist = picklists.isNotEmpty ? picklists.first : null;
        picks = selectedPicklist?.picks ?? [];
      }
    });
  }

  void addTeam(TeamStats2026 team) {
    setState(() {
      if (!picks.any((p) => p.number == team.team_number)) {
        picks.add(Picks(number: team.team_number, comments: ""));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Picklist for ${widget.eventCode}',
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            /// Rankings/Picklist (drag-reorder)
            Expanded(
              flex: 2,
              child: ReorderableListView.builder(
                itemCount: picks.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = picks.removeAt(oldIndex);
                    picks.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final pick = picks[index];
                  return Card(
                    key: ValueKey(pick.number),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(pick.number),
                      subtitle: pick.comments.isNotEmpty
                          ? Text(
                              pick.comments,
                              style: TextStyle(color: Colors.grey.shade700),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => setState(() {
                          picks.removeAt(index);
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            /// Picklist Selector and Actions
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Text("Picklists",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: picklists.length,
                      itemBuilder: (context, i) {
                        final pl = picklists[i];
                        final selected = pl == selectedPicklist;
                        return Card(
                          color:
                              selected ? Colors.green.shade100 : Colors.white,
                          child: ListTile(
                            title: Text(pl.name),
                            onTap: () => selectPicklist(pl),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deletePicklist(pl),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => openCreateDialog(),
                    child: const Text("Create Picklist"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: savePicklist,
                    child: const Text("Save Picklist"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void openCreateDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Picklist"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Picklist Name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                createPicklist(nameController.text);
                Navigator.pop(context);
              },
              child: const Text("Create")),
        ],
      ),
    );
  }
}

class _TeamDataSource extends DataGridSource {
  _TeamDataSource(
    this.rows,
    this.minValues,
    this.maxValues,
    this.heatMap,
    this.context,
    this.tournament,
    this.scouting,
    this.rankings,
  );

  final Map<String, dynamic> minValues, maxValues, heatMap;
  final List<DataGridRow> rows;
  final BuildContext context;
  final Tournament tournament;
  final List<MatchScouting2026> scouting;
  final List<TeamStats2026> rankings;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = rows.indexOf(row);
    final bool evenRow = rowIndex % 2 == 0;

    // Get reference to picklist state
    final _PicklistPageState? state =
        context.findAncestorStateOfType<_PicklistPageState>();

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        // Determine background color
        final bool useHeatMap =
            heatMap[cell.columnName] != null && heatMap[cell.columnName]!;

        Color bgColor = useHeatMap
            ? _getGradientColor(
                cell.value,
                minValues[cell.columnName],
                maxValues[cell.columnName],
                cell.columnName == 'rank' ||
                    cell.columnName == 'simulated_rank' ||
                    cell.columnName == 'death_rate' ||
                    cell.columnName == 'defense_rate',
              )
            : (evenRow
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0));

        // Check if team is already in picklist
        final String teamNumber = row.getCells()[0].value.toString();
        final bool alreadyInPicklist =
            state?.picks.any((p) => p.number == teamNumber) ?? false;

        if (alreadyInPicklist) {
          bgColor = Colors.grey.shade700; // grey out already-added teams
        }

        return GestureDetector(
          onTap: () {
            if (!alreadyInPicklist && state != null) {
              // Safe add: prevents duplicates
              final team =
                  rankings.firstWhere((t) => t.team_number == teamNumber);
              // ignore: invalid_use_of_protected_member
              state.setState(() {
                state.picks.add(Picks(number: team.team_number, comments: ""));
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.center,
            color: bgColor,
            child: Text(
              '${_formatValue(cell.value)}',
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
