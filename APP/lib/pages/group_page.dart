import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/models/group_join_request.dart';
import 'package:scouting_app/models/match_scouting_2025.dart';
import 'package:scouting_app/widgets/login_widget.dart';

import '../models/alliance_request.dart';
import '../models/group.dart';
import '../models/tournament.dart';
import '../widgets/polar_forecast_app_bar.dart';
import 'package:intl/intl.dart';
import 'scouting_report_page.dart';

class GroupPage extends StatefulWidget {
  final String group;
  final String? joinCode;
  const GroupPage(this.group, this.joinCode);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int _currentTab = 0;
  String? token;
  String? membershipData;
  Group? groupData;
  String? join_link;
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGroupData();
  }

  set group(Group? _group) {
    this.groupData = _group;
    if (mounted) {
      setState(() {
        groupData = _group;
      });
    }
  }

  set membership(String? _membership) {
    this.membershipData = _membership;
    if (mounted) {
      setState(() {
        membershipData = _membership;
      });
    }
  }

  Future<void> _fetchGroupData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      token = await apiService.token;

      if (token == null) {
        setState(() {
          loading = false;
          errorMessage = 'Please log in to access the group page.';
        });
        return;
      }

      if (widget.joinCode == null) {
        final (fetchedGroup, fetchedMembership) =
            await apiService.get_group(widget.group);
        setState(() {
          groupData = fetchedGroup;
          membershipData = fetchedMembership;
          join_link =
              '${apiService.APPURL}/group/${groupData?.name}/join/${groupData!.join_code}';
          loading = false;
        });
      } else {
        final joinResults =
            await apiService.join_group(widget.group, widget.joinCode!);

        if (joinResults.any((element) =>
            (element.group_name == widget.group) && !element.accepted)) {
          setState(() {
            errorMessage = 'Join Request Sent';
          });
        }

        final (fetchedGroup, fetchedMembership) =
            await apiService.get_group(widget.group);
        setState(() {
          groupData = fetchedGroup;
          membershipData = fetchedMembership;
          join_link =
              '${apiService.APPURL}/group/${groupData?.name}/join/${groupData!.join_code}';
          loading = false;
          errorMessage = null;
        });
      }
    } catch (error) {
      setState(() {
        loading = false;
        errorMessage = error.toString();
      });
    }
    await Future.delayed(Durations.medium1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> tabs = [
      _EventsTab(
        this,
        group: groupData,
        membership: membershipData,
      ),
      _MembersTab(
        this,
        group: groupData,
        membership: membershipData,
      ),
      _OfflineScoutingTab(),
      if (membershipData == 'owner')
        _SettingsTab(
          this,
          group: groupData,
          membership: membershipData,
        )
    ];

    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: '${widget.group}',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (newTabIdx) => setState(() => _currentTab = newTabIdx),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined,
                  color: theme.primaryColor),
              activeIcon: Icon(Icons.calendar_month, color: theme.primaryColor),
              label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.person, color: theme.primaryColor),
              label: 'Members'),
          BottomNavigationBarItem(
              icon: Icon(Icons.wifi_off_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.wifi_off, color: theme.primaryColor),
              label: 'Offline'),
          if (membershipData == 'owner')
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined, color: theme.primaryColor),
                activeIcon: Icon(Icons.settings, color: theme.primaryColor),
                label: 'Settings'),
        ],
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(color: Colors.white),
        unselectedLabelStyle: TextStyle(color: Colors.white),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: _fetchGroupData, // Calls the new fetch function
          color: Colors.blue,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: loading
                ? Center(child: CircularProgressIndicator(color: Colors.blue))
                : token == null
                    ? Center(
                        child: LoginWidget(
                        redirect_path: widget.joinCode == null
                            ? 'group/${widget.group}/'
                            : 'group/${widget.group}/join/${widget.joinCode}',
                      ))
                    : errorMessage != null
                        ? Center(
                            child: Text(errorMessage!,
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 20.0)))
                        : SizedBox(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            child: tabs[_currentTab]),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (groupData != null)
            Tooltip(
              message: 'Leave Group',
              child: FloatingActionButton.small(
                backgroundColor: Colors.red,
                shape: CircleBorder(
                  side: BorderSide(color: Colors.red),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Leave Group'),
                        content:
                            Text('Are you sure you want to leave this group?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/');
                              final apiService = Provider.of<ApiService>(
                                  context,
                                  listen: false);
                              apiService
                                  .leave_group(groupData?.name ?? '')
                                  .then((value) {})
                                  .onError((e, _) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              });
                            },
                            child: Text('Leave'),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.red),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.logout),
              ),
            ),
          if (groupData?.join_code != null) SizedBox(height: 5),
          if (groupData?.join_code != null)
            Tooltip(
              message: 'Invite Scouts',
              child: FloatingActionButton.small(
                backgroundColor: Colors.blue,
                shape: CircleBorder(
                  side: BorderSide(color: Colors.blue),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: join_link!));
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Column(
                            children: [
                              Text('Join Link Copied to Clipboard'),
                              SizedBox(height: 10),
                              QrImageView(
                                size: min(constraints.maxWidth,
                                    (constraints.maxHeight - 30)),
                                data: join_link!,
                                eyeStyle: QrEyeStyle(
                                    color: Colors.blue,
                                    eyeShape: QrEyeShape.square),
                                dataModuleStyle: QrDataModuleStyle(
                                  color: Colors.blue,
                                  dataModuleShape: QrDataModuleShape.square,
                                ),
                                embeddedImage:
                                    AssetImage('assets/PolarBearHead.png'),
                                embeddedImageStyle: QrEmbeddedImageStyle(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Icon(Icons.group_add),
              ),
            )
        ],
      ),
    );
  }
}

