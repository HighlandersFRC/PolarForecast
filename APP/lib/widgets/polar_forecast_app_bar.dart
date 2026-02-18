import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/group_join_request.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tournament.dart';
import '../api_service.dart';
import '../utils.dart';

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
  State<StatefulWidget> createState() {
    return _PolarForecastSliverBarState();
  }
}

class _PolarForecastSliverBarState extends State<PolarForecastSliverBar> {
  late final Future<List<Tournament>> tournaments;
  String? token;
  final GlobalKey _iconButtonKey = GlobalKey();
  bool isSearching = false;
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    tournaments = apiService.fetchTournaments();
    apiService.token.then((token) {
      if (mounted)
        setState(() {
          this.token = token;
        });
      this.token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apiService = Provider.of<ApiService>(context);
    return SliverAppBar(
      automaticallyImplyLeading: widget.showBackButton,
      title: !isMobile()
          ? Row(
              children: [
                Image.asset(
                  'assets/PolarBearHead.png',
                  height:
                      kToolbarHeight * 0.8, // Adjust size based on screen width
                ),
                const SizedBox(
                    width: 8), // Add some spacing between image and text
                Flexible(
                  child: Text(
                    'Polar Forecast ${widget.extraText ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: kToolbarHeight *
                          0.8, // Adjust font size based on screen width
                      fontFamily: 'Font',
                    ),
                    overflow: TextOverflow.fade, // Prevent overflow
                  ),
                ),
              ],
            )
          : Image.asset(
              'assets/PolarBearHead.png',
              height: kToolbarHeight * 0.8, // Adjust size based on screen width
            ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.white),
          onPressed: () => _openDocumentationSheet(context),
        ),
        IconButton(
          key: _iconButtonKey,
          icon: Icon(token == null
              ? Icons.account_circle_outlined
              : Icons.account_circle),
          color: Colors.white,
          onPressed: () {
            final RenderBox button =
                _iconButtonKey.currentContext!.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            final Offset offset =
                button.localToGlobal(Offset.zero, ancestor: overlay);
            final RelativeRect position = RelativeRect.fromRect(
              Rect.fromLTWH(
                  offset.dx, offset.dy, button.size.width, button.size.height),
              Offset.zero & overlay.size,
            );

            showMenu(
              context: context,
              position: position,
              items: [
                if (token != null)
                  PopupMenuItem(
                    enabled: false,
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Logged in as: ${get_scout_info(token ?? '').username}',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                  ),
                if (token != null)
                  PopupMenuItem(
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Groups',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                    onTap: () {
                      _openGroupsPopup(context);
                    },
                  ),
                if (token != null)
                  PopupMenuItem(
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Group Join Requests',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                    onTap: () {
                      _openJoinRequestsPopup(context);
                    },
                  ),
                if (token != null)
                  PopupMenuItem(
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Logout',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                    onTap: () {
                      apiService.logout();
                    },
                  ),
                if (token == null)
                  PopupMenuItem(
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Login',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                    onTap: () {
                      apiService.login('home');
                    },
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () async {
            if (!isSearching) await _openSearch();
          },
        ),
      ],
      backgroundColor: theme.primaryColor,
    );
  }

  Future<void> _openSearch() async {
    setState(() {
      isSearching = true;
    });
    final param = await tournaments;
    setState(() {
      isSearching = false;
    });
    showSearch(
      context: context,
      delegate: TournamentSearchDelegate(param),
    );
  }
}

class PolarForecastAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String? extraText;
  final bool backButton;

  const PolarForecastAppBar({super.key, this.extraText, this.backButton = true})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() {
    return _PolarForecastAppBarState();
  }
}

