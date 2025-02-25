import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/group_join_request.dart';
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
  List<Tournament> tournaments = [];
  String? token;
  final GlobalKey _iconButtonKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchTournaments().then((tournaments) {
      if (mounted)
        setState(() {
          this.tournaments = tournaments;
        });
      else
        this.tournaments = tournaments;
    });
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
                      fontFamily: 'OpenSans',
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
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Groups',
                        style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white),
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
          icon: const Icon(Icons.search),
          onPressed: () {
            _openSearch();
          },
        ),
      ],
      backgroundColor: theme.primaryColor,
    );
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SearchAnchor.bar(
        suggestionsBuilder: (context, searchController) =>
            _getSuggestions(searchController),
      ),
    );
  }

  List<Widget> _getSuggestions(SearchController searchController) {
    if (tournaments.isEmpty) return [];
    var filteredTournaments = tournaments
        .where(
          (tournament) => tournament.display
              .toLowerCase()
              .contains(searchController.text.toLowerCase()),
        )
        .toList();
    List<Widget> suggestions = [
      ...filteredTournaments.map((tournament) {
        return ListTile(
          title: Text(tournament.display),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/event/${tournament.key}');
          },
        );
      })
    ];
    return suggestions;
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
  List<Tournament> tournaments = [];
  String? token;
  final GlobalKey _iconButtonKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchTournaments().then((tournaments) {
      if (mounted)
        setState(() {
          this.tournaments = tournaments;
        });
      else
        this.tournaments = tournaments;
    });
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
                    'Polar Forecast ${widget.extraText ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: kToolbarHeight *
                          0.8, // Adjust font size based on screen width
                      fontFamily: 'OpenSans',
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
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Groups',
                        style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white),
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
          icon: const Icon(Icons.search),
          onPressed: () {
            _openSearch();
          },
        ),
      ],
      backgroundColor: theme.primaryColor,
    );
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SearchAnchor.bar(
        suggestionsBuilder: (context, searchController) =>
            _getSuggestions(searchController),
      ),
    );
  }

  List<Widget> _getSuggestions(SearchController searchController) {
    if (tournaments.isEmpty) return [];
    var filteredTournaments = tournaments
        .where(
          (tournament) => tournament.display
              .toLowerCase()
              .contains(searchController.text.toLowerCase()),
        )
        .toList();
    List<Widget> suggestions = [
      ...filteredTournaments.map((tournament) {
        return ListTile(
          title: Text(tournament.display),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/event/${tournament.key}');
          },
        );
      })
    ];
    return suggestions;
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
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                groups.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('You are not part of any group',
                            style: TextStyle(color: Colors.white)),
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
                              title: Text(groups[index]['name']),
                            );
                          },
                        )),
                      ),
                if (groups.isEmpty)
                  ElevatedButton(
                      child: Text('Create a New Group'),
                      onPressed: () {
                        final TextEditingController groupNameController =
                            TextEditingController();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Create a New Group'),
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
                                  child: const Text('Cancel'),
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
                                    });
                                  },
                                  child: const Text('Create'),
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
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    if (requests.isEmpty) Text('No Pending Join Requests'),
                    ExpansionPanelList.radio(
                      children: [
                        ...List.generate(requests.length, (requestIndex) {
                          return ExpansionPanelRadio(
                              value: requestIndex,
                              headerBuilder: (context, open) => ListTile(
                                    title: Text(
                                        'Group: ${requests[requestIndex].group_name}'),
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
                                              content: Text(e.toString())));
                                    });
                                  },
                                  child: Text('Delete'),
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
