import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/widgets/login_widget.dart';

import '../models/group.dart';
import '../widgets/polar_forecast_app_bar.dart';

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
  String? membership;
  Group? groupData;
  String? join_link;
  bool loading = true;
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.token.then((_token) {
      token = _token;
      if (mounted) {
        setState(() {
          token = _token;
        });
      }
      if (token != null) {
        if (widget.joinCode == null) {
          apiService.get_group(widget.group).then(
            (value) {
              var (_groupData, _membership) = value;
              groupData = _groupData;
              membership = _membership;
              join_link =
                  '${apiService.APPURL}/group/${groupData?.name}/join/${groupData!.join_code}';
              loading = false;
              if (mounted) {
                setState(() {
                  membership = _membership;
                  groupData = _groupData;
                  join_link =
                      '${apiService.APPURL}/group/${groupData?.name}/join/${groupData!.join_code}';
                  loading = false;
                });
              }
            },
          ).onError((error, stackTrace) {
            loading = false;
            errorMessage = error.toString();
            if (mounted)
              setState(() {
                loading = false;
                errorMessage = error.toString();
              });
          });
        } else {
          apiService.join_group(widget.group, widget.joinCode!).then(
            (value) {
              var (_groupData, _membership) = value;
              groupData = _groupData;
              membership = _membership;
              join_link =
                  '${apiService.APPURL}/group/${groupData?.name}/join/${groupData!.join_code}';
              loading = false;
              if (mounted) {
                setState(() {
                  membership = _membership;
                  groupData = _groupData;
                  join_link =
                      '${apiService.APPURL}/group/${groupData?.name}/join/${groupData!.join_code}';
                  loading = false;
                });
              }
            },
          ).onError((error, stackTrace) {
            loading = false;
            errorMessage = error.toString();
            if (mounted)
              setState(() {
                loading = false;
                errorMessage = error.toString();
              });
          });
        }
      } else {
        loading = false;
        if (mounted)
          setState(() {
            loading = false;
            errorMessage = 'Please log in to access the group page.';
          });
      }
    }).onError((_, __) {
      loading = false;
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> tabs = [
      _EventsTab(
        widget,
        group: groupData,
        membership: membership,
      ),
      _MembersTab(
        widget,
        group: groupData,
        membership: membership,
      ),
      _SettingsTab(
        widget,
        group: groupData,
        membership: membership,
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
              icon: Icon(Icons.settings_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.settings, color: theme.primaryColor),
              label: 'Settings'),
        ],
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black),
        selectedItemColor:
            theme.brightness == Brightness.dark ? Colors.white : Colors.black,
        showUnselectedLabels: false,
      ),
      body: loading
          ? CircularProgressIndicator(color: Colors.blue)
          : token == null
              ? Center(
                  child: LoginWidget(
                  redirect_path: widget.joinCode == null
                      ? 'group/${widget.group}/'
                      : 'group/${widget.group}/join/${widget.joinCode}',
                ))
              : errorMessage != null
                  ? Text(errorMessage!)
                  : tabs[_currentTab],
      floatingActionButton: groupData?.join_code == null
          ? null
          : ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: join_link!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Group join link copied to clipboard!'),
                  ),
                );
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.copy),
                SizedBox(
                  width: 10,
                ),
                Text('Join Code: ${groupData!.join_code}')
              ])),
    );
  }
}

class _EventsTab extends StatefulWidget {
  final GroupPage widget;
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Events Tab'),
    );
  }
}

class _MembersTab extends StatefulWidget {
  final GroupPage widget;
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
  bool loading = true;
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.get_group_members(widget.group?.name ?? '').then((value) {
      members = value;
      loading = false;
      if (mounted) {
        setState(() {
          members = value;
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
    return loading
        ? CircularProgressIndicator(color: Colors.blue)
        : SingleChildScrollView(
            child: Column(children: [
              Card(
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
                                      'Owner: ${members?['owners'][index]['username']}'),
                                  padding: EdgeInsets.all(20),
                                );
                              },
                              body: Text(members?['owners'][index]['id']),
                            )),
                  ),
                ]),
              ),
              Card(
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
                                      'Admin ${index + 1}: ${members?['admins'][index]['username']}'),
                                  padding: EdgeInsets.all(20),
                                );
                              },
                              body: Row(
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
                                                members?['admins'][index]['id'])
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
                  if (members?['admins'].length == 0)
                    Text('There are no admins in your group')
                ]),
              ),
              Card(
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
                                      'Member ${index + 1}: ${members?['members'][index]['username']}'),
                                  padding: EdgeInsets.all(20),
                                );
                              },
                              body: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
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
                  if (members?['members'].length == 0)
                    Text('There are no members in your group')
                ]),
              ),
            ]),
          );
  }
}

class _SettingsTab extends StatefulWidget {
  final GroupPage widget;
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
    return Center(
      child: Text('Settings Tab'),
    );
  }
}
