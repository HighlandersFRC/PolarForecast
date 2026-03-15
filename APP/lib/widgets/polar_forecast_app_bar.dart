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
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = tournaments
        .where((t) => t.display.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].display,
              style: const TextStyle(fontFamily: 'Font')),
          leading: const Icon(Icons.event),
          onTap: () {
            Navigator.pushNamed(context, '/event/${results[index].key}');
          },
        );
      },
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

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    tournaments = apiService.fetchTournaments();
    apiService.token.then((t) => setState(() => token = t));
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    // Adjust sizes based on screen width
    final logoHeight = isDesktop ? 24.0 : 28.0;
    final titleFontSize = isDesktop ? 16.0 : 18.0;
    final iconSize = isDesktop ? 20.0 : 24.0;

    return SliverAppBar(
      automaticallyImplyLeading: widget.showBackButton,
      pinned: true,
      stretch: true,
      expandedHeight: 120,
      backgroundColor: Colors.blue,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final topPadding = MediaQuery.of(context).padding.top;

          return FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsetsDirectional.only(
              start: 72, // space for back button
              end: 120, // reserve space for actions
              bottom: 16,
            ),
            title: Row(
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/PolarBearHead.png',
                    height: logoHeight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Polar Forecast ${widget.extraText ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: titleFontSize,
                    ),
                  ),
                ),
              ],
            ),
            background: Container(
              padding: EdgeInsets.only(top: topPadding),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.blue, Colors.black],
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          tooltip: 'Documentation',
          iconSize: iconSize,
          onPressed: () => _openDocumentationSheet(context),
        ),
        _AccountMenuButton(
          token: token,
          apiService: apiService,
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded),
          iconSize: iconSize,
          onPressed: () async {
            final list = await tournaments;
            showSearch(
              context: context,
              delegate: TournamentSearchDelegate(list),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// A dedicated widget for the Account Menu to keep the AppBar clean
class _AccountMenuButton extends StatelessWidget {
  final String? token;
  final ApiService apiService;

  const _AccountMenuButton({this.token, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(
          token == null ? Icons.account_circle_outlined : Icons.account_circle),
      itemBuilder: (context) => [
        if (token != null) ...[
          PopupMenuItem(
            enabled: false,
            child: Text(
              'User: ${get_scout_info(token!).username}',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
              value: 1, child: const _MenuLabel(Icons.group_work, 'Groups')),
          PopupMenuItem(
              value: 2,
              child: const _MenuLabel(
                  Icons.notifications_active, 'Join Requests')),
          PopupMenuItem(
              value: 3, child: const _MenuLabel(Icons.logout, 'Logout')),
        ] else
          PopupMenuItem(
              value: 4, child: const _MenuLabel(Icons.login, 'Login')),
      ],
      onSelected: (val) {
        if (val == 1) _openGroupsPopup(context);
        if (val == 2) _openJoinRequestsPopup(context);
        if (val == 3) apiService.logout();
        if (val == 4) apiService.login('home');
      },
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
    builder: (context) => AlertDialog(
      title: const Text('Your Groups',
          style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: SizedBox(
        width: double.maxFinite,
        child: groups.isEmpty
            ? const Text('You are not part of any group yet.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: groups.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) => ListTile(
                  leading: const CircleAvatar(
                      child: Icon(Icons.group, color: Colors.blue)),
                  title: Text(groups[i]['name']),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                      context, '/group/${groups[i]['name']}'),
                ),
              ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
        if (groups.isEmpty)
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create New'),
            onPressed: () => _showCreateGroupDialog(context),
          ),
      ],
    ),
  );
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

    // Sizes based on desktop vs mobile
    final logoHeight = desktop ? 24.0 : 32.0;
    final titleFontSize = desktop ? 16.0 : 20.0;
    final iconSize = desktop ? 20.0 : 24.0;
    final spacing = desktop ? 8.0 : 12.0;

    return AppBar(
      automaticallyImplyLeading: backButton,
      backgroundColor: Colors.blue,
      elevation: 0,
      centerTitle: !desktop,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/PolarBearHead.png', height: logoHeight),
          SizedBox(width: spacing),
          Flexible(
            child: Text(
              extraText ?? 'Polar Forecast',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Font',
                fontSize: titleFontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline_rounded, size: iconSize),
          onPressed: () => _openDocumentationSheet(context),
        ),
        FutureBuilder<String?>(
          future: apiService.token,
          builder: (context, snapshot) {
            return _AccountMenuButton(
                token: snapshot.data,
                apiService: apiService // pass down icon size
                );
          },
        ),
        IconButton(
          icon: Icon(Icons.search_rounded, size: iconSize),
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
    );
  }
}

void _showCreateGroupDialog(BuildContext context) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create Group'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Group Name',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final apiService = Provider.of<ApiService>(context, listen: false);
            apiService.make_group(controller.text, null, null).then((value) {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/group/${value.name}');
            }).onError((e, _) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString())));
            });
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}
