import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:csv/csv.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:scouting_app/models/pit_scouting_2026.dart';
import 'package:scouting_app/utils/download_stub.dart';
import 'package:scouting_app/widgets/auto_display_2026.dart';
import 'package:scouting_app/widgets/auto_pieces_2026.dart';
import 'package:scouting_app/widgets/login_widget.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';
import '../models/group.dart';
import '../models/team_stats_2026.dart';
import '../models/picture_data.dart';
import '../models/tournament.dart';
import '../widgets/deaths_form.dart';

final CacheManager picklistAvatarCacheManager = CacheManager(
  Config(
    'picklistAvatarCache',
    stalePeriod: const Duration(days: 14),
    maxNrOfCacheObjects: 600,
  ),
);

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
  final Set<String> _warmedAvatarUrls = {};

  void exportCSV() {
    if (selectedPicklist == null) return;

    List<List<String>> rows = [];

    rows.add([
      'Rank',
      'Comp Rank',
      'Team',
      'Comments',
      'OPR',
      'Auto Points',
      'Teleop Points',
      'Endgame Points',
      'Teleop Pass',
      'Sim RP',
      'Death Rate',
      'Defense Rate'
    ]);

    for (int i = 0; i < picks.length; i++) {
      final pick = picks[i];
      final stats = _getTeamStats(pick.number);

      rows.add([
        (i + 1).toString(),
        stats?.rank.toString() ?? '-',
        pick.number,
        pick.comments,
        stats?.OPR.toStringAsFixed(2) ?? '',
        stats?.auto_points.toStringAsFixed(2) ?? '',
        stats?.teleop_points.toStringAsFixed(2) ?? '',
        stats?.endgame_points.toStringAsFixed(2) ?? '',
        stats?.teleop_pass.toStringAsFixed(2) ?? '',
        stats?.simulated_rp.toString() ?? '',
        stats?.death_rate.toStringAsFixed(2) ?? '',
        stats?.defense_rate.toStringAsFixed(2) ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);

    // ✅ FIX: use cross-platform helper
    downloadFile(
      bytes,
      '${widget.eventCode}_${selectedPicklist!.name}.csv',
    );
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
    'OPR': (t) => t.OPR,
    'Auto Points': (t) => t.auto_points,
    'Teleop Points': (t) => t.teleop_points,
    'Endgame Points': (t) => t.endgame_points,
    'Total Pass': (t) => t.total_pass,
    'Auto Pass': (t) => t.auto_pass,
    'Teleop Pass': (t) => t.teleop_pass,
    'Climbing Points': (t) => t.climbing_points,
    'Auto Fuel Scored': (t) => t.auto_fuel_scored,
    'Teleop Fuel Scored': (t) => t.teleop_fuel_scored,
    'Total Fuel Scored': (t) => t.total_fuel_scored,
    'Foul Points': (t) => t.foul_points,
    'Defense Rate': (t) => t.defense_rate,
    'Death Rate': (t) => t.death_rate,
    'Simulated RP': (t) => t.simulated_rp.toDouble(),
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
    return '2026';
  }

  int snowCount = 100;
  Map<String, Color> teamColors = {};

  String _avatarPrimaryUrl(String teamNumber) {
    return 'https://images.weserv.nl/?url=www.thebluealliance.com/avatar/$_eventYear/frc$teamNumber.png&w=96&h=96&fit=contain';
  }

  String _avatarFallbackUrl(String teamNumber) {
    return 'https://api.dicebear.com/9.x/identicon/png?seed=frc$teamNumber&size=64';
  }

  Future<void> _warmAvatarCacheForPicks() async {
    if (picks.isEmpty || !mounted) return;

    final urlsToWarm = <String>[];
    for (final pick in picks.take(80)) {
      final primary = _avatarPrimaryUrl(pick.number);
      final fallback = _avatarFallbackUrl(pick.number);

      if (_warmedAvatarUrls.add(primary)) {
        urlsToWarm.add(primary);
      }
      if (_warmedAvatarUrls.add(fallback)) {
        urlsToWarm.add(fallback);
      }
    }

    if (urlsToWarm.isEmpty) return;

    final immediate = urlsToWarm.take(24).toList();
    final deferred = urlsToWarm.skip(24).toList();

    Future<void> cacheAndPrecache(String url) async {
      try {
        await picklistAvatarCacheManager.getSingleFile(url, key: url);
        if (!mounted) return;
        await precacheImage(
          ExtendedNetworkImageProvider(
            url,
          ),
          context,
        );
      } catch (_) {}
    }

    await Future.wait(immediate.map(cacheAndPrecache));

    if (deferred.isNotEmpty) {
      unawaited(Future(() async {
        for (final url in deferred) {
          await cacheAndPrecache(url);
          await Future.delayed(const Duration(milliseconds: 30));
        }
      }));
    }
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
        if (widget.picklistID.isNotEmpty) {
          selectedPicklist = picklists.firstWhere(
            (p) => p.picklist_id == widget.picklistID,
            orElse: () => picklists.first,
          );
        } else {
          selectedPicklist = picklists.first;
        }
        picks = List.from(selectedPicklist!.picks);
      }
    });

    for (final p in picks) {
      _ensureTeamName(p.number);
    }
    unawaited(_warmAvatarCacheForPicks());
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
        unawaited(_warmAvatarCacheForPicks());
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
    unawaited(_warmAvatarCacheForPicks());
  }

  void createPicklist(String name, String field) {
    final getter = statFields[field]!;

    final sortedTeams = [...rankings];
    sortedTeams.sort((a, b) => getter(b).compareTo(getter(a)));

    final newPicklist = Picklist2026(
      picklist_id: '',
      name: name,
      picks: sortedTeams
          .map((t) => Picks(number: t.team_number, comments: ''))
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
              title: Text('Delete Picklist',
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
                  child: const Text('Cancel'),
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
                  child: const Text('Delete'),
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
          teamNames[teamNumber] = nickname;
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
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              title: Row(
                children: [
                  Icon(Icons.add_chart_rounded, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'Create Picklist',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Set up the details for your new picklist.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Picklist Name',
                      prefixIcon: const Icon(Icons.edit_note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      filled: true,
                    ),
                    onChanged: (val) => setStateDialog(() {}),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedField,
                    icon: const Icon(Icons.arrow_drop_down),
                    decoration: InputDecoration(
                      labelText: 'Initial Sort Metric',
                      prefixIcon: const Icon(Icons.sort_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      filled: true,
                    ),
                    items: statFields.keys
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => selectedField = value);
                      }
                    },
                  ),
                ],
              ),
              actionsPadding:
                  const EdgeInsets.only(right: 24, bottom: 24, left: 24),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    // ignore: deprecated_member_use
                    disabledBackgroundColor: Colors.blue.withOpacity(0.4),
                  ),
                  onPressed: isValid
                      ? () {
                          createPicklist(
                              nameController.text.trim(), selectedField);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openBubbleCompare() {
    if (picks.length < 2 || selectedPicklist == null) return;

    final route =
        '/group/${widget.groupName}/events/${widget.eventCode}/picklist/generate/${selectedPicklist!.picklist_id}';

    Navigator.of(context).pushNamed(route);
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        // ignore: deprecated_member_use
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
        final theme = Theme.of(context);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Comments',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'For Team ${pick.number}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Add notes, strategy, or observations...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            Navigator.pop(context, controller.text.trim()),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                  Icon(Icons.list, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Picklists',
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
              const Divider(height: 24, color: Colors.blue),
              Expanded(
                child: picklists.isEmpty
                    ? Center(
                        child: Text('No picklists found',
                            style: TextStyle(
                                // ignore: deprecated_member_use
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
                                  // ignore: deprecated_member_use
                                  ? cs.primary.withOpacity(0.06)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  final route =
                                      '/group/${widget.groupName}/events/${widget.eventCode}/picklist/${pl.picklist_id}';

                                  selectPicklist(pl);
                                  Navigator.pop(context);

                                  if (pl.picklist_id.isNotEmpty) {
                                    Navigator.of(context)
                                        .pushReplacementNamed(route);
                                  }
                                },
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
                                            : Colors.blueGrey,
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
                                                          prefixIcon: Icon(
                                                              Icons.edit_note),
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
                                              } else if (value ==
                                                  'AutoGenerate') {
                                                _openBubbleCompare();
                                              } else if (value == 'Export') {
                                                exportCSV();
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'rename',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_outlined,
                                                        size: 20),
                                                    SizedBox(width: 12),
                                                    Text('Rename'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'AutoGenerate',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .auto_awesome_outlined,
                                                        size: 20),
                                                    SizedBox(width: 12),
                                                    Text(
                                                        'Auto Generate Picklist'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'Export',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.download,
                                                        size: 20),
                                                    SizedBox(width: 12),
                                                    Text('Export as CSV'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuDivider(
                                                color: Colors.blueAccent,
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline,
                                                        size: 20,
                                                        color:
                                                            Colors.redAccent),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.redAccent),
                                                    ),
                                                  ],
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
                color: Colors.blue,
                onPressed: () {
                  Navigator.pop(context);
                  openCreateDialog();
                },
                icon: Icons.add,
                label: 'New Picklist',
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTeamImages(String teamNumber) async {
    final eventYear = int.parse(_eventYear);
    String eventCode = widget.eventCode;
    if (eventCode.length > 4) {
      eventCode = eventCode.substring(4);
    }

    showDialog(
      context: context,
      builder: (context) {
        return TeamImagesDialog(
          teamNumber: teamNumber,
          eventYear: eventYear,
          eventCode: eventCode,
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
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: PolarForecastAppBar(
          extraText:
              'Picklist for ${widget.eventCode} | Picklist: ${selectedPicklist?.name}'),
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
                color: cs.onSurface,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              child: picks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt,
                              // ignore: deprecated_member_use
                              size: 72,
                              color: cs.onSurface.withOpacity(0.14)),
                          const SizedBox(height: 16),
                          Text(
                            'No teams in this picklist yet.',
                            style: TextStyle(
                                fontSize: 18,
                                // ignore: deprecated_member_use
                                color: cs.onSurface.withOpacity(0.6)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Create a new picklist or add teams from rankings.',
                            style: TextStyle(
                                fontSize: 13,
                                // ignore: deprecated_member_use
                                color: cs.onSurface.withOpacity(0.5)),
                          )
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: EdgeInsets.only(bottom: isMobile ? 96 : 80),
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

                        final tbaProxyAvatar = _avatarPrimaryUrl(pick.number);
                        final dicebearAvatar = _avatarFallbackUrl(pick.number);

                        final teamStats = _getTeamStats(pick.number);

                        final tint = teamColors[pick.number];
                        final cardTint = tint != null
                            // ignore: deprecated_member_use
                            ? tint.withOpacity(0.08)
                            : cs.surfaceContainerHighest;

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
                                        // ignore: deprecated_member_use
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
                                    // ignore: deprecated_member_use
                                    ? cs.primary.withOpacity(0.6)
                                    // ignore: deprecated_member_use
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
                                              // ignore: deprecated_member_use
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 10.0 : 12.0,
                                      vertical: isMobile ? 8.0 : 10.0),
                                  child: isMobile
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 44,
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '#${index + 1}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: cs.onSurface,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Icon(
                                                        Icons.emoji_events,
                                                        size: 18,
                                                        color:
                                                            trophyColorForRank(
                                                                teamStats
                                                                        ?.rank ??
                                                                    0),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        teamStats != null
                                                            ? '#${teamStats.rank}'
                                                            : '-',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: trophyColorForRank(
                                                              teamStats?.rank ??
                                                                  0),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      ReorderableDragStartListener(
                                                        index: index,
                                                        child: Icon(
                                                          Icons.drag_handle,
                                                          size: 20,
                                                          color: cs.onSurface
                                                              // ignore: deprecated_member_use
                                                              .withOpacity(0.4),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                InkWell(
                                                  onTap: () {
                                                    _openTeamImages(
                                                        pick.number);
                                                  },
                                                  child: TeamAvatar(
                                                    primaryUrl: tbaProxyAvatar,
                                                    fallbackUrl: dicebearAvatar,
                                                    teamNumber: pick.number,
                                                    size: 38,
                                                    onColor: (color) {
                                                      if (color != null) {
                                                        final currentColor =
                                                            teamColors[
                                                                pick.number];
                                                        if (currentColor !=
                                                            color) {
                                                          setState(() {
                                                            teamColors[pick
                                                                    .number] =
                                                                color;
                                                          });
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: cs.onSurface,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Wrap(
                                                        spacing: 6,
                                                        runSpacing: 4,
                                                        children: [
                                                          if (teamStats !=
                                                              null) ...[
                                                            _buildStatBadge(
                                                                'OPR',
                                                                teamStats.OPR
                                                                    .toStringAsFixed(
                                                                        1),
                                                                Colors.purple),
                                                            _buildStatBadge(
                                                                'Auto',
                                                                teamStats
                                                                    .auto_points
                                                                    .toStringAsFixed(
                                                                        1),
                                                                Colors.green),
                                                            _buildStatBadge(
                                                                'Teleop',
                                                                teamStats
                                                                    .teleop_points
                                                                    .toStringAsFixed(
                                                                        1),
                                                                Colors.orange),
                                                            _buildStatBadge(
                                                                'Pass',
                                                                teamStats
                                                                    .teleop_pass
                                                                    .toStringAsFixed(
                                                                        1),
                                                                Colors.blue),
                                                          ],
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: cs
                                                          .surfaceContainerHighest,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: cs.outline
                                                            // ignore: deprecated_member_use
                                                            .withOpacity(0.06),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      pick.comments.isEmpty
                                                          ? 'No comments.'
                                                          : pick.comments,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: cs.onSurface
                                                            // ignore: deprecated_member_use
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
                                                  icon: Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                    color: cs.onSurface
                                                        // ignore: deprecated_member_use
                                                        .withOpacity(0.7),
                                                  ),
                                                  onPressed: () =>
                                                      _editCommentsDialog(
                                                          index),
                                                  tooltip: 'Edit comments',
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
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
                                                const SizedBox(width: 6),
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
                                                const SizedBox(width: 6),
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
                                                const SizedBox(width: 6),
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
                                        )
                                      : Row(
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      fontWeight:
                                                          FontWeight.w700,
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
                                                          // ignore: deprecated_member_use
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
                                                    final currentColor =
                                                        teamColors[pick.number];
                                                    if (currentColor != color) {
                                                      setState(() {
                                                        teamColors[pick
                                                            .number] = color;
                                                      });
                                                    }
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
                                                        WrapCrossAlignment
                                                            .center,
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
                                                      if (teamStats !=
                                                          null) ...[
                                                        _buildStatBadge(
                                                            'OPR',
                                                            teamStats.OPR
                                                                .toStringAsFixed(
                                                                    1),
                                                            Colors.purple),
                                                        _buildStatBadge(
                                                            'Auto',
                                                            teamStats
                                                                .auto_points
                                                                .toStringAsFixed(
                                                                    1),
                                                            Colors.green),
                                                        _buildStatBadge(
                                                            'Teleop',
                                                            teamStats
                                                                .teleop_points
                                                                .toStringAsFixed(
                                                                    1),
                                                            Colors.orange),
                                                        _buildStatBadge(
                                                            'Pass',
                                                            teamStats
                                                                .teleop_pass
                                                                .toStringAsFixed(
                                                                    1),
                                                            Colors.blue),
                                                        _buildStatBadge(
                                                            'Death',
                                                            '${(teamStats.death_rate * 100).toStringAsFixed(0)}%',
                                                            Colors.red),
                                                        _buildStatBadge(
                                                            'Def',
                                                            '${(teamStats.defense_rate * 100).toStringAsFixed(0)}%',
                                                            Colors.brown),
                                                        _buildStatBadge(
                                                            'Sim RP',
                                                            teamStats
                                                                .simulated_rp
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
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: cs
                                                                .surfaceContainerHighest,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: cs
                                                                    .outline
                                                                    // ignore: deprecated_member_use
                                                                    .withOpacity(
                                                                        0.06)),
                                                          ),
                                                          child: Text(
                                                            pick.comments
                                                                    .isEmpty
                                                                ? 'No comments.'
                                                                : pick.comments,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: cs
                                                                  .onSurface
                                                                  // ignore: deprecated_member_use
                                                                  .withOpacity(
                                                                      0.85),
                                                              fontStyle: pick
                                                                      .comments
                                                                      .isEmpty
                                                                  ? FontStyle
                                                                      .normal
                                                                  : FontStyle
                                                                      .italic,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.edit,
                                                            size: 18,
                                                            color: cs.onSurface
                                                                // ignore: deprecated_member_use
                                                                .withOpacity(
                                                                    0.7)),
                                                        onPressed: () =>
                                                            _editCommentsDialog(
                                                                index),
                                                        tooltip:
                                                            'Edit comments',
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
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          opacity: isFirst
                                                              ? 0.3
                                                              : 1.0,
                                                          child:
                                                              GlassIconButton(
                                                            icon: Icons
                                                                .keyboard_arrow_up,
                                                            color: cs.onSurface,
                                                            tooltip:
                                                                'Move up 1',
                                                            onPressed: isFirst
                                                                ? null
                                                                : () => _moveUp(
                                                                    index),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: AnimatedOpacity(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          opacity: isLast
                                                              ? 0.3
                                                              : 1.0,
                                                          child:
                                                              GlassIconButton(
                                                            icon: Icons
                                                                .keyboard_arrow_down,
                                                            color: cs.onSurface,
                                                            tooltip:
                                                                'Move down 1',
                                                            onPressed: isLast
                                                                ? null
                                                                : () =>
                                                                    _moveDown(
                                                                        index),
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
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          opacity: isFirst
                                                              ? 0.3
                                                              : 1.0,
                                                          child:
                                                              GlassIconButton(
                                                            icon: Icons
                                                                .vertical_align_top,
                                                            color: Colors.green,
                                                            tooltip:
                                                                'Move to top',
                                                            onPressed: isFirst
                                                                ? null
                                                                : () =>
                                                                    _moveTop(
                                                                        index),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: AnimatedOpacity(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          opacity: isLast
                                                              ? 0.3
                                                              : 1.0,
                                                          child:
                                                              GlassIconButton(
                                                            icon: Icons
                                                                .vertical_align_bottom,
                                                            color:
                                                                Colors.orange,
                                                            tooltip:
                                                                'Move to bottom',
                                                            onPressed: isLast
                                                                ? null
                                                                : () =>
                                                                    _moveToBottom(
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

class AutoComparisonContainerPage extends StatefulWidget {
  final String eventCode;
  final String leftTeamNumber;
  final String rightTeamNumber;
  final Map<String, String> teamNames;

  const AutoComparisonContainerPage({
    super.key,
    required this.eventCode,
    required this.leftTeamNumber,
    required this.rightTeamNumber,
    required this.teamNames,
  });

  @override
  State<AutoComparisonContainerPage> createState() =>
      _AutoComparisonContainerPageState();
}

class _AutoComparisonContainerPageState
    extends State<AutoComparisonContainerPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tabs = [
      AutoFuelComparisonPagePitScouting(
        eventCode: widget.eventCode,
        leftTeamNumber: widget.leftTeamNumber,
        rightTeamNumber: widget.rightTeamNumber,
        teamNames: widget.teamNames,
      ),
      AutoFuelComparisonPageMatchScouting(
        eventCode: widget.eventCode,
        leftTeamNumber: widget.leftTeamNumber,
        rightTeamNumber: widget.rightTeamNumber,
        teamNames: widget.teamNames,
      ),
    ];

    return Scaffold(
      body: tabs[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined, color: theme.primaryColor),
            activeIcon: Icon(Icons.assignment, color: theme.primaryColor),
            label: 'Auto from Pit Scouting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility_outlined, color: theme.primaryColor),
            activeIcon: Icon(Icons.visibility, color: theme.primaryColor),
            label: 'Auto from Match Scouting',
          ),
        ],
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.primaryColor,
      ),
    );
  }
}

class AutoFuelComparisonPagePitScouting extends StatefulWidget {
  final String eventCode;
  final String leftTeamNumber;
  final String rightTeamNumber;
  final Map<String, String> teamNames;

  const AutoFuelComparisonPagePitScouting({
    super.key,
    required this.eventCode,
    required this.leftTeamNumber,
    required this.rightTeamNumber,
    required this.teamNames,
  });

  @override
  State<AutoFuelComparisonPagePitScouting> createState() =>
      _AutoFuelComparisonPageStatePitScouting();
}

class _AutoFuelComparisonPageStatePitScouting
    extends State<AutoFuelComparisonPagePitScouting> {
  bool isLoading = true;
  String? token;

  PitScouting2026? pitScouting;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    final apiService = Provider.of<ApiService>(context, listen: false);

    apiService.token.then((_token) {
      if (!mounted) return;

      if (_token == null) {
        setState(() {
          token = null;
          isLoading = false;
        });
        return;
      }

      setState(() => token = _token);

      final year = widget.eventCode.substring(0, 4);
      final event = widget.eventCode.substring(4);

      apiService
          .fetchTeamPitScouting(
        year,
        event,
        "frc${widget.leftTeamNumber}",
      )
          .then((data) {
        if (!mounted) return;

        setState(() {
          pitScouting = data;
          isLoading = false;
        });
      }).catchError((e) {
        print("Pit scouting error: $e");
        setState(() => isLoading = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Auto Pit Scouting - ${widget.eventCode}',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token == null
              ? LoginWidget(
                  redirect_path: '/event/${widget.eventCode}',
                )
              : pitScouting == null
                  ? const Center(
                      child: Text("No pit scouting data available"),
                    )
                  : _buildAutos(),
    );
  }

  Widget _buildAutos() {
    final autos = pitScouting!.data.autos;

    if (autos!.isEmpty) {
      return const Center(child: Text("No autos recorded"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: autos.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoPieces2026(
                auto: autos[index],
                locked: true,
                onChanged: (_) {},
              ),
            ),
          ),
        );
      },
    );
  }
}

class AutoFuelComparisonPageMatchScouting extends StatefulWidget {
  final String eventCode;
  final String leftTeamNumber;
  final String rightTeamNumber;
  final Map<String, String> teamNames;

  const AutoFuelComparisonPageMatchScouting({
    super.key,
    required this.eventCode,
    required this.leftTeamNumber,
    required this.rightTeamNumber,
    required this.teamNames,
  });

  @override
  State<AutoFuelComparisonPageMatchScouting> createState() =>
      _AutoFuelComparisonPageStateMatchScouting();
}

class _AutoFuelComparisonPageStateMatchScouting
    extends State<AutoFuelComparisonPageMatchScouting> {
  List<MatchScouting2026> scouting = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    final apiService = Provider.of<ApiService>(context, listen: false);

    apiService.token.then((_token) {
      if (_token != null) {
        if (mounted) {
          setState(() => token = _token);
        }

        apiService
            .fetchTeamMatchScouting(
          int.parse(widget.eventCode.substring(0, 4)),
          widget.eventCode.substring(4),
          "frc${widget.leftTeamNumber}",
        )
            .then((_scouting) {
          if (mounted) {
            setState(() {
              scouting = _scouting;
              isLoading = false;
            });
          }
        });
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Auto Match Scouting - ${widget.eventCode}',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token == null
              ? LoginWidget(
                  redirect_path: '/event/${widget.eventCode}',
                )
              : scouting.isEmpty
                  ? const Center(child: Text("No scouting data available"))
                  : ListView.builder(
                      itemCount: (scouting.length / 2).ceil(),
                      itemBuilder: (context, rowIndex) {
                        final leftIndex = rowIndex * 2;
                        final rightIndex = leftIndex + 1;

                        final left = scouting[leftIndex];
                        final right = rightIndex < scouting.length
                            ? scouting[rightIndex]
                            : null;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(child: _buildCard(left)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: right != null
                                    ? _buildCard(right)
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildCard(MatchScouting2026 data) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: AutoDisplay2026(
        scoutingData: data,
      ),
    );
  }
}

class DeathsComparisonPage extends StatelessWidget {
  final String eventCode;
  final String leftTeamNumber;
  final String rightTeamNumber;
  final Map<String, String> teamNames;

  const DeathsComparisonPage({
    super.key,
    required this.eventCode,
    required this.leftTeamNumber,
    required this.rightTeamNumber,
    required this.teamNames,
  });

  String _teamLabel(String teamNumber) {
    final nickname = teamNames[teamNumber];
    if (nickname != null && nickname.isNotEmpty) {
      return '$teamNumber | $nickname';
    }
    return teamNumber;
  }

  int _teamNumberAsInt(String teamNumber) {
    return int.tryParse(teamNumber) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PolarForecastAppBar(extraText: 'Deaths Comparison - $eventCode'),
      body: FutureBuilder<List<Tournament>>(
        future: apiService.fetchTournaments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Unable to load tournament data.'));
          }

          final tournament =
              snapshot.data!.where((t) => t.key == eventCode).firstOrNull;

          if (tournament == null) {
            return Center(
              child: Text(
                'Could not find event $eventCode.',
                style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 900;
              final leftPane = _DeathsTeamPanel(
                title: _teamLabel(leftTeamNumber),
                tournament: tournament,
                teamNumber: _teamNumberAsInt(leftTeamNumber),
              );
              final rightPane = _DeathsTeamPanel(
                title: _teamLabel(rightTeamNumber),
                tournament: tournament,
                teamNumber: _teamNumberAsInt(rightTeamNumber),
              );

              if (sideBySide) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(child: leftPane),
                      const SizedBox(width: 10),
                      Expanded(child: rightPane),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(child: leftPane),
                    const SizedBox(height: 10),
                    Expanded(child: rightPane),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeathsTeamPanel extends StatelessWidget {
  final String title;
  final Tournament tournament;
  final int teamNumber;

  const _DeathsTeamPanel({
    required this.title,
    required this.tournament,
    required this.teamNumber,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: cs.surfaceVariant.withOpacity(0.35),
            child: Text(
              'Team $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
          Expanded(
            child: DeathsForm(tournament, teamNumber, true),
          ),
        ],
      ),
    );
  }
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
                                              child: ExtendedImage.network(
                                                image.link,
                                                fit: BoxFit.contain,
                                                loadStateChanged:
                                                    (ExtendedImageState state) {
                                                  switch (state
                                                      .extendedImageLoadState) {
                                                    case LoadState.loading:
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2));
                                                    case LoadState.failed:
                                                      return const Icon(
                                                          Icons
                                                              .broken_image_outlined,
                                                          color: Colors.white70,
                                                          size: 36);
                                                    default:
                                                      return null;
                                                  }
                                                },
                                              ),
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
                                ExtendedImage.network(
                                  image.link,
                                  fit: BoxFit.cover,
                                  loadStateChanged: (ExtendedImageState state) {
                                    switch (state.extendedImageLoadState) {
                                      case LoadState.loading:
                                        return Container(
                                          color: cs.surfaceVariant,
                                        );
                                      case LoadState.failed:
                                        return Container(
                                          color: cs.surfaceVariant,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                              Icons.broken_image_outlined),
                                        );
                                      default:
                                        return null;
                                    }
                                  },
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
  static final Map<String, Color?> _paletteCache = {};
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
    if (_paletteCache.containsKey(_currentUrl)) {
      widget.onColor?.call(_paletteCache[_currentUrl]);
      return;
    }

    try {
      final provider = ExtendedNetworkImageProvider(
        _currentUrl,
      );
      final palette = await PaletteGenerator.fromImageProvider(provider,
          size: const Size(40, 40), maximumColorCount: 4);
      final color = palette.dominantColor?.color ?? palette.vibrantColor?.color;
      _paletteCache[_currentUrl] = color;
      widget.onColor?.call(color);
    } catch (e) {
      _paletteCache[_currentUrl] = null;
      widget.onColor?.call(null);
    }
  }

  void _onImageError(Object? _, StackTrace? __) {
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
            : ExtendedImage.network(
                _currentUrl,
                cacheMaxAge: const Duration(days: 14),
                fit: BoxFit.cover,
                width: widget.size,
                height: widget.size,
                loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Container(
                        color: cs.surfaceVariant,
                      );
                    case LoadState.failed:
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _onImageError(null, null);
                      });
                      return const SizedBox.shrink();
                    default:
                      return null;
                  }
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
