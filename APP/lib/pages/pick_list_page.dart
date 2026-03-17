import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';
import 'dart:html' as html;
import '../models/group.dart';
import '../models/team_stats_2026.dart';
import '../models/picture_data.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _getTeamRank(String teamNumber) {
    final index = rankings.indexWhere((t) => t.team_number == teamNumber);
    if (index == -1) return 0;
    return rankings[index].rank;
  }

  void exportCSV() {
    if (selectedPicklist == null) return;

    List<List<String>> rows = [];

    rows.add([
      "Rank",
      "Comp Rank",
      "Team",
      "Comments",
      "OPR",
      "Auto Points",
      "Teleop Points",
      "Endgame Points",
      "Teleop Pass",
      "Sim RP",
      "Death Rate",
      "Defense Rate"
    ]);

    for (int i = 0; i < picks.length; i++) {
      final pick = picks[i];
      final stats = _getTeamStats(pick.number);

      rows.add([
        (i + 1).toString(),
        stats?.rank.toString() ?? "-",
        pick.number,
        pick.comments ?? "",
        stats?.OPR.toStringAsFixed(2) ?? "",
        stats?.auto_points.toStringAsFixed(2) ?? "",
        stats?.teleop_points.toStringAsFixed(2) ?? "",
        stats?.endgame_points.toStringAsFixed(2) ?? "",
        stats?.teleop_pass.toStringAsFixed(2) ?? "",
        stats?.simulated_rp.toString() ?? "",
        stats?.death_rate.toStringAsFixed(2) ?? "",
        stats?.defense_rate.toStringAsFixed(2) ?? "",
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
        "download",
        "${widget.eventCode}_${selectedPicklist!.name}.csv",
      )
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  Future<void> renamePicklist({
    required String picklistId,
    required String newName,
  }) async {
    if (selectedPicklist == null) return;

    setState(() {
      _saving = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final updatedPicklist = Picklist2026(
        picklist_id: picklistId,
        name: newName,
        picks: selectedPicklist!.picks,
      );

      await apiService.updatePicklist(
          widget.groupName, widget.eventCode, picklistId, updatedPicklist);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rename picklist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  final Map<String, double Function(TeamStats2026)> statFields = {
    "OPR": (t) => t.OPR,
    "Auto Points": (t) => t.auto_points,
    "Teleop Points": (t) => t.teleop_points,
    "Endgame Points": (t) => t.endgame_points,
    "Total Pass": (t) => t.total_pass,
    "Auto Pass": (t) => t.auto_pass,
    "Teleop Pass": (t) => t.teleop_pass,
    "Climbing Points": (t) => t.climbing_points,
    "Auto Fuel Scored": (t) => t.auto_fuel_cycles,
    "Teleop Fuel Scored": (t) => t.teleop_fuel_cycles,
    "Total Fuel Scored": (t) => t.total_fuel_cycles,
    "Foul Points": (t) => t.foul_points,
    "Defense Rate": (t) => t.defense_rate,
    "Death Rate": (t) => t.death_rate,
    "Simulated RP": (t) => t.simulated_rp.toDouble(),
  };

  bool _saving = false;
  String? _highlightedTeam;

  Future<void> _autoSave() async {
    if (_saving) return;
    _saving = true;
    await savePicklist();
    _saving = false;
  }

  List<TeamStats2026> rankings = [];
  List<Picklist2026> picklists = [];
  Picklist2026? selectedPicklist;
  List<Picks> picks = [];

  final Map<String, String> teamNames = {};

  String get _eventYear {
    if (widget.eventCode.length >= 4 &&
        int.tryParse(widget.eventCode.substring(0, 4)) != null) {
      return widget.eventCode.substring(0, 4);
    }
    return "2026";
  }

  int snowCount = 100;
  Map<String, Color> teamColors = {};

  @override
  void initState() {
    super.initState();
    _fetchRankings();
    _setupPicklistWebsocket();
    _loadInitialPicklists();
  }

  @override
  void dispose() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.closePicklistConnection();
    super.dispose();
  }

  Future<void> _loadInitialPicklists() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final initialPicklists =
        await apiService.fetchPicklists(widget.groupName, widget.eventCode);

    setState(() {
      picklists = initialPicklists;
      if (picklists.isNotEmpty) {
        selectedPicklist = picklists.first;
        picks = List.from(selectedPicklist!.picks);
      }
    });

    for (final p in picks) {
      _ensureTeamName(p.number);
    }
  }

  Future<void> _fetchRankings() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    int year = int.parse(_eventYear);
    String code = widget.eventCode;
    if (widget.eventCode.length > 4) {
      code = widget.eventCode.substring(4);
    }

    final fetchedRankings = await apiService.fetchEventRankings(year, code);
    setState(() {
      rankings = fetchedRankings;
    });
  }

  void _setupPicklistWebsocket() {
    final apiService = Provider.of<ApiService>(context, listen: false);

    apiService.getPicklists(
      widget.groupName,
      widget.eventCode,
      (updatedPicklists) {
        setState(() {
          picklists = updatedPicklists;

          if (picklists.isNotEmpty) {
            selectedPicklist = picklists.firstWhere(
              (p) => p.picklist_id == selectedPicklist?.picklist_id,
              orElse: () => picklists.first,
            );
            picks = List.from(selectedPicklist!.picks);
          }
        });

        for (final p in picks) {
          _ensureTeamName(p.number);
        }
      },
    );

    apiService.fetchPicklists(widget.groupName, widget.eventCode);
  }

  void selectPicklist(Picklist2026 picklist) {
    setState(() {
      selectedPicklist = picklist;
      picks = List.from(picklist.picks);
    });

    for (final p in picks) {
      _ensureTeamName(p.number);
    }
  }

  void createPicklist(String name, String field) {
    final getter = statFields[field]!;

    final sortedTeams = [...rankings];
    sortedTeams.sort((a, b) => getter(b).compareTo(getter(a)));

    final newPicklist = Picklist2026(
      picklist_id: "",
      name: name,
      picks: sortedTeams
          .map((t) => Picks(number: t.team_number, comments: ""))
          .toList(),
    );

    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.addPicklist(widget.groupName, widget.eventCode, newPicklist);
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
  }

  Future<void> _confirmDeletePicklist(Picklist2026 picklist) async {
    final controller = TextEditingController();
    bool isMatch = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text("Delete Picklist",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.redAccent)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Type '${picklist.name}' to confirm deletion."),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      hintText: picklist.name,
                    ),
                    onChanged: (val) {
                      setStateDialog(() {
                        isMatch = val == picklist.name;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isMatch ? Colors.redAccent : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isMatch
                      ? () {
                          Navigator.pop(context);
                          deletePicklist(picklist);
                        }
                      : null,
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TeamStats2026? _getTeamStats(String teamNumber) {
    try {
      return rankings.firstWhere((t) => t.team_number == teamNumber);
    } catch (e) {
      return null;
    }
  }

  Future<void> _ensureTeamName(String teamNumber) async {
    if (teamNames.containsKey(teamNumber)) return;
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final nickname = await apiService.fetchTeamNicknames('frc$teamNumber');
      if (mounted) {
        setState(() {
          teamNames[teamNumber] = nickname ?? "";
        });
      }
    } catch (e) {}
  }

  void openCreateDialog() {
    final nameController = TextEditingController();
    String selectedField = statFields.keys.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final isValid = nameController.text.trim().isNotEmpty;
            final theme = Theme.of(context);
            final cs = theme.colorScheme;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text("Create Picklist",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Picklist Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                    ),
                    onChanged: (val) {
                      setStateDialog(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedField,
                    decoration: InputDecoration(
                      labelText: "Initial Sort Metric",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                    ),
                    items: statFields.keys
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() => selectedField = value!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isValid ? cs.primary : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isValid
                      ? () {
                          createPicklist(
                              nameController.text.trim(), selectedField);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openQuickCompare() {
    if (picks.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough teams to compare!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return QuickCompareDialog(
          picks: picks,
          rankings: rankings,
          eventYear: int.parse(_eventYear),
          eventCode: widget.eventCode,
          onSwap: (idx1, idx2) {
            setState(() {
              final temp = picks[idx1];
              picks[idx1] = picks[idx2];
              picks[idx2] = temp;
              _triggerHighlight(picks[idx1].number);
              _triggerHighlight(picks[idx2].number);
            });
            _autoSave();
          },
          teamNames: teamNames,
        );
      },
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  void _triggerHighlight(String teamNumber) {
    setState(() {
      _highlightedTeam = teamNumber;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _highlightedTeam = null;
        });
      }
    });
  }

  void _moveTop(int index) {
    if (index <= 0) return;
    setState(() {
      final item = picks.removeAt(index);
      picks.insert(0, item);
      _triggerHighlight(item.number);
    });
    _autoSave();
  }

  void _moveUp(int index) {
    if (index <= 0) return;
    setState(() {
      final item = picks.removeAt(index);
      picks.insert(index - 1, item);
      _triggerHighlight(item.number);
    });
    _autoSave();
  }

  void _moveDown(int index) {
    if (index >= picks.length - 1) return;
    setState(() {
      final item = picks.removeAt(index);
      picks.insert(index + 1, item);
      _triggerHighlight(item.number);
    });
    _autoSave();
  }

  void _moveToBottom(int index) {
    if (index >= picks.length - 1) return;
    setState(() {
      final item = picks.removeAt(index);
      picks.add(item);
      _triggerHighlight(item.number);
    });
    _autoSave();
  }

  Future<void> _editCommentsDialog(int index) async {
    final pick = picks[index];
    final controller = TextEditingController(text: pick.comments);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Edit Comments for Team ${pick.number}"),
          content: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 6,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: "Enter comments",
              filled: true,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text("Save")),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        picks[index] = Picks(number: pick.number, comments: result);
      });
      _autoSave();
    }
  }

  Widget _buildDrawerMenu(ThemeData theme, ColorScheme cs) {
    return Drawer(
      backgroundColor: theme.cardColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.list, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Picklists",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface),
                  ),
                  const Spacer(),
                  if (_saving)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: picklists.isEmpty
                    ? Center(
                        child: Text("No picklists found",
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.6))),
                      )
                    : ListView.builder(
                        itemCount: picklists.length,
                        itemBuilder: (context, i) {
                          final pl = picklists[i];
                          final isSelected = pl == selectedPicklist;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Material(
                              color: isSelected
                                  ? cs.primary.withOpacity(0.06)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  selectPicklist(pl);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? cs.primary
                                          : Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      pl.name,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? cs.primary
                                            : cs.onSurface.withOpacity(0.9),
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert,
                                                size: 20),
                                            onSelected: (value) async {
                                              if (value == 'rename') {
                                                final newName =
                                                    await showDialog<String>(
                                                  context: context,
                                                  builder: (context) {
                                                    String tempName = pl.name;
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Rename Picklist'),
                                                      content: TextField(
                                                        autofocus: true,
                                                        controller:
                                                            TextEditingController(
                                                                text: pl.name),
                                                        onChanged: (val) =>
                                                            tempName = val,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'Picklist Name',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(
                                                                      tempName),
                                                          child: const Text(
                                                              'Rename'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (newName != null &&
                                                    newName.trim().isNotEmpty) {
                                                  await renamePicklist(
                                                    picklistId: pl.picklist_id,
                                                    newName: newName.trim(),
                                                  );
                                                }
                                              } else if (value == 'delete') {
                                                _confirmDeletePicklist(pl);
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'rename',
                                                child: Text('Rename'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.redAccent),
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              GlassButton(
                color: cs.primary,
                onPressed: () {
                  Navigator.pop(context);
                  openCreateDialog();
                },
                icon: Icons.add,
                label: "New Picklist",
              ),
              const SizedBox(height: 10),
              GlassButton(
                color: cs.secondary,
                onPressed: () {
                  Navigator.pop(context);
                  _openQuickCompare();
                },
                icon: Icons.compare_arrows,
                label: "Quick Compare",
              ),
              const SizedBox(height: 10),
              GlassButton(
                color: Colors.green,
                onPressed: exportCSV,
                icon: Icons.download,
                label: "Export CSV",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTeamImages(String teamNumber) async {
    final eventYear = int.parse(_eventYear);
    String eventCode = widget.eventCode;
    // Extract just the event code without the year
    if (eventCode.length > 4) {
      eventCode = eventCode.substring(4);
    }

    showDialog(
      context: context,
      builder: (context) {
        return TeamImagesDialog(
          teamNumber: teamNumber,
          eventYear: eventYear,
          eventCode: eventCode, // Use the cleaned event code
          rankings: rankings,
          picklistIndex: picks.indexWhere((p) => p.number == teamNumber) + 1,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar:
          PolarForecastAppBar(extraText: 'Picklist for ${widget.eventCode}'),
      endDrawer: _buildDrawerMenu(theme, cs),
      floatingActionButton: Builder(
        builder: (context) {
          return GlassRoundButton(
            color: cs.primary,
            icon: Icons.menu,
            tooltip: 'Open Picklist Panel',
            onPressed: () {
              try {
                _scaffoldKey.currentState?.openEndDrawer();
              } catch (_) {
                Scaffold.of(context).openEndDrawer();
              }
            },
          );
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: SnowField(
                particleCount: snowCount,
                color: cs.onBackground,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: picks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt,
                              size: 72, color: cs.onSurface.withOpacity(0.14)),
                          const SizedBox(height: 16),
                          Text(
                            "No teams in this picklist yet.",
                            style: TextStyle(
                                fontSize: 18,
                                color: cs.onSurface.withOpacity(0.6)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Create a new picklist or add teams from rankings.",
                            style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurface.withOpacity(0.5)),
                          )
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: picks.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = picks.removeAt(oldIndex);
                          picks.insert(newIndex, item);
                          _triggerHighlight(item.number);
                        });
                        _autoSave();
                      },
                      itemBuilder: (context, index) {
                        final pick = picks[index];

                        final tbaProxyAvatar =
                            'https://images.weserv.nl/?url=www.thebluealliance.com/avatar/$_eventYear/frc${pick.number}.png&w=96&h=96&fit=contain';
                        final dicebearAvatar =
                            'https://api.dicebear.com/9.x/identicon/png?seed=frc${pick.number}&size=64';

                        final teamStats = _getTeamStats(pick.number);

                        final tint = teamColors[pick.number];
                        final cardTint = tint != null
                            ? tint.withOpacity(0.08)
                            : cs.surfaceVariant;

                        bool isFirst = index == 0;
                        bool isLast = index == picks.length - 1;
                        bool isHighlighted = _highlightedTeam == pick.number;

                        Color trophyColorForRank(int rank) {
                          if (rank == 1) return Colors.amber;
                          if (rank == 2) return Colors.grey;
                          if (rank == 3) return const Color(0xFFcd7f32);
                          return cs.primary;
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          key: ValueKey(pick.number),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isHighlighted
                                ? [
                                    BoxShadow(
                                        color: cs.primary.withOpacity(0.4),
                                        blurRadius: 16,
                                        spreadRadius: 2)
                                  ]
                                : [],
                          ),
                          child: Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isHighlighted
                                    ? cs.primary.withOpacity(0.6)
                                    : cs.outline.withOpacity(0.12),
                                width: isHighlighted ? 1.5 : 1.0,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 6, sigmaY: 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              cardTint,
                                              cardTint.withOpacity(0.02)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '#${index + 1}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: cs.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Icon(
                                              Icons.emoji_events,
                                              size: 20,
                                              color: trophyColorForRank(
                                                  teamStats?.rank ?? 0),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              teamStats != null
                                                  ? '#${teamStats.rank}'
                                                  : '-',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: trophyColorForRank(
                                                    teamStats?.rank ?? 0),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            ReorderableDragStartListener(
                                              index: index,
                                              child: Icon(
                                                Icons.drag_handle,
                                                size: 22,
                                                color: cs.onSurface
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          _openTeamImages(pick.number);
                                        },
                                        child: TeamAvatar(
                                          primaryUrl: tbaProxyAvatar,
                                          fallbackUrl: dicebearAvatar,
                                          teamNumber: pick.number,
                                          size: 40,
                                          onColor: (color) {
                                            if (color != null) {
                                              setState(() {
                                                teamColors[pick.number] = color;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/event/${widget.eventCode}/team/frc${pick.number}',
                                                    );
                                                  },
                                                  child: Text(
                                                    "${pick.number}${teamNames[pick.number] != null && teamNames[pick.number]!.isNotEmpty ? ' | ${teamNames[pick.number]}' : ''}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: cs.onSurface,
                                                    ),
                                                  ),
                                                ),
                                                if (teamStats != null) ...[
                                                  _buildStatBadge(
                                                      "OPR",
                                                      teamStats.OPR
                                                          .toStringAsFixed(1),
                                                      Colors.purple),
                                                  _buildStatBadge(
                                                      "Auto",
                                                      teamStats.auto_points
                                                          .toStringAsFixed(1),
                                                      Colors.green),
                                                  _buildStatBadge(
                                                      "Teleop",
                                                      teamStats.teleop_points
                                                          .toStringAsFixed(1),
                                                      Colors.orange),
                                                  _buildStatBadge(
                                                      "Pass",
                                                      teamStats.teleop_pass
                                                          .toStringAsFixed(1),
                                                      Colors.blue),
                                                  _buildStatBadge(
                                                      "Death",
                                                      '${(teamStats.death_rate * 100).toStringAsFixed(0)}%',
                                                      Colors.red),
                                                  _buildStatBadge(
                                                      "Def",
                                                      '${(teamStats.defense_rate * 100).toStringAsFixed(0)}%',
                                                      Colors.brown),
                                                  _buildStatBadge(
                                                      "Sim RP",
                                                      teamStats.simulated_rp
                                                          .toString(),
                                                      Colors.teal),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: cs.surfaceVariant,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: cs.outline
                                                              .withOpacity(
                                                                  0.06)),
                                                    ),
                                                    child: Text(
                                                      pick.comments.isEmpty
                                                          ? "No comments."
                                                          : pick.comments,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: cs.onSurface
                                                            .withOpacity(0.85),
                                                        fontStyle: pick.comments
                                                                .isEmpty
                                                            ? FontStyle.normal
                                                            : FontStyle.italic,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.edit,
                                                      size: 18,
                                                      color: cs.onSurface
                                                          .withOpacity(0.7)),
                                                  onPressed: () =>
                                                      _editCommentsDialog(
                                                          index),
                                                  tooltip: "Edit comments",
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 72,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: AnimatedOpacity(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    opacity:
                                                        isFirst ? 0.3 : 1.0,
                                                    child: GlassIconButton(
                                                      icon: Icons
                                                          .keyboard_arrow_up,
                                                      color: cs.onSurface,
                                                      tooltip: 'Move up 1',
                                                      onPressed: isFirst
                                                          ? null
                                                          : () =>
                                                              _moveUp(index),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: AnimatedOpacity(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    opacity: isLast ? 0.3 : 1.0,
                                                    child: GlassIconButton(
                                                      icon: Icons
                                                          .keyboard_arrow_down,
                                                      color: cs.onSurface,
                                                      tooltip: 'Move down 1',
                                                      onPressed: isLast
                                                          ? null
                                                          : () =>
                                                              _moveDown(index),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: AnimatedOpacity(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    opacity:
                                                        isFirst ? 0.3 : 1.0,
                                                    child: GlassIconButton(
                                                      icon: Icons
                                                          .vertical_align_top,
                                                      color: Colors.green,
                                                      tooltip: 'Move to top',
                                                      onPressed: isFirst
                                                          ? null
                                                          : () =>
                                                              _moveTop(index),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: AnimatedOpacity(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    opacity: isLast ? 0.3 : 1.0,
                                                    child: GlassIconButton(
                                                      icon: Icons
                                                          .vertical_align_bottom,
                                                      color: Colors.orange,
                                                      tooltip: 'Move to bottom',
                                                      onPressed: isLast
                                                          ? null
                                                          : () => _moveToBottom(
                                                              index),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickCompareDialog extends StatefulWidget {
  final List<Picks> picks;
  final List<TeamStats2026> rankings;
  final int eventYear;
  final String eventCode;
  final void Function(int index1, int index2) onSwap;
  final Map<String, String> teamNames;

  const QuickCompareDialog({
    super.key,
    required this.picks,
    required this.rankings,
    required this.eventYear,
    required this.eventCode,
    required this.onSwap,
    required this.teamNames,
  });

  @override
  State<QuickCompareDialog> createState() => _QuickCompareDialogState();
}

class _QuickCompareDialogState extends State<QuickCompareDialog> {
  int leftIndex = 0;
  int rightIndex = 1;

  List<PictureData> teamAImages = [];
  List<PictureData> teamBImages = [];
  bool isLoading = false;
  final Map<String, String> names = {};

  @override
  void initState() {
    super.initState();
    names.addAll(widget.teamNames);
    if (widget.picks.length > 1) {
      leftIndex = 0;
      rightIndex = 1;
    }
    _loadPair();
  }

  Future<void> _loadPair() async {
    if (widget.picks.length < 2) return;
    if (leftIndex < 0 || leftIndex >= widget.picks.length) return;
    if (rightIndex < 0 || rightIndex >= widget.picks.length) return;
    if (leftIndex == rightIndex) return;

    setState(() => isLoading = true);
    final a = widget.picks[leftIndex].number;
    final b = widget.picks[rightIndex].number;

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Extract the event code without the year
      String eventCode = widget.eventCode;
      if (eventCode.length > 4) {
        eventCode = eventCode.substring(4);
      }

      final futures = await Future.wait([
        apiService.fetchTeamImages(widget.eventYear, eventCode, 'frc$a'),
        apiService.fetchTeamImages(widget.eventYear, eventCode, 'frc$b'),
        apiService.fetchTeamNicknames('frc$a'),
        apiService.fetchTeamNicknames('frc$b'),
      ]);

      setState(() {
        teamAImages = futures[0] as List<PictureData>;
        teamBImages = futures[1] as List<PictureData>;
        final nA = futures[2] as String?;
        final nB = futures[3] as String?;
        if (nA != null && nA.isNotEmpty) names[a] = nA;
        if (nB != null && nB.isNotEmpty) names[b] = nB;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  TeamStats2026? _statsFor(String teamNumber) {
    try {
      return widget.rankings.firstWhere((t) => t.team_number == teamNumber);
    } catch (_) {
      return null;
    }
  }

  void _handleLike(String likedTeamNumber) {
    if (leftIndex == rightIndex) return;

    final idxA = leftIndex;
    final idxB = rightIndex;
    final teamA = widget.picks[idxA].number;
    final teamB = widget.picks[idxB].number;
    final originalLowerIndex = max(idxA, idxB);

    if (likedTeamNumber == teamA && idxA > idxB) {
      widget.onSwap(idxB, idxA);
    } else if (likedTeamNumber == teamB && idxB > idxA) {
      widget.onSwap(idxA, idxB);
    }

    final loserTeam = likedTeamNumber == teamA ? teamB : teamA;
    final loserIndex = widget.picks.indexWhere((p) => p.number == loserTeam);
    int nextIndex = originalLowerIndex + 1;

    if (nextIndex == loserIndex) {
      nextIndex += 1;
    }

    if (loserIndex != -1 && nextIndex >= 0 && nextIndex < widget.picks.length) {
      setState(() {
        leftIndex = loserIndex;
        rightIndex = nextIndex;
      });
      _loadPair();
      return;
    }

    final updatedAIndex = widget.picks.indexWhere((p) => p.number == teamA);
    final updatedBIndex = widget.picks.indexWhere((p) => p.number == teamB);
    if (updatedAIndex != -1 && updatedBIndex != -1) {
      setState(() {
        leftIndex = updatedAIndex;
        rightIndex = updatedBIndex;
      });
    }

    _loadPair();
  }

  Future<void> _showImagePreview(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          backgroundColor: Colors.black87,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTeam({required bool leftSide}) async {
    final currentTeam = leftSide
        ? widget.picks[leftIndex].number
        : widget.picks[rightIndex].number;
    String search = '';

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = widget.picks
                .where(
                  (p) => _teamLabel(p.number)
                      .toLowerCase()
                      .contains(search.toLowerCase()),
                )
                .toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search team number or name',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setSheetState(() => search = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final team = filtered[index].number;
                          final isSelected = team == currentTeam;
                          return ListTile(
                            dense: true,
                            title: Text(
                              _teamLabel(team),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing:
                                isSelected ? const Icon(Icons.check) : null,
                            onTap: () => Navigator.pop(context, team),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;
    final newIndex = widget.picks.indexWhere((p) => p.number == selected);
    if (newIndex == -1) return;

    setState(() {
      if (leftSide) {
        leftIndex = newIndex;
        if (leftIndex == rightIndex) {
          rightIndex = (leftIndex + 1) % widget.picks.length;
        }
      } else {
        rightIndex = newIndex;
        if (leftIndex == rightIndex) {
          leftIndex =
              (rightIndex - 1 + widget.picks.length) % widget.picks.length;
        }
      }
    });
    _loadPair();
  }

  Widget _glassContainer({required Widget child, double radius = 12}) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.18),
            border: Border.all(color: cs.outline.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: child,
        ),
      ),
    );
  }

  String _teamLabel(String teamNumber) {
    final nickname = names[teamNumber];
    if (nickname != null && nickname.isNotEmpty) {
      return '$teamNumber | $nickname';
    }
    return teamNumber;
  }

  String _formatMetric(_CompareMetric metric, double value) {
    if (metric.asPercent) {
      return '${(value * 100).toStringAsFixed(1)}%';
    }
    if (metric.integerLike) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  List<_CompareMetric> _buildMetrics(TeamStats2026? a, TeamStats2026? b) {
    return [
      _CompareMetric(
          'Comp Rank', (a?.rank ?? 0).toDouble(), (b?.rank ?? 0).toDouble(),
          lowerIsBetter: true, integerLike: true),
      _CompareMetric('Sim Rank', (a?.simulated_rank ?? 0).toDouble(),
          (b?.simulated_rank ?? 0).toDouble(),
          lowerIsBetter: true, integerLike: true),
      _CompareMetric('OPR Rank', (a?.OPRRank ?? 0).toDouble(),
          (b?.OPRRank ?? 0).toDouble(),
          lowerIsBetter: true, integerLike: true),
      _CompareMetric('OPR', a?.OPR ?? 0, b?.OPR ?? 0),
      _CompareMetric('Auto Points', a?.auto_points ?? 0, b?.auto_points ?? 0),
      _CompareMetric(
          'Teleop Points', a?.teleop_points ?? 0, b?.teleop_points ?? 0),
      _CompareMetric(
          'Endgame Points', a?.endgame_points ?? 0, b?.endgame_points ?? 0),
      _CompareMetric(
          'Climbing Points', a?.climbing_points ?? 0, b?.climbing_points ?? 0),
      _CompareMetric('Total Pass', a?.total_pass ?? 0, b?.total_pass ?? 0),
      _CompareMetric('Auto Pass', a?.auto_pass ?? 0, b?.auto_pass ?? 0),
      _CompareMetric('Teleop Pass', a?.teleop_pass ?? 0, b?.teleop_pass ?? 0),
      _CompareMetric(
          'Auto Fuel', a?.auto_fuel_cycles ?? 0, b?.auto_fuel_cycles ?? 0),
      _CompareMetric('Teleop Fuel', a?.teleop_fuel_cycles ?? 0,
          b?.teleop_fuel_cycles ?? 0),
      _CompareMetric(
          'Total Fuel', a?.total_fuel_cycles ?? 0, b?.total_fuel_cycles ?? 0),
      _CompareMetric('Foul Points', a?.foul_points ?? 0, b?.foul_points ?? 0,
          lowerIsBetter: true),
      _CompareMetric('Death Rate', a?.death_rate ?? 0, b?.death_rate ?? 0,
          lowerIsBetter: true, asPercent: true),
      _CompareMetric('Defense Rate', a?.defense_rate ?? 0, b?.defense_rate ?? 0,
          asPercent: true),
      _CompareMetric('Sim RP', (a?.simulated_rp ?? 0).toDouble(),
          (b?.simulated_rp ?? 0).toDouble(),
          integerLike: true),
    ];
  }

  Widget _metricRow(_CompareMetric metric, bool compactMode) {
    final cs = Theme.of(context).colorScheme;
    final tied = (metric.left - metric.right).abs() < 1e-9;
    final leftBetter = metric.lowerIsBetter
        ? metric.left < metric.right
        : metric.left > metric.right;

    final leftBg = tied
        ? cs.surfaceVariant.withOpacity(0.08)
        : leftBetter
            ? Colors.green.withOpacity(0.14)
            : Colors.red.withOpacity(0.08);
    final rightBg = tied
        ? cs.surfaceVariant.withOpacity(0.08)
        : leftBetter
            ? Colors.red.withOpacity(0.08)
            : Colors.green.withOpacity(0.14);

    final leftBorder = tied
        ? cs.outline.withOpacity(0.18)
        : leftBetter
            ? Colors.green.withOpacity(0.5)
            : Colors.red.withOpacity(0.38);
    final rightBorder = tied
        ? cs.outline.withOpacity(0.18)
        : leftBetter
            ? Colors.red.withOpacity(0.38)
            : Colors.green.withOpacity(0.5);

    final labelWidth = compactMode ? 120.0 : 160.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: leftBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: leftBorder),
              ),
              child: Text(
                _formatMetric(metric, metric.left),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: labelWidth,
            child: Text(
              metric.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withOpacity(0.85)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: rightBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rightBorder),
              ),
              child: Text(
                _formatMetric(metric, metric.right),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamPanel({
    required String teamNumber,
    required int pickIndex,
    required TeamStats2026? stats,
    required String avatar,
    required String fallback,
    required List<PictureData> images,
  }) {
    final rankColor = trophyColorForRank(stats?.rank ?? 0);
    return _glassContainer(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TeamAvatar(
                  primaryUrl: avatar,
                  fallbackUrl: fallback,
                  teamNumber: teamNumber,
                  size: 52,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _teamLabel(teamNumber),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _pill('Pick #$pickIndex', Colors.blue),
                          _pill(
                              stats != null ? 'Comp #${stats.rank}' : 'Comp #-',
                              rankColor),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 112,
              width: double.infinity,
              child: images.isEmpty
                  ? const Center(child: Text('No images'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final image = images[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _showImagePreview(image.link),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              image.link,
                              width: 128,
                              height: 112,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.34)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.picks.length < 2) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Not enough teams to compare'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ]),
        ),
      );
    }

    if (leftIndex == rightIndex) {
      rightIndex = (leftIndex + 1) % widget.picks.length;
    }

    final aNum = widget.picks[leftIndex].number;
    final bNum = widget.picks[rightIndex].number;
    final aStats = _statsFor(aNum);
    final bStats = _statsFor(bNum);
    final metrics = _buildMetrics(aStats, bStats);

    final aAvatar = teamImageUrl(widget.eventYear, widget.eventCode, aNum);
    final bAvatar = teamImageUrl(widget.eventYear, widget.eventCode, bNum);

    final screen = MediaQuery.of(context).size;
    final dialogWidth = min(1100.0, screen.width * 0.96);
    final dialogHeight = min(860.0, screen.height * 0.9);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(12),
      child: _glassContainer(
        radius: 16,
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTeam(leftSide: true),
                                icon: const Icon(Icons.groups_2_outlined),
                                label: Text(
                                  'Team A: ${_teamLabel(aNum)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTeam(leftSide: false),
                                icon: const Icon(Icons.groups_2_outlined),
                                label: Text(
                                  'Team B: ${_teamLabel(bNum)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Close',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                if (compact)
                                  Column(
                                    children: [
                                      _teamPanel(
                                        teamNumber: aNum,
                                        pickIndex: leftIndex + 1,
                                        stats: aStats,
                                        avatar: aAvatar,
                                        fallback: avatarFallback(aNum),
                                        images: teamAImages,
                                      ),
                                      const SizedBox(height: 10),
                                      _teamPanel(
                                        teamNumber: bNum,
                                        pickIndex: rightIndex + 1,
                                        stats: bStats,
                                        avatar: bAvatar,
                                        fallback: avatarFallback(bNum),
                                        images: teamBImages,
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _teamPanel(
                                          teamNumber: aNum,
                                          pickIndex: leftIndex + 1,
                                          stats: aStats,
                                          avatar: aAvatar,
                                          fallback: avatarFallback(aNum),
                                          images: teamAImages,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _teamPanel(
                                          teamNumber: bNum,
                                          pickIndex: rightIndex + 1,
                                          stats: bStats,
                                          avatar: bAvatar,
                                          fallback: avatarFallback(bNum),
                                          images: teamBImages,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: _glassContainer(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ListView.builder(
                                        itemCount: metrics.length,
                                        itemBuilder: (context, index) =>
                                            _metricRow(metrics[index], compact),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    GlassActionButton(
                                      icon: const Icon(Icons.thumb_up),
                                      label: Text('I like $aNum'),
                                      color: Colors.green,
                                      onPressed: () => _handleLike(aNum),
                                    ),
                                    GlassActionButton(
                                      icon: const Icon(Icons.thumb_up),
                                      label: Text('I like $bNum'),
                                      color: Colors.green,
                                      onPressed: () => _handleLike(bNum),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color trophyColorForRank(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return const Color(0xFFcd7f32);
    return Theme.of(context).colorScheme.primary;
  }

  String teamImageUrl(int year, String eventCode, String teamNumber) {
    return 'https://images.weserv.nl/?url=www.thebluealliance.com/avatar/$year/frc$teamNumber.png&w=256&h=256&fit=contain';
  }

  String avatarFallback(String teamNumber) {
    return 'https://api.dicebear.com/9.x/identicon/png?seed=frc$teamNumber&size=128';
  }

  Widget _statRowComparison(
      String label, double aVal, double bVal, bool invertDeath) {
    return const SizedBox.shrink();
  }
}

class _CompareMetric {
  final String label;
  final double left;
  final double right;
  final bool lowerIsBetter;
  final bool asPercent;
  final bool integerLike;

  const _CompareMetric(
    this.label,
    this.left,
    this.right, {
    this.lowerIsBetter = false,
    this.asPercent = false,
    this.integerLike = false,
  });
}

class TeamImagesDialog extends StatefulWidget {
  final String teamNumber;
  final int eventYear;
  final String eventCode;
  final List<TeamStats2026> rankings;
  final int picklistIndex;

  const TeamImagesDialog({
    super.key,
    required this.teamNumber,
    required this.eventYear,
    required this.eventCode,
    required this.rankings,
    required this.picklistIndex,
  });

  @override
  State<TeamImagesDialog> createState() => _TeamImagesDialogState();
}

class _TeamImagesDialogState extends State<TeamImagesDialog> {
  List<PictureData> images = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final fetched = await apiService.fetchTeamImages(
          widget.eventYear, widget.eventCode, 'frc${widget.teamNumber}');
      if (mounted) {
        setState(() {
          images = fetched;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stats = widget.rankings
        .where((t) => t.team_number == widget.teamNumber)
        .firstOrNull;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 920,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team ${widget.teamNumber} Images',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click on an image to enlarge it.',
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.photo_library_outlined)
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()))
            else if (images.isEmpty)
              SizedBox(
                  height: 220,
                  child: Center(child: Text('No robot images available')))
            else
              SizedBox(
                height: 430,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 780 ? 3 : 2;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, i) {
                        final image = images[i];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    insetPadding: const EdgeInsets.all(24),
                                    backgroundColor: Colors.black87,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: InteractiveViewer(
                                            minScale: 0.8,
                                            maxScale: 4.5,
                                            child: Center(
                                              child: Image.network(image.link,
                                                  fit: BoxFit.contain),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: const Icon(Icons.close,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(image.link, fit: BoxFit.cover),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.35)
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: Icon(
                                    Icons.zoom_in,
                                    color: Colors.white.withOpacity(0.95),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (stats != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _metricChip('Comp Rank', '#${stats.rank}', cs.primary),
                      _metricChip('Picklist', '#${widget.picklistIndex}',
                          Colors.indigo),
                      _metricChip(
                          'OPR', stats.OPR.toStringAsFixed(1), Colors.purple),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _metricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class TeamAvatar extends StatefulWidget {
  final String primaryUrl;
  final String fallbackUrl;
  final String teamNumber;
  final double size;
  final ValueChanged<Color?>? onColor;

  const TeamAvatar({
    super.key,
    required this.primaryUrl,
    required this.fallbackUrl,
    required this.teamNumber,
    this.size = 48,
    this.onColor,
  });

  @override
  State<TeamAvatar> createState() => _TeamAvatarState();
}

class _TeamAvatarState extends State<TeamAvatar> {
  late String _currentUrl;
  bool _showIcon = false;
  bool _triedFallback = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.primaryUrl;
    _showIcon = false;
    _triedFallback = false;
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    try {
      final provider = NetworkImage(_currentUrl);
      final palette = await PaletteGenerator.fromImageProvider(provider,
          maximumColorCount: 6);
      final color = palette.dominantColor?.color ?? palette.vibrantColor?.color;
      if (color != null) widget.onColor?.call(color);
    } catch (e) {}
  }

  void _onImageError(Object _, StackTrace? __) {
    if (!_triedFallback && widget.fallbackUrl.isNotEmpty) {
      setState(() {
        _currentUrl = widget.fallbackUrl;
        _triedFallback = true;
      });
      _generatePalette();
      return;
    }

    setState(() {
      _showIcon = true;
      widget.onColor?.call(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outline.withOpacity(0.12)),
        ),
        child: _showIcon
            ? Center(
                child: Icon(
                  Icons.smart_toy,
                  size: widget.size * 0.54,
                  color: cs.onSurfaceVariant.withOpacity(0.7),
                ),
              )
            : Image.network(
                _currentUrl,
                fit: BoxFit.cover,
                width: widget.size,
                height: widget.size,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: widget.size * 0.36,
                      height: widget.size * 0.36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: cs.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onImageError(error, stackTrace);
                  });
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}

class SnowField extends StatefulWidget {
  final int particleCount;
  final Color color;

  const SnowField({
    super.key,
    this.particleCount = 40,
    this.color = Colors.white,
  });

  @override
  State<SnowField> createState() => _SnowFieldState();
}

class _SnowFieldState extends State<SnowField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_SnowParticle> _particles;
  late DateTime _lastTick;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.particleCount, (i) => _createParticle());
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(_tick);
    _controller.repeat(
        min: 0, max: 1, period: const Duration(milliseconds: 16));
    _lastTick = DateTime.now();
  }

  _SnowParticle _createParticle() {
    return _SnowParticle(
      x: _rnd.nextDouble(),
      y: _rnd.nextDouble(),
      radius: 1.5 + _rnd.nextDouble() * 3,
      speed: 20 + _rnd.nextDouble() * 60,
      drift: -20 + _rnd.nextDouble() * 40,
      opacity: 0.25 + _rnd.nextDouble() * 0.75,
    );
  }

  void _tick() {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    for (final p in _particles) {
      p._logicalY += (p.speed * dt) / 300.0;
      p._logicalX += (p.drift * dt) / 300.0;
      if (p._logicalY > 1.25) {
        p._logicalY = -0.05 - _rnd.nextDouble() * 0.1;
        p._logicalX = _rnd.nextDouble();
      }
      if (p._logicalX < -0.2) p._logicalX = 1.05;
      if (p._logicalX > 1.2) p._logicalX = -0.05;
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SnowPainter(
          _particles, widget.color, MediaQuery.of(context).devicePixelRatio),
      size: Size.infinite,
    );
  }
}

class _SnowParticle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double drift;
  final double opacity;
  double _logicalX;
  double _logicalY;

  _SnowParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.opacity,
  })  : _logicalX = x,
        _logicalY = y;
}

class _SnowPainter extends CustomPainter {
  final List<_SnowParticle> particles;
  final Color baseColor;
  final double devicePixelRatio;

  _SnowPainter(this.particles, this.baseColor, this.devicePixelRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final Color dotColor = baseColor.withOpacity(0.7);

    for (final p in particles) {
      final dx = (p._logicalX.clamp(-0.5, 1.5)) * size.width;
      final dy = (p._logicalY.clamp(-0.5, 1.5)) * size.height;

      paint.color = dotColor.withOpacity(p.opacity * 0.9);
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter old) => true;
}

class GlassButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const GlassButton({
    super.key,
    required this.color,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: color.withOpacity(0.12),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(label, style: TextStyle(color: cs.onPrimaryContainer)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  const GlassIconButton({
    super.key,
    required this.color,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: color.withOpacity(0.12),
          child: Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onPressed,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
                  ),
                ),
                child: Center(
                  child: Icon(icon,
                      color: onPressed == null ? color.withOpacity(0.4) : color,
                      size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassActionButton extends StatelessWidget {
  final Widget icon;
  final Widget label;
  final Color color;
  final VoidCallback onPressed;

  const GlassActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: color.withOpacity(0.14),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.16), color.withOpacity(0.08)],
                ),
                border: Border.all(color: color.withOpacity(0.28)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: color),
                    child: icon,
                  ),
                  const SizedBox(width: 8),
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                    child: label,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassRoundButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const GlassRoundButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: color.withOpacity(0.18),
            child: InkWell(
              onTap: onPressed,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  ),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Icon(icon, color: cs.onPrimaryContainer),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    try {
      return isEmpty ? null : first;
    } catch (e) {
      return null;
    }
  }
}
