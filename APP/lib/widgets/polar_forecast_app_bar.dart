import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/models/group_join_request.dart';
import 'package:scouting_app/models/tournament.dart';
import 'package:scouting_app/utils.dart';
// Assuming these imports are correct based on your snippet
// import 'package:scouting_app/models/group_join_request.dart';
// import '../models/tournament.dart';
// import '../api_service.dart';
// import '../utils.dart';

void _openDocumentationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('How to use Groups',
                  style: TextStyle(fontFamily: 'Font')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/documentation/groups');
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('How to Scout',
                  style: TextStyle(fontFamily: 'Font')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/documentation/scout');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

Future<void> _openJoinRequestsPopup(BuildContext context) async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  final token = await apiService.token;
  if (token == null) return;

  final List<GroupJoinRequest> requests =
      (await apiService.get_user_join_requests())
          .where((element) => !element.accepted)
          .toList();

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Join Requests',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Font')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: double.maxFinite,
          child: requests.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child:
                      Text('No pending requests.', textAlign: TextAlign.center),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return Card(
                      elevation: 0,
                      color: Colors.blue,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(req.group_name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Pending approval'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () async {
                            try {
                              await apiService.delete_join_request(req);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class TournamentSearchDelegate extends SearchDelegate {
  final List<Tournament> tournaments;

  TournamentSearchDelegate(this.tournaments);

  @override
  String get searchFieldLabel => 'Search tournaments…';

  @override
  TextStyle get searchFieldStyle => const TextStyle(
        fontFamily: 'Font',
        fontSize: 16,
        color: Colors.white,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0x591E3A8A),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontFamily: 'Font',
          color: Colors.white.withOpacity(0.45),
          fontSize: 16,
        ),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontFamily: 'Font',
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          tooltip: 'Clear',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
      tooltip: 'Back',
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = query.isEmpty
        ? tournaments
        : tournaments
            .where((t) => t.display.toLowerCase().contains(query.toLowerCase()))
            .toList();

    if (results.isEmpty) {
      return _EmptyState(query: query);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(
        height: 0.5,
        thickness: 0.5,
        color: Colors.white.withOpacity(0.08),
        indent: 64,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final tournament = results[index];
        final highlighted = _highlight(tournament.display, query);

        return _TournamentTile(
          tournament: tournament,
          highlighted: highlighted,
          onTap: () {
            close(context, null);
            Navigator.pushNamed(context, '/event/${tournament.key}');
          },
        );
      },
    );
  }

  // Returns spans with the matching query portion highlighted
  List<TextSpan> _highlight(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }
    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;
    int idx;
    while ((idx = lower.indexOf(lowerQuery, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          backgroundColor: Color(0x33FFFFFF),
        ),
      ));
      start = idx + query.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }
}

// ─── Tournament Tile ──────────────────────────────────────────────────────────

class _TournamentTile extends StatefulWidget {
  final Tournament tournament;
  final List<TextSpan> highlighted;
  final VoidCallback onTap;

  const _TournamentTile({
    required this.tournament,
    required this.highlighted,
    required this.onTap,
  });

  @override
  State<_TournamentTile> createState() => _TournamentTileState();
}

class _TournamentTileState extends State<_TournamentTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovering ? Colors.white.withOpacity(0.06) : Colors.transparent,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.white.withOpacity(0.6),
              size: 20,
            ),
          ),
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Font',
                fontSize: 15,
                color: Colors.white.withOpacity(0.85),
              ),
              children: widget.highlighted,
            ),
          ),
          subtitle: widget.tournament.key.isNotEmpty
              ? Text(
                  widget.tournament.key,
                  style: TextStyle(
                    fontFamily: 'Font',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.35),
                    letterSpacing: 0.3,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.25),
            size: 18,
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'Start typing to search'
                : 'No results for "$query"',
            style: TextStyle(
              fontFamily: 'Font',
              fontSize: 15,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class PolarForecastSliverBar extends StatefulWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String? extraText;
  final bool showBackButton;

  const PolarForecastSliverBar(
      {super.key, this.extraText, this.showBackButton = true})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => _PolarForecastSliverBarState();
}

