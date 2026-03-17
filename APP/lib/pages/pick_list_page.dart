import 'dart:convert';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
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
        pick.comments ?? "",
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

    // THIS IS THE PART YOU WERE MISSING

    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
        "download",
        "${widget.eventCode}_${selectedPicklist!.name}.csv",
      )
      ..click();

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

  // Helper to extract the year for TBA avatars
  String get _eventYear {
    if (widget.eventCode.length >= 4 &&
        int.tryParse(widget.eventCode.substring(0, 4)) != null) {
      return widget.eventCode.substring(0, 4);
    }
    return "2026"; // Fallback
  }

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

  void addTeam(TeamStats2026 team) {
    setState(() {
      if (!picks.any((p) => p.number == team.team_number)) {
        picks.add(Picks(number: team.team_number, comments: ""));
      }
    });
  }

  // Helper function to find a team's stats from the rankings list
  TeamStats2026? _getTeamStats(String teamNumber) {
    try {
      return rankings.firstWhere((t) => t.team_number == teamNumber);
    } catch (e) {
      return null; // Return null if stats aren't loaded or team isn't found
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
                    backgroundColor: Colors.blue, // button background
                    foregroundColor: Colors.white, // text color
                  ),
                  onPressed: () {
                    createPicklist(nameController.text, selectedField);
                    Navigator.pop(context);
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // A visually appealing badge for team stats
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // full page background color (you had Colors.black previously; keep it or change as needed)
      backgroundColor: Colors.black,
      appBar:
          PolarForecastAppBar(extraText: 'Picklist for ${widget.eventCode}'),
      // Use a Stack so we can paint an animated snow background behind the page content.
      body: Stack(
        children: [
          // Snow field is behind everything. It ignores pointer events.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: SnowField(
                // small number of particles by default for performance
                particleCount: 40,
                // pass theme color so snow adapts (light on dark or dark on light)
                color: cs.onBackground,
              ),
            ),
          ),

          // Main content (same as before) sits on top of the snowfield.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Main Picklist Area (Flex 5)
                Expanded(
                  flex: 5,
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
                    padding: const EdgeInsets.all(12),
                    child: picks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.list_alt,
                                    size: 72,
                                    color: cs.onSurface.withOpacity(0.14)),
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
                            buildDefaultDragHandles: true,
                            itemCount: picks.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex--;
                                final item = picks.removeAt(oldIndex);
                                picks.insert(newIndex, item);
                              });
                              _autoSave();
                            },
                            itemBuilder: (context, index) {
                              final pick = picks[index];

                              // Proxied The Blue Alliance avatar URL (uses images.weserv.nl to avoid CORS)
                              final tbaProxyAvatar =
                                  'https://images.weserv.nl/?url=www.thebluealliance.com/avatar/$_eventYear/frc${pick.number}.png&w=96&h=96&fit=contain';

                              // DiceBear fallback (deterministic identicon)
                              final dicebearAvatar =
                                  'https://api.dicebear.com/9.x/identicon/png?seed=frc${pick.number}&size=64';

                              final teamStats = _getTeamStats(pick.number);

                              return Card(
                                key: ValueKey(pick.number),
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: cs.outline.withOpacity(0.12)),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    dense: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Bold Rank Number
                                        Container(
                                          width: 42,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${_getTeamRank(pick.number)}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Avatar (robust to CORS errors)
                                        InkWell(
                                          onTap: () {
                                            final eventCode = widget
                                                .eventCode; // your event code
                                            final teamNumber = pick
                                                .number; // the team's number

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
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: InkWell(
                                      onTap: () {
                                        // Replace with your actual eventCode variable
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
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 6),
                                        // Stat Badges Row
                                        if (teamStats != null)
                                          Wrap(
                                            children: [
                                              _buildStatBadge("OPR",
                                                  teamStats.OPR, Colors.purple),
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

                                        const SizedBox(height: 6),

                                        // Comments TextField
                                        // Comments TextField
                                        Builder(
                                          builder: (context) {
                                            final controller =
                                                TextEditingController(
                                                    text: pick.comments);
                                            final focusNode = FocusNode();

                                            focusNode.addListener(() {
                                              if (!focusNode.hasFocus) {
                                                final value = controller.text;

                                                setState(() {
                                                  picks[index] = Picks(
                                                    number: pick.number,
                                                    comments: value,
                                                  );
                                                });

                                                _autoSave();
                                              }
                                            });

                                            return TextField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              decoration: InputDecoration(
                                                labelText: "Comments",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                filled: true,
                                              ),
                                            );
                                          },
                                        ),

                                        // Finalized Comment display
                                        if (pick.comments.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8,
                                                8,
                                                0,
                                                0), // Aligns with TextField
                                            child: Text(
                                              pick.comments,
                                              style: TextStyle(
                                                color: cs.onSurface
                                                    .withOpacity(0.7),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Remove button
                                        IconButton(
                                          icon: Icon(Icons.close,
                                              color: cs.onSurface
                                                  .withOpacity(0.6)),
                                          tooltip: 'Remove from picklist',
                                          onPressed: () => setState(
                                              () => picks.removeAt(index)),
                                        ),
                                        // Reorder handle (makes drag affordance clearer)
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: Icon(Icons.drag_handle,
                                              color: cs.onSurface
                                                  .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(width: 20),

                /// Sidebar: Picklist Selector (Flex 2)
                Expanded(
                  flex: 2,
                  child: Container(
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
                            // subtle saving indicator (UI-only)
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
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blue)),
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
                                      style: TextStyle(
                                          color:
                                              cs.onSurface.withOpacity(0.6))),
                                )
                              : ListView.builder(
                                  itemCount: picklists.length,
                                  itemBuilder: (context, i) {
                                    final pl = picklists[i];
                                    final isSelected = pl == selectedPicklist;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Material(
                                        color: isSelected
                                            ? cs.primary.withOpacity(0.06)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          onTap: () => selectPicklist(pl),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.grey.shade100,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                      : Colors.grey.shade100,
                                                ),
                                              ),
                                              trailing: isSelected
                                                  ? IconButton(
                                                      icon: const Icon(
                                                          Icons.delete_outline,
                                                          color:
                                                              Colors.redAccent,
                                                          size: 20),
                                                      onPressed: () =>
                                                          deletePicklist(pl),
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
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue, // Button background
                            foregroundColor:
                                Colors.white, // Text and icon color
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: openCreateDialog,
                          icon: const Icon(Icons.add),
                          label: const Text(
                            "New Picklist",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: exportCSV,
                          icon: const Icon(Icons.download),
                          label: const Text(
                            "Export CSV",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
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

/// TeamAvatar: tries `primaryUrl` first, then `fallbackUrl`, then shows robot icon if both fail.
/// Uses theme colors for loaders and borders.
class TeamAvatar extends StatefulWidget {
  final String primaryUrl;
  final String fallbackUrl;
  final String teamNumber;
  final double size;

  const TeamAvatar({
    super.key,
    required this.primaryUrl,
    required this.fallbackUrl,
    required this.teamNumber,
    this.size = 48,
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
    // Start with the proxied TBA avatar (or whatever primaryUrl the parent provided).
    _currentUrl = widget.primaryUrl;
    _showIcon = false;
    _triedFallback = false;
  }

  void _onImageError(Object _, StackTrace? __) {
    if (!_triedFallback && widget.fallbackUrl.isNotEmpty) {
      // Try the fallback (DiceBear) once
      setState(() {
        _currentUrl = widget.fallbackUrl;
        _triedFallback = true;
      });
      return;
    }

    // final fallback failed — show robot icon
    setState(() {
      _showIcon = true;
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
                // loader that uses theme primary color
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
                  // call error handler to progress the fallback/show icon
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onImageError(error, stackTrace);
                  });
                  // show an empty container while we switch to fallback or icon
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}

/// SnowField: lightweight animated dot/snowfield drawn behind the UI.
/// It uses a CustomPainter and an AnimationController. The parent places it behind the content,
/// so it will never cover interactive cards.
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
    // We initialize with normalized positions; real canvas size will be applied on the paint step.
    return _SnowParticle(
      x: _rnd.nextDouble(), // 0..1
      y: _rnd.nextDouble(), // 0..1
      radius: 1.5 + _rnd.nextDouble() * 3, // 1.5..5.0
      speed: 20 + _rnd.nextDouble() * 60, // pixels per second (approx)
      drift: -20 + _rnd.nextDouble() * 40, // horizontal drift in px/sec
      opacity: 0.25 + _rnd.nextDouble() * 0.75,
    );
  }

  void _tick() {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    // update logical positions (normalized)
    for (final p in _particles) {
      // We'll update y/x as normalized values using canvas size later. To avoid coupling to size here,
      // we'll store velocities as px/sec and update normalized positions when painting. But for simplicity,
      // update using normalized approximation:
      p._logicalY += (p.speed * dt) /
          300.0; // heuristic divisor to keep motion pleasant regardless of canvas
      p._logicalX += (p.drift * dt) / 300.0;
      // wrap around
      if (p._logicalY > 1.25) {
        p._logicalY = -0.05 - _rnd.nextDouble() * 0.1;
        p._logicalX = _rnd.nextDouble();
      }
      if (p._logicalX < -0.2) p._logicalX = 1.05;
      if (p._logicalX > 1.2) p._logicalX = -0.05;
    }

    // repaint
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
    // The painter respects the canvas size; snow remains behind content because parent placed this widget first inside a Stack.
    return CustomPaint(
      painter: _SnowPainter(
          _particles, widget.color, MediaQuery.of(context).devicePixelRatio),
      size: Size.infinite,
    );
  }
}

class _SnowParticle {
  double x; // initial normalized x
  double y; // initial normalized y
  final double radius;
  final double speed; // px/sec (heuristic)
  final double drift; // px/sec
  final double opacity;

  // internal logical positions used by update loop
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
    // make color subtle and theme-aware
    final Color dotColor = baseColor.withOpacity(0.7);

    for (final p in particles) {
      // convert normalized logical positions to pixel coordinates
      final dx = (p._logicalX.clamp(-0.5, 1.5)) * size.width;
      final dy = (p._logicalY.clamp(-0.5, 1.5)) * size.height;

      paint.color = dotColor.withOpacity(p.opacity * 0.9);
      // Draw as a circle (snowflake dot)
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter old) => true;
}