class _PolarForecastAppBarState extends State<PolarForecastAppBar> {
  late final Future<List<Tournament>> tournaments;
  String? token;
  final GlobalKey _iconButtonKey = GlobalKey();
  bool isSearching = false;
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    tournaments = apiService.fetchTournaments();
    apiService.token.then((token) {
      if (mounted)
        setState(() {
          this.token = token;
        });
      this.token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apiService = Provider.of<ApiService>(context);
    return AppBar(
      automaticallyImplyLeading: widget.backButton,
      title: !isMobile()
          ? Row(
              children: [
                Image.asset(
                  'assets/PolarBearHead.png',
                  height:
                      kToolbarHeight * 0.8, // Adjust size based on screen width
                ),
                const SizedBox(
                    width: 8), // Add some spacing between image and text
                Flexible(
                  child: Text(
                    widget.extraText ?? 'Polar Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: kToolbarHeight *
                          0.8, // Adjust font size based on screen width
                      fontFamily: 'Font',
                    ),
                    overflow: TextOverflow.fade, // Prevent overflow
                  ),
                ),
              ],
            )
          : Image.asset(
              'assets/PolarBearHead.png',
              height: kToolbarHeight * 0.8, // Adjust size based on screen width
            ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.white),
          onPressed: () => _openDocumentationSheet(context),
        ),
        IconButton(
          key: _iconButtonKey,
          icon: Icon(token == null
              ? Icons.account_circle_outlined
              : Icons.account_circle),
          color: Colors.white,
          onPressed: () {
            final RenderBox button =
                _iconButtonKey.currentContext!.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            final Offset offset =
                button.localToGlobal(Offset.zero, ancestor: overlay);
            final RelativeRect position = RelativeRect.fromRect(
              Rect.fromLTWH(
                  offset.dx, offset.dy, button.size.width, button.size.height),
              Offset.zero & overlay.size,
            );

            showMenu(
              context: context,
              position: position,
              items: [
                if (token != null)
                  PopupMenuItem(
                    enabled: false,
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Logged in as: ${get_scout_info(token ?? '').username}',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                  ),
                if (token != null)
                  PopupMenuItem(
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Groups',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                    onTap: () {
                      _openGroupsPopup(context);
                    },
                  ),
                if (token != null)
                  PopupMenuItem(
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Group Join Requests',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                    onTap: () {
                      _openJoinRequestsPopup(context);
                    },
                  ),
                if (token != null)
                  PopupMenuItem(
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Logout',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                    onTap: () {
                      apiService.logout();
                    },
                  ),
                if (token == null)
                  PopupMenuItem(
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Login',
                        style:
                            TextStyle(color: Colors.white, fontFamily: 'Font'),
                      ),
                    ),
                    onTap: () {
                      apiService.login('home');
                    },
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () async {
            if (!isSearching) await _openSearch();
          },
        ),
      ],
      backgroundColor: theme.primaryColor,
    );
  }

  Future<void> _openSearch() async {
    setState(() {
      isSearching = true;
    });
    final param = await tournaments;
    setState(() {
      isSearching = false;
    });
    showSearch(
      context: context,
      delegate: TournamentSearchDelegate(param),
    );
  }
}

class TournamentSearchDelegate extends SearchDelegate {
  final List<Tournament> tournaments;

  TournamentSearchDelegate(this.tournaments);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = tournaments
        .where((tournament) =>
            tournament.display.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(results[index].display,
                style: TextStyle(fontFamily: 'Font')),
            onTap: () {
              Navigator.pushNamed(context, '/event/${results[index].key}');
            },
            onLongPress: () {
              launchUrl(Uri.parse(
                  Provider.of<ApiService>(context, listen: false).APPURL +
                      '/event/${results[index].key}'));
            });
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = tournaments
        .where((tournament) =>
            tournament.display.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].display,
              style: TextStyle(fontFamily: 'Font')),
          onTap: () {
            Navigator.pushNamed(context, '/event/${suggestions[index].key}');
          },
        );
      },
    );
  }
}

