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
  int _getTeamRank(String teamNumber) {
    final index = rankings.indexWhere((t) => t.team_number == teamNumber);
    if (index == -1) return 0;
    return index + 1;
  }

  void exportCSV() {
    if (selectedPicklist == null) return;

    List<List<String>> rows = [];

    rows.add([
      "Rank",
      "Team",
      "Comments",
      "OPR",
      "Auto Points",
      "Teleop Points",
      "Endgame Points"
    ]);

    for (int i = 0; i < picks.length; i++) {
      final pick = picks[i];
      final stats = _getTeamStats(pick.number);

      rows.add([
        (i + 1).toString(),
        pick.number,
        pick.comments,
        stats?.OPR.toStringAsFixed(2) ?? "",
        stats?.auto_points.toStringAsFixed(2) ?? "",
        stats?.teleop_points.toStringAsFixed(2) ?? "",
        stats?.endgame_points.toStringAsFixed(2) ?? "",
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.Url.revokeObjectUrl(url);
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

  String get _eventYear {
    if (widget.eventCode.length >= 4 &&
        int.tryParse(widget.eventCode.substring(0, 4)) != null) {
      return widget.eventCode.substring(0, 4);
    }
    return "2026";
  }

  int snowCount = 40;
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
      },
    );

    apiService.fetchPicklists(widget.groupName, widget.eventCode);
  }

  void selectPicklist(Picklist2026 picklist) {
    setState(() {
      selectedPicklist = picklist;
      picks = List.from(picklist.picks);
    });
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
              title: const Text("Delete Picklist",
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

  void addTeam(TeamStats2026 team) {
    setState(() {
      if (!picks.any((p) => p.number == team.team_number)) {
        picks.add(Picks(number: team.team_number, comments: ""));
      }
    });
  }

  TeamStats2026? _getTeamStats(String teamNumber) {
    try {
      return rankings.firstWhere((t) => t.team_number == teamNumber);
    } catch (e) {
      return null;
    }
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
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text("Create Picklist",
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
                      setStateDialog(
                          () {}); // Trigger rebuild to update validation
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
                    backgroundColor: isValid ? Colors.blue : Colors.grey,
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

  Widget _buildStatBadge(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}',
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
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
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text("Save")),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 800;

    final Widget teamsListPane = Container(
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
      padding: const EdgeInsets.all(12),
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
                        fontSize: 18, color: cs.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Create a new picklist or add teams from rankings.",
                    style: TextStyle(
                        fontSize: 13, color: cs.onSurface.withOpacity(0.5)),
                  )
                ],
              ),
            )
          : ReorderableListView.builder(
              buildDefaultDragHandles: true,
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
                final cardTint =
                    tint != null ? tint.withOpacity(0.08) : cs.surfaceVariant;

                bool isFirst = index == 0;
                bool isLast = index == picks.length - 1;
                bool isHighlighted = _highlightedTeam == pick.number;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  key: ValueKey(pick.number),
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
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
                              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Replaced ListTile with a Custom Row to remove trailing height constraints
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Rank
                              Container(
                                width: 42,
                                alignment: Alignment.center,
                                child: Text(
                                  '${_getTeamRank(pick.number)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Avatar
                              InkWell(
                                onTap: () {
                                  final eventCode = widget.eventCode;
                                  final teamNumber = pick.number;
                                  Navigator.pushNamed(
                                    context,
                                    '/event/$eventCode/team/frc$teamNumber',
                                  );
                                },
                                child: TeamAvatar(
                                  primaryUrl: tbaProxyAvatar,
                                  fallbackUrl: dicebearAvatar,
                                  teamNumber: pick.number,
                                  size: 48,
                                  onColor: (color) {
                                    if (color != null) {
                                      setState(() {
                                        teamColors[pick.number] = color;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Main Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        final eventCode = widget.eventCode;
                                        Navigator.pushNamed(
                                          context,
                                          '/event/$eventCode/team/frc${pick.number}',
                                        );
                                      },
                                      child: Text(
                                        "Team ${pick.number}",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (teamStats != null)
                                      Wrap(
                                        children: [
                                          _buildStatBadge("OPR", teamStats.OPR,
                                              Colors.purple),
                                          _buildStatBadge(
                                              "Auto",
                                              teamStats.auto_points,
                                              Colors.green),
                                          _buildStatBadge(
                                              "Teleop",
                                              teamStats.teleop_points,
                                              Colors.orange),
                                        ],
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: cs.surfaceVariant,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: cs.outline
                                                      .withOpacity(0.06)),
                                            ),
                                            child: Text(
                                              pick.comments.isEmpty
                                                  ? "No comments. Tap edit to add."
                                                  : pick.comments,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: cs.onSurface
                                                    .withOpacity(0.85),
                                                fontStyle: pick.comments.isEmpty
                                                    ? FontStyle.normal
                                                    : FontStyle.italic,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              size: 20,
                                              color: cs.onSurface
                                                  .withOpacity(0.7)),
                                          onPressed: () =>
                                              _editCommentsDialog(index),
                                          tooltip: "Edit comments",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Trailing Controls (Now free to expand vertically)
                              SizedBox(
                                width: 86,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AnimatedOpacity(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            opacity: isFirst ? 0.3 : 1.0,
                                            child: GlassIconButton(
                                              icon: Icons.keyboard_arrow_up,
                                              color: cs.onSurface,
                                              tooltip: 'Move up 1',
                                              onPressed: isFirst
                                                  ? null
                                                  : () => _moveUp(index),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: AnimatedOpacity(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            opacity: isLast ? 0.3 : 1.0,
                                            child: GlassIconButton(
                                              icon: Icons.keyboard_arrow_down,
                                              color: cs.onSurface,
                                              tooltip: 'Move down 1',
                                              onPressed: isLast
                                                  ? null
                                                  : () => _moveDown(index),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      opacity: isLast ? 0.3 : 1.0,
                                      child: GlassIconButton(
                                        icon: Icons.vertical_align_bottom,
                                        color: Colors.orange,
                                        tooltip: 'Move to bottom',
                                        onPressed: isLast
                                            ? null
                                            : () => _moveToBottom(index),
                                      ),
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
    );

    final Widget controlsPane = Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: cs.outline.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                "Your Picklists",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface),
              ),
              const Spacer(),
              if (_saving)
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.blue),
                      ),
                      const SizedBox(width: 6),
                      Text("Saving...",
                          style: TextStyle(fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: picklists.isEmpty
                ? Center(
                    child: Text("No picklists found",
                        style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
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
                            onTap: () => selectPicklist(pl),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
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
                                        ? Colors.blue
                                        : cs.onSurface.withOpacity(0.9),
                                  ),
                                ),
                                trailing: isSelected
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.redAccent, size: 20),
                                        onPressed: () =>
                                            _confirmDeletePicklist(pl),
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
            color: Colors.blue,
            onPressed: openCreateDialog,
            icon: Icons.add,
            label: "New Picklist",
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
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          PolarForecastAppBar(extraText: 'Picklist for ${widget.eventCode}'),
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
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? Column(
                    children: [
                      Flexible(flex: 3, child: controlsPane),
                      const SizedBox(height: 16),
                      Expanded(flex: 5, child: teamsListPane),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: teamsListPane),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: controlsPane),
                    ],
                  ),
          ),
        ],
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
      borderRadius: BorderRadius.circular(10),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
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