class _EventsTab extends StatefulWidget {
  final _GroupPageState widget;
  final Group? group;
  final String? membership;
  _EventsTab(
    this.widget, {
    Key? key,
    this.group,
    this.membership,
  }) : super(key: key);
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  List<AllianceRequest> requests = [];
  List<Tournament> tournaments = [];
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.token.then((_token) {
      if (_token != null && widget.group != null) {
        apiService.get_alliance_requests(widget.group!.name).then(
          (value) {
            var filtered = value.where((val) {
              return !val.accepted;
            }).toList();
            requests = filtered;
            if (mounted) {
              setState(() => requests = value);
            }
          },
        );
        apiService.fetchTournaments().then((_tournaments) {
          if (mounted) {
            setState(() {
              tournaments = _tournaments;
            });
          }
          tournaments = _tournaments;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    var filtered = requests.where((val) {
      return !val.accepted;
    }).toList();
    requests = filtered;
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          SizedBox(
            height: 10,
          ),
          if (widget.group != null)
            if (widget.membership != 'member')
              Card(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return FutureBuilder<List<Tournament>>(
                                  future: apiService.fetchTournaments(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return AlertDialog(
                                        title: Text('Error'),
                                        content: Text(
                                            'Failed to load events. Please try again later.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    }
                                    final tournaments = snapshot.data ?? [];
                                    String? selectedEvent;
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text('Choose an Event'),
                                          content: Column(
                                            children: [
                                              SearchAnchor.bar(
                                                barHintText: 'Select an event',
                                                suggestionsBuilder:
                                                    (context, controller) {
                                                  final filteredTournaments =
                                                      tournaments
                                                          .where((tournament) {
                                                    return tournament.display
                                                        .toLowerCase()
                                                        .contains(controller
                                                            .text
                                                            .toLowerCase());
                                                  }).toList();
                                                  return [
                                                    ListTile(
                                                      title: Text('None'),
                                                      onTap: () {
                                                        setState(() {
                                                          selectedEvent = null;
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    ...filteredTournaments
                                                        .map((tournament) {
                                                      return ListTile(
                                                        title: Text(
                                                            tournament.display),
                                                        onTap: () {
                                                          setState(() {
                                                            selectedEvent =
                                                                tournament.key;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      );
                                                    }),
                                                  ];
                                                },
                                              ),
                                              if (selectedEvent != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0),
                                                  child: Text(
                                                    'Selected Event: $selectedEvent',
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 30.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: selectedEvent != null
                                                  ? () {
                                                      apiService
                                                          .add_group_to_event(
                                                              widget.group
                                                                      ?.name ??
                                                                  '',
                                                              selectedEvent!)
                                                          .then((val) {
                                                        var (
                                                          group,
                                                          membership
                                                        ) = val;
                                                        widget.widget.group =
                                                            group;
                                                        widget.widget
                                                                .membership =
                                                            membership;
                                                      });
                                                      Navigator.of(context)
                                                          .pop(selectedEvent);
                                                    }
                                                  : null,
                                              child: Text('Confirm'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Text('Join An Event')))),
          if (widget.group != null)
            if (widget.group!.events.length == 0)
              Center(
                child: Text(
                  'Not Currently Part of Any Events',
                  style: TextStyle(color: Colors.white, fontSize: 30.0),
                ),
              ),
          ExpansionPanelList.radio(
            dividerColor: Colors.transparent,
            children: (widget.group?.events.length ?? 0) == 0
                ? []
                : List.generate(widget.group!.events.length, (int event_index) {
                    final event_requests = requests.where((request) {
                      return request.event ==
                          widget.group!.events[event_index].event_code;
                    }).toList();
                    return ExpansionPanelRadio(
                        canTapOnHeader: false,
                        value: event_index,
                        headerBuilder: (context, isExpanded) => Card(
                              child: ListTile(
                                title: ClipRect(
                                  child: Row(children: [
                                    Tooltip(
                                      message: widget.group!.events[event_index]
                                              .up_to_date
                                          ? 'Event Data Up To Date'
                                          : 'Event Data Updating',
                                      child: Container(
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget
                                                  .group!
                                                  .events[event_index]
                                                  .up_to_date
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      triggerMode: TooltipTriggerMode.tap,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    TextButton(
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.all(0)),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              '/event/${widget.group!.events[event_index].event_code}');
                                        },
                                        child: Text(
                                            tournaments.any((tournament) =>
                                                    tournament.key ==
                                                    widget
                                                        .group!
                                                        .events[event_index]
                                                        .event_code)
                                                ? tournaments
                                                    .firstWhere((tournament) =>
                                                        tournament.key ==
                                                        widget
                                                            .group!
                                                            .events[event_index]
                                                            .event_code)
                                                    .display
                                                : widget
                                                    .group!
                                                    .events[event_index]
                                                    .event_code,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.blue,
                                                decorationColor: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline)))
                                  ]),
                                ),
                              ),
                            ),
                        body: Padding(
                            padding: EdgeInsets.all(10),
                            child: LayoutBuilder(
                                builder: (contexts, constraints) =>
                                    SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      width: max(
                                                          constraints.maxWidth /
                                                              2,
                                                          200),
                                                      child: Card(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    20),
                                                            child: Column(
                                                                children: [
                                                                  Text(
                                                                      'Alliances',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              Colors.white)),
                                                                  if (widget
                                                                          .membership !=
                                                                      'member')
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              final apiService = Provider.of<ApiService>(context, listen: false);
                                                                              final year = int.parse(widget.group!.events[event_index].event_code.substring(0, 4));
                                                                              final code = widget.group!.events[event_index].event_code.substring(4);
                                                                              final event_groups = apiService.get_event_groups(code, year);
                                                                              return FutureBuilder<List>(
                                                                                  future: event_groups,
                                                                                  builder: (context, snapshot) {
                                                                                    List groups = [];
                                                                                    try {
                                                                                      groups = snapshot.requireData;
                                                                                    } catch (e) {
                                                                                      return AlertDialog(
                                                                                        title: Text('Groups at ${widget.group!.events[event_index].event_code}'),
                                                                                        content: CircularProgressIndicator(
                                                                                          color: Colors.blue,
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                    for (int i = 0; i < groups.length; i++) {
                                                                                      final group = groups[i];
                                                                                      if (group['name'] == widget.group!.name) {
                                                                                        groups.removeAt(i);
                                                                                        break;
                                                                                      }
                                                                                    }
                                                                                    return AlertDialog(
                                                                                      title: Text('Groups at ${widget.group!.events[event_index].event_code}'),
                                                                                      content: SingleChildScrollView(
                                                                                        child: Column(
                                                                                          children: [
                                                                                            if (groups.length == 0) Text('There are no other groups at ${widget.group!.events[event_index].event_code}'),
                                                                                            ...List.generate(groups.length, (int group_index) {
                                                                                              return ListTile(
                                                                                                  title: Text('${groups[group_index]['name']} - ${groups[group_index]['affiliation'].substring(3)}'),
                                                                                                  onTap: () {
                                                                                                    apiService.request_alliance(widget.group!.name, widget.group!.events[event_index].event_code, groups[group_index]['name']).then((_requests) {
                                                                                                      setState(() {
                                                                                                        this.requests = _requests;
                                                                                                      });
                                                                                                    }).onError((e, _) {
                                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                                                                                    });
                                                                                                    Navigator.of(context).pop();
                                                                                                  });
                                                                                            })
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      actions: [],
                                                                                    );
                                                                                  });
                                                                            },
                                                                          );
                                                                        },
                                                                        child: Text(
                                                                            'Create an Alliance')),
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                  if (widget
                                                                          .group!
                                                                          .events[
                                                                              event_index]
                                                                          .alliance_groups
                                                                          .length ==
                                                                      0)
                                                                    Text(
                                                                        'No Alliances'),
                                                                  if (widget
                                                                          .group!
                                                                          .events[
                                                                              event_index]
                                                                          .alliance_groups
                                                                          .length !=
                                                                      0)
                                                                    ExpansionPanelList
                                                                        .radio(
                                                                            children:
                                                                                List.generate(widget.group!.events[event_index].alliance_groups.length, (int alliance_index) {
                                                                      return ExpansionPanelRadio(
                                                                          canTapOnHeader:
                                                                              true,
                                                                          value:
                                                                              alliance_index,
                                                                          headerBuilder: (context, expanded) =>
                                                                              ListTile(title: Text('${widget.group!.events[event_index].alliance_groups[alliance_index].name} - ${widget.group!.events[event_index].alliance_groups[alliance_index].affiliation.substring(3)}')),
                                                                          body: Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              if (widget.membership != 'member')
                                                                                ElevatedButton(
                                                                                    style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white), backgroundColor: WidgetStatePropertyAll(Colors.red)),
                                                                                    onPressed: () {
                                                                                      apiService.leave_alliance(widget.group!.name, widget.group!.events[event_index].event_code, widget.group!.events[event_index].alliance_groups[alliance_index].name).then((val) {
                                                                                        var (
                                                                                          group,
                                                                                          membership
                                                                                        ) = val;
                                                                                        setState(() {
                                                                                          widget.widget.membership = membership;
                                                                                          widget.widget.group = group;
                                                                                        });
                                                                                      }).onError((e, _) {
                                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                                                                      });
                                                                                    },
                                                                                    child: Text('Leave')),
                                                                            ],
                                                                          ));
                                                                    }))
                                                                ])),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: max(
                                                          constraints.maxWidth /
                                                              2,
                                                          200),
                                                      child: Card(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    20),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  'Alliance Requests',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                if (widget.membership !=
                                                                        'owner' &&
                                                                    widget.membership !=
                                                                        'admin')
                                                                  Text(
                                                                      'You must be an owner or admin to view alliance requests'),
                                                                if (event_requests
                                                                            .length ==
                                                                        0 &&
                                                                    widget.membership !=
                                                                        'member')
                                                                  Text(
                                                                      'No Pending Requests'),
                                                                if (event_requests
                                                                        .length !=
                                                                    0)
                                                                  ExpansionPanelList
                                                                      .radio(
                                                                          children: List.generate(
                                                                              event_requests.length,
                                                                              (request_index) {
                                                                    final request =
                                                                        event_requests[
                                                                            request_index];
                                                                    if (request
                                                                            .group_1 ==
                                                                        widget
                                                                            .group!
                                                                            .name)
                                                                      return ExpansionPanelRadio(
                                                                          canTapOnHeader:
                                                                              true,
                                                                          value:
                                                                              request_index,
                                                                          headerBuilder: (context, open) =>
                                                                              ListTile(
                                                                                title: Text('${request.group_2} - ${request.group_2_affiliation.substring(3)}', style: TextStyle(fontSize: 11)),
                                                                              ),
                                                                          body:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              IconButton(
                                                                                  onPressed: () {
                                                                                    apiService.delete_alliance_request(widget.group!.name, widget.group!.events[event_index].event_code, request).then((_requests) {
                                                                                      setState(() {
                                                                                        this.requests = _requests;
                                                                                      });
                                                                                    }).onError((e, _) {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                                                                    });
                                                                                  },
                                                                                  icon: Icon(Icons.delete, color: Colors.red)),
                                                                            ],
                                                                          ));
                                                                    return ExpansionPanelRadio(
                                                                        canTapOnHeader:
                                                                            true,
                                                                        value:
                                                                            request_index,
                                                                        headerBuilder: (context,
                                                                                open) =>
                                                                            ListTile(
                                                                              title: Text('${request.group_1} - ${request.group_1_affiliation}'),
                                                                            ),
                                                                        body:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            IconButton(
                                                                                onPressed: () {
                                                                                  apiService.accept_alliance(widget.group!.name, widget.group!.events[event_index].event_code, request).then((_requests) {
                                                                                    setState(() {
                                                                                      this.requests = _requests;
                                                                                    });
                                                                                    apiService.get_group(widget.group!.name).then((val) {
                                                                                      setState(() {
                                                                                        var (
                                                                                          group,
                                                                                          membership
                                                                                        ) = val;
                                                                                        widget.widget.group = group;
                                                                                        widget.widget.membership = membership;
                                                                                      });
                                                                                    });
                                                                                  });
                                                                                },
                                                                                icon: Icon(Icons.check_rounded, color: Colors.green)),
                                                                            IconButton(
                                                                                onPressed: () {
                                                                                  apiService.decline_alliance(widget.group!.name, widget.group!.events[event_index].event_code, request).then((_requests) {
                                                                                    setState(() {
                                                                                      this.requests = _requests;
                                                                                    });
                                                                                  });
                                                                                },
                                                                                icon: Icon(Icons.close_rounded, color: Colors.red)),
                                                                          ],
                                                                        ));
                                                                  })),
                                                              ],
                                                            )),
                                                      ),
                                                    ),
                                                  ]),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Scouting Report',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Card(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  ScoutingReportPage(
                                                                group:
                                                                    '${widget.group?.name}',
                                                                event:
                                                                    '${widget.group!.events[event_index].event_code}',
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                            'View Scouting Report'),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Tap to see detailed scouting data for this event.',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                ],
                                              ),
                                              Card(
                                                child: Padding(
                                                  padding: EdgeInsets.all(20.0),
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              foregroundColor:
                                                                  Colors.white),
                                                      onPressed: () {
                                                        apiService
                                                            .remove_event_from_group(
                                                                widget.group
                                                                        ?.name ??
                                                                    '',
                                                                widget
                                                                        .group
                                                                        ?.events[
                                                                            event_index]
                                                                        .event_code ??
                                                                    '')
                                                            .then((data) {
                                                          var (_group, role) =
                                                              data;
                                                          widget.widget.group =
                                                              _group;
                                                          widget.widget
                                                                  .membership =
                                                              role;
                                                        }).onError((e, _) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      e.toString())));
                                                        });
                                                      },
                                                      child:
                                                          Text('Leave Event')),
                                                ),
                                              )
                                            ])))));
                  }),
          )
        ]));
  }
}