_openGroupsPopup(BuildContext context) async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  final token = await apiService.token;
  if (token == null) {
    return;
  }
  final List groups = (await apiService.get_user_groups()).where((group) {
    // print(group);
    // print(group['path'].runtimeType);
    return group['path'].toString().split('/').length == 2;
  }).toList();
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        // Use Dialog instead of Card for a better look
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ensures it takes minimal height
              children: [
                Text(
                  'Your Group',
                  style: TextStyle(
                      color: Colors.white, fontSize: 30, fontFamily: 'Font'),
                ),
                groups.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('You are not part of any group',
                            style: TextStyle(
                                color: Colors.red, fontFamily: 'Font')),
                      )
                    : SizedBox(
                        child: Column(
                            children: List.generate(
                          groups.length,
                          (index) {
                            return ListTile(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    '/group/${groups[index]['name']}');
                              },
                              title: Text(groups[index]['name'],
                                  style: TextStyle(fontFamily: 'Font')),
                            );
                          },
                        )),
                      ),
                if (groups.isEmpty)
                  ElevatedButton(
                      child: Text('Create a New Group',
                          style: TextStyle(fontFamily: 'Font')),
                      onPressed: () {
                        final TextEditingController groupNameController =
                            TextEditingController();
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Create a New Group',
                                  style: TextStyle(fontFamily: 'Font')),
                              content: TextField(
                                  controller: groupNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Group Name',
                                    hintText: 'Enter the name of the group',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'))
                                  ]),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel',
                                      style: TextStyle(fontFamily: 'Font')),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final apiService = Provider.of<ApiService>(
                                        context,
                                        listen: false);
                                    apiService
                                        .make_group(groupNameController.text,
                                            null, null)
                                        .then((value) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .pushNamed('/group/${value.name}');
                                    }).onError((e, _) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(e.toString(),
                                                  style: TextStyle(
                                                      fontFamily: 'Font'))));
                                    });
                                  },
                                  child: const Text('Create',
                                      style: TextStyle(fontFamily: 'Font')),
                                ),
                              ],
                            );
                          },
                        );
                      }),
              ],
            ),
          ),
        ),
      );
    },
  );
}

_openJoinRequestsPopup(BuildContext context) async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  final token = await apiService.token;
  if (token == null) return;
  final List<GroupJoinRequest> requests =
      (await apiService.get_user_join_requests())
          .where(
            (element) => !element.accepted,
          )
          .toList();
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Text(
                      'Group Join Requests',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontFamily: 'Font'),
                    ),
                    if (requests.isEmpty)
                      Text('No Pending Join Requests',
                          style: TextStyle(fontFamily: 'Font')),
                    ExpansionPanelList.radio(
                      children: [
                        ...List.generate(requests.length, (requestIndex) {
                          return ExpansionPanelRadio(
                              value: requestIndex,
                              headerBuilder: (context, open) => ListTile(
                                    title: Text(
                                        'Group: ${requests[requestIndex].group_name}',
                                        style: TextStyle(fontFamily: 'Font')),
                                  ),
                              body: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    apiService
                                        .delete_join_request(
                                            requests[requestIndex])
                                        .then((_) {})
                                        .onError((e, _) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(e.toString(),
                                                  style: TextStyle(
                                                      fontFamily: 'Font'))));
                                    });
                                  },
                                  child: Text('Delete',
                                      style: TextStyle(fontFamily: 'Font')),
                                  style: ButtonStyle(
                                    foregroundColor:
                                        WidgetStatePropertyAll(Colors.white),
                                    backgroundColor:
                                        WidgetStatePropertyAll(Colors.red),
                                  )));
                        })
                      ],
                    )
                  ],
                ))));
      });
}

_openDocumentationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('How to use Groups',
                  style: TextStyle(fontFamily: 'Font')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/documentation/groups',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_red_eye),
              title: const Text('How to Scout',
                  style: TextStyle(fontFamily: 'Font')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/documentation/scout',
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