class _PolarForecastSliverBarState extends State<PolarForecastSliverBar> {
  late final Future<List<Tournament>> tournaments;
  String? token;
  bool isSearching = false;

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    tournaments = apiService.fetchTournaments();
    apiService.token.then((t) {
      if (mounted) setState(() => token = t);
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final desktop = isDesktop(context);

    final logoHeight = desktop ? 24.0 : 32.0;
    final titleFontSize = desktop ? 16.0 : 20.0;
    final iconSize = desktop ? 20.0 : 24.0;
    final spacing = desktop ? 8.0 : 12.0;

    return SliverAppBar(
      automaticallyImplyLeading: widget.showBackButton,
      pinned: true,
      floating: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: !desktop,

      // Glass background via flexibleSpace
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0x591E3A8A), // ~35% opacity 0xFF1E3A8A
              border: Border(
                bottom: BorderSide(color: Colors.white24, width: 0.5),
              ),
            ),
          ),
        ),
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.pushNamed(context, '/'),
              child: Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/PolarBearHead.png',
                  height: logoHeight,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
          if (!isMobile())
            Flexible(
              child: Text(
                widget.extraText ?? 'Polar Forecast',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Font',
                  fontSize: titleFontSize,
                  color: Colors.white.withOpacity(0.9),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),

      actions: [
        IconButton(
          icon: Icon(Icons.help_outline_rounded,
              size: iconSize, color: Colors.white70),
          onPressed: () => _openDocumentationSheet(context),
        ),
        FutureBuilder<String?>(
          future: apiService.token,
          builder: (context, snapshot) {
            return _AccountMenuButton(
              token: snapshot.data,
              apiService: apiService,
            );
          },
        ),
        IconButton(
          icon: isSearching
              ? SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                )
              : Icon(Icons.search_rounded,
                  size: iconSize, color: Colors.white70),
          onPressed: () async {
            if (isSearching) return;
            setState(() => isSearching = true);
            final list = await tournaments;
            if (mounted) {
              setState(() => isSearching = false);
              showSearch(
                context: context,
                delegate: TournamentSearchDelegate(list),
              );
            }
          },
        ),
        SizedBox(width: spacing),
      ],
    );
  }
}

/// A dedicated widget for the Account Menu to keep the AppBar clean
class _AccountMenuButton extends StatelessWidget {
  final String? token;
  final ApiService apiService;

  const _AccountMenuButton({
    this.token,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(
        token == null ? Icons.account_circle_outlined : Icons.account_circle,
      ),
      itemBuilder: (context) => [
        if (token != null) ...[
          PopupMenuItem(
            enabled: false,
            child: Text(
              'User: ${get_scout_info(token!).username}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 1,
            child: _MenuLabel(Icons.group_work, 'Groups'),
          ),
          const PopupMenuItem(
            value: 2,
            child: _MenuLabel(Icons.notifications_active, 'Join Requests'),
          ),
          const PopupMenuItem(
            value: 3,
            child: _MenuLabel(Icons.logout, 'Logout'),
          ),
        ] else
          const PopupMenuItem(
            value: 4,
            child: _MenuLabel(Icons.login, 'Login'),
          ),
      ],
      onSelected: (val) async {
        if (!context.mounted) return;

        if (val == 1) _openGroupsPopup(context);
        if (val == 2) _openJoinRequestsPopup(context);

        if (val == 3) {
          await apiService.logout();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out')),
            );
          }
        }

        if (val == 4) {
          await _handleLogin(context);
        }
      },
    );
  }

  // ---------------------------
  // 🔥 CLEAN LOGIN HANDLER
  // ---------------------------
  Future<void> _handleLogin(BuildContext context) async {
    try {
      final result = await apiService.login('home');

      // ❗ login() now returns either token OR error string
      if (!context.mounted) return;

      if (result == null) {
        _showError(context, 'Login failed (no response)');
        return;
      }

      if (result.startsWith('❌') ||
          result.startsWith('🚨') ||
          result.startsWith('⚠️')) {
        _showError(context, result);
        return;
      }

      // ✅ Force refresh token state
      final token = await apiService.token;

      if (token == null) {
        _showError(context, 'Login failed: token exchange did not complete');
        return;
      }

      await apiService.fetchTournaments();
      final validatedToken = await apiService.token;
      if (validatedToken == null) {
        _showError(context,
            'Session could not be validated. Access is denied until you log in again.');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          duration: Duration(seconds: 2),
        ),
      );
    } on AuthRecoveryException catch (e) {
      if (!context.mounted) return;
      _showError(context, e.message);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Login exception: $e');
    }
  }

  // ---------------------------
  // 🔥 SNACKBAR HELPER
  // ---------------------------
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 8),
      ),
    );
  }
}

