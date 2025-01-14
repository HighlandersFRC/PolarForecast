import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/widgets/login_widget.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> tabs = [
      _EventsTab(widget),
      _MembersTab(widget),
      _SettingsTab(widget)
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
      body: token == null
          ? LoginWidget(
              redirect_path: widget.joinCode == null
                  ? '/group/${widget.group}/'
                  : '/group/${widget.group}/join/${widget.joinCode}',
            )
          : tabs[_currentTab],
    );
  }
}

class _EventsTab extends StatefulWidget {
  final GroupPage widget;
  _EventsTab(this.widget);
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
  _MembersTab(this.widget);
  @override
  _MembersTabState createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Members Tab'),
    );
  }
}

class _SettingsTab extends StatefulWidget {
  final GroupPage widget;
  _SettingsTab(this.widget);
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