class _MembersTab extends StatefulWidget {
  final _GroupPageState widget;
  final Group? group;
  final String? membership;
  _MembersTab(
    this.widget, {
    Key? key,
    this.group,
    this.membership,
  }) : super(key: key);
  @override
  _MembersTabState createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  Map? members;
  List<GroupJoinRequest>? requests = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.get_group_members(widget.group?.name ?? '').then((value) {
      members = value;
      if (mounted) {
        setState(() {
          members = value;
        });
      }
      apiService
          .get_group_join_requests(widget.group?.name ?? '')
          .then((value) {
        requests = value;
        loading = false;
        if (mounted) {
          setState(() {
            requests = value;
            loading = false;
          });
        }
      }).onError((e, _) {
        loading = false;
        if (mounted)
          setState(() {
            loading = false;
          });
      });
    });
  }

  // Add drag-to-refresh functionality
  Future<void> _refreshData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      loading = true;
    });
    await apiService.get_group_members(widget.group?.name ?? '').then((value) {
      members = value;
      if (mounted) {
        setState(() {
          members = value;
        });
      }
    });
    await apiService
        .get_group_join_requests(widget.group?.name ?? '')
        .then((value) {
      requests = value;
      if (mounted) {
        setState(() {
          requests = value;
          loading = false;
        });
      }
    }).onError((e, _) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(
      context,
    );
    final filteredRequests =
        requests?.where((request) => !request.accepted).toList();
    return loading
        ? Center(child: CircularProgressIndicator(color: Colors.blue))
        : RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: 10,
                ),
                if (widget.membership != 'member')
                  Card(
                      child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('Join Requests',
                            style:
                                TextStyle(color: Colors.white, fontSize: 30)),
                        if ((filteredRequests?.length ?? 0) == 0)
                          Text('No Pending Join Requests'),
                        ExpansionPanelList.radio(elevation: 0, children: [
                          ...List.generate(
                            filteredRequests?.length ?? 0,
                            (requestIndex) => ExpansionPanelRadio(
                                canTapOnHeader: true,
                                backgroundColor: Color.fromARGB(0, 0, 0, 0),
                                value: filteredRequests![requestIndex],
                                headerBuilder: (context, isExpanded) {
                                  return ListTile(
                                    title: Text(
                                        'Username: ${filteredRequests[requestIndex].username}\nTime of Request: ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(filteredRequests[requestIndex].request_time * 1000).toLocal())}'),
                                  );
                                },
                                body: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        apiService
                                            .accept_join_request(
                                                filteredRequests[requestIndex])
                                            .then((value) {
                                          setState(() {
                                            requests = value;
                                          });
                                          apiService
                                              .get_group_members(
                                                  widget.group!.name)
                                              .then(
                                                (Map _members) => setState(() {
                                                  members = _members;
                                                }),
                                              );
                                        });
                                      },
                                      style: ButtonStyle(
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.green)),
                                      icon: Icon(Icons.check_rounded),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        apiService
                                            .decline_join_request(
                                                filteredRequests[requestIndex])
                                            .then((value) {
                                          setState(() {
                                            requests = value;
                                          });
                                        });
                                      },
                                      style: ButtonStyle(
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.red)),
                                      icon: Icon(Icons.close_rounded),
                                    )
                                  ],
                                )),
                          )
                        ]),
                      ],
                    ),
                  )),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(children: [
                      Text(
                        'Owners',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      ExpansionPanelList.radio(
                        dividerColor: Colors.blue,
                        elevation: 0,
                        children: List.generate(
                            members?['owners'].length,
                            (index) => ExpansionPanelRadio(
                                  canTapOnHeader: true,
                                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                                  value: members?['owners'][index],
                                  headerBuilder: (context, isExpanded) {
                                    return Padding(
                                      child: Text(
                                          'Owner: ${members?['owners'][index]['firstName']}'),
                                      padding: EdgeInsets.all(20),
                                    );
                                  },
                                  body: Text(
                                      members?['owners'][index]['username']),
                                )),
                      ),
                    ]),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(children: [
                      Text(
                        'Admins',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      ExpansionPanelList.radio(
                        dividerColor: Colors.blue,
                        elevation: 0,
                        children: List.generate(
                          members?['admins'].length,
                          (index) => ExpansionPanelRadio(
                              canTapOnHeader: true,
                              backgroundColor: Color.fromARGB(0, 0, 0, 0),
                              value: members?['admins'][index],
                              headerBuilder: (context, isExpanded) {
                                return Padding(
                                  child: Text(
                                      'Admin ${index + 1}: ${members?['admins'][index]['firstName']}'),
                                  padding: EdgeInsets.all(20),
                                );
                              },
                              body: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(members?['admins'][index]['username']),
                                    if (widget.membership == 'owner')
                                      SizedBox(width: 8),
                                    if (widget.membership == 'owner')
                                      ElevatedButton(
                                          onPressed: () {
                                            apiService
                                                .demote_group_member(
                                                    widget.group?.name ?? '',
                                                    members?['admins'][index]
                                                        ['id'])
                                                .then((value) {
                                              setState(() {
                                                members = value;
                                              });
                                            });
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.red),
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.white)),
                                          child: Text('Demote to Member')),
                                    if (widget.membership == 'owner')
                                      SizedBox(width: 8),
                                    if (widget.membership == 'owner')
                                      ElevatedButton(
                                        onPressed: () {
                                          apiService
                                              .promote_group_admin(
                                                  widget.group?.name ?? '',
                                                  members?['admins'][index]
                                                      ['id'])
                                              .then((value) {
                                            setState(() {
                                              members = value;
                                            });
                                          });
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.yellow),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.black)),
                                        child: Text('Promote to Owner'),
                                      )
                                  ],
                                ),
                              )),
                        ),
                      ),
                      if (members?['admins'].length == 0)
                        Text('There are no admins in your group')
                    ]),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(children: [
                      Text(
                        'Members',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      ExpansionPanelList.radio(
                        dividerColor: Colors.blue,
                        elevation: 0,
                        children: List.generate(
                          members?['members'].length,
                          (index) => ExpansionPanelRadio(
                              canTapOnHeader: true,
                              backgroundColor: Color.fromARGB(0, 0, 0, 0),
                              value: members?['members'][index],
                              headerBuilder: (context, isExpanded) {
                                return Padding(
                                  child: Text(
                                      'Member ${index + 1}: ${members?['members'][index]['firstName']}'),
                                  padding: EdgeInsets.all(20),
                                );
                              },
                              body: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!(widget.membership == 'owner' ||
                                          widget.membership == 'admin'))
                                        Text(
                                            'username: ${members?['members'][index]['username']}'),
                                      if (widget.membership == 'owner' ||
                                          widget.membership == 'admin')
                                        SizedBox(
                                          width: 10,
                                        ),
                                      if (widget.membership == 'owner' ||
                                          widget.membership == 'admin')
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.red),
                                                foregroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.white)),
                                            onPressed: () {
                                              apiService
                                                  .kick_group_member(
                                                      widget.group?.name ?? '',
                                                      members?['members'][index]
                                                          ['id'])
                                                  .then((value) {
                                                setState(() {
                                                  members = value;
                                                });
                                              });
                                            },
                                            child: Text('Kick')),
                                      if (widget.membership == 'owner')
                                        SizedBox(
                                          width: 10,
                                        ),
                                      if (widget.membership == 'owner')
                                        ElevatedButton(
                                            onPressed: () {
                                              apiService
                                                  .promote_group_member(
                                                      widget.group?.name ?? '',
                                                      members?['members'][index]
                                                          ['id'])
                                                  .then((value) {
                                                setState(() {
                                                  members = value;
                                                });
                                              });
                                            },
                                            child: Text('Promote to Admin')),
                                    ]),
                              )),
                        ),
                      ),
                      if (members?['members'].length == 0)
                        Text('There are no members in your group')
                    ]),
                  ),
                ),
              ]),
            ));
  }
}