class _MenuLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuLabel(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

// --- Improved Group Dialog ---
_openGroupsPopup(BuildContext context) async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  final groups = (await apiService.get_user_groups())
      .where((g) => g['path'].toString().split('/').length == 2)
      .toList();

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(Icons.group_rounded,
                            color: Colors.white.withOpacity(0.8), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Your Group',
                        style: TextStyle(
                          fontFamily: 'Font',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: Colors.white.withOpacity(0.5), size: 20),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: Colors.white.withOpacity(0.08), height: 0.5),

                // ── Body ───────────────────────────────
                groups.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 24),
                        child: Column(
                          children: [
                            Icon(Icons.group_off_rounded,
                                size: 44, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            Text(
                              'No groups yet',
                              style: TextStyle(
                                fontFamily: 'Font',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a group to collect scouting data with your team and share insights.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Font',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: groups.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: Colors.white.withOpacity(0.08),
                            indent: 60,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, i) => _GroupTile(
                            group: groups[i],
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/group/${groups[i]['name']}',
                            ),
                          ),
                        ),
                      ),

                Divider(color: Colors.white.withOpacity(0.08), height: 0.5),

                // ── Footer (FIXED LOGIC) ─────────────────
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (groups.isEmpty) ...[
                        const SizedBox(width: 8),
                        _GlassFilledButton(
                          icon: Icons.add_rounded,
                          label: 'Create Group',
                          onPressed: () => _showCreateGroupDialog(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
// ─── Group Tile ───────────────────────────────────────────────────────────────

class _GroupTile extends StatefulWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;

  const _GroupTile({required this.group, required this.onTap});

  @override
  State<_GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<_GroupTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: _hovering ? Colors.white.withOpacity(0.06) : Colors.transparent,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Icon(Icons.group_rounded,
                color: Colors.white.withOpacity(0.7), size: 18),
          ),
          title: Text(
            widget.group['name'],
            style: TextStyle(
              fontFamily: 'Font',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          subtitle: Text(
            widget.group['path'],
            style: TextStyle(
              fontFamily: 'Font',
              fontSize: 12,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.25), size: 18),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _GlassFilledButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GlassFilledButton(
      {required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label:
          Text(label, style: const TextStyle(fontFamily: 'Font', fontSize: 13)),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.18),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white.withOpacity(0.25), width: 0.5),
        ),
      ),
    );
  }
}

class PolarForecastAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? extraText;
  final bool backButton;

  const PolarForecastAppBar({
    super.key,
    this.extraText,
    this.backButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final desktop = isDesktop(context);

    final logoHeight = desktop ? 24.0 : 32.0;
    final titleFontSize = desktop ? 16.0 : 20.0;
    final iconSize = desktop ? 20.0 : 24.0;
    final spacing = desktop ? 8.0 : 12.0;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AppBar(
          automaticallyImplyLeading: backButton,
          backgroundColor:
              const Color(0xFF1E3A8A).withOpacity(0.35), // soft blue glass
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: !desktop,

          // glass border effect
          shape: const Border(
            bottom: BorderSide(
              color: Colors.white24,
              width: 0.5,
            ),
          ),

          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/PolarBearHead.png',
                      height: logoHeight,
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Flexible(
                child: Text(
                  extraText ?? 'Polar Forecast',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Font',
                    fontSize: titleFontSize,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded,
                  size: iconSize, color: Colors.white70),
              onPressed: () => _openDocumentationSheet(context),
            ),
            FutureBuilder<String?>(
              future: apiService.token,
              builder: (context, snapshot) {
                return _AccountMenuButton(
                  token: snapshot.data,
                  apiService: apiService,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search_rounded,
                  size: iconSize, color: Colors.white70),
              onPressed: () async {
                final list = await apiService.fetchTournaments();
                if (context.mounted) {
                  showSearch(
                    context: context,
                    delegate: TournamentSearchDelegate(list),
                  );
                }
              },
            ),
            SizedBox(width: spacing),
          ],
        ),
      ),
    );
  }
}

void _showCreateGroupDialog(BuildContext context) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ─────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Create Group',
                      style: TextStyle(
                        fontFamily: 'Font',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Input ──────────────────────────────
                TextField(
                  controller: controller,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9]'),
                    ),
                  ],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'Font',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blueAccent.withOpacity(0.8),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── Buttons ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        backgroundColor: Colors.white.withOpacity(0.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () async {
                        final apiService =
                            Provider.of<ApiService>(context, listen: false);

                        apiService
                            .make_group(controller.text, null, null)
                            .then((value) {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed('/group/${value.name}');
                        }).onError((e, _) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.18),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                      ),
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