class _SettingsTab extends StatefulWidget {
  final _GroupPageState widget;
  final Group? group;
  final String? membership;
  _SettingsTab(
    this.widget, {
    Key? key,
    this.group,
    this.membership,
  }) : super(key: key);
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 10,
      ),
      Card(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: ElevatedButton(
            onPressed: _openConfirmDelete,
            child: Text('Delete Group'),
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red),
                foregroundColor: WidgetStatePropertyAll(Colors.white))),
      )),
      Card(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'More Settings Coming Soon...',
          style: TextStyle(color: Colors.blue, fontSize: 30.0),
        ),
      ))
    ]);
  }

  _openConfirmDelete() {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to delete this group?'),
              Text('Please type "${widget.group!.name}" to confirm:'),
              TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Group Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text == widget.group!.name) {
                  Navigator.of(context).pushNamed('/');
                  final apiService =
                      Provider.of<ApiService>(context, listen: false);
                  apiService
                      .delete_group(widget.group!.name)
                      .then((value) {})
                      .onError((e, _) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Group name does not match')),
                  );
                }
              },
              child: Text('Delete'),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OfflineScoutingTab extends StatefulWidget {
  @override
  _OfflineScoutingTabState createState() => _OfflineScoutingTabState();
}

class _OfflineScoutingTabState extends State<_OfflineScoutingTab> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  TextEditingController _textController = TextEditingController();
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    this.controller = controller;
    try {
      final jsonData = jsonDecode(_textController.text);
      final matchData = MatchScouting2025.fromJson(jsonData);

      // Submit the scanned data
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.post_offline_match_scouting(matchData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match data submitted successfully!')),
      );
      setState(() {
        _textController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => Column(
              children: [
                Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight - 96,
                    child: Card(
                        child: Padding(
                      padding: EdgeInsets.all(20),
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: (QRViewController controller) {
                          this.controller = controller;
                          controller.scannedDataStream.listen((scanData) {
                            try {
                              final jsonData = jsonDecode(scanData.code!);
                              final matchData =
                                  MatchScouting2025.fromJson(jsonData);

                              // Update the text field with the scanned data
                              final prevText = _textController.text;
                              setState(() {
                                setState(() {
                                  _textController.text =
                                      jsonEncode(matchData.toJson());
                                });
                              });
                              if (prevText != _textController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Scan Successful')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error: ${e.toString()}')),
                              );
                            }
                          });
                        },
                      ),
                    ))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: 'Enter Data Manually',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      // SizedBox(height: 10),
                      ElevatedButton(
                          onPressed:
                              _textController.text.isEmpty ? null : _onSubmit,
                          child: Text('Submit'))
                    ],
                  ),
                ),
              ],
            ));
  }
}
