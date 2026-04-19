import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';

class GroupsDocumentation extends StatelessWidget {
  const GroupsDocumentation({Key? key}) : super(key: key);

  Widget buildSection({
    required String id,
    required String title,
    required String content,
    String? imagePath,
  }) {
    return Container(
      key: ValueKey(id),
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Font')),
          const SizedBox(height: 12),
          if (imagePath != null) Image.asset(imagePath, fit: BoxFit.fitWidth),
          if (imagePath != null) const SizedBox(height: 12),
          Text(content,
              style: const TextStyle(
                  fontSize: 16, height: 1.6, fontFamily: 'Font')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final Map<String, GlobalKey> sectionKeys = {
      'groups': GlobalKey(),
      'group_creation': GlobalKey(),
      'adding_members': GlobalKey(),
      'group_management': GlobalKey(),
      'permissions': GlobalKey(),
      'group_events': GlobalKey(),
      'alliances': GlobalKey(),
      'alliance_requests': GlobalKey(),
    };

    void scrollToSection(String id) {
      final key = sectionKeys[id];
      if (key != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }

    final tableOfContents = [
      ListTile(
          title: const Text('What are Groups?',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          onTap: () => scrollToSection('groups')),
      ListTile(
          title: const Text('Creating a Group',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          onTap: () => scrollToSection('group_creation')),
      ListTile(
          title: const Text('Adding Members',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          onTap: () => scrollToSection('adding_members')),
      ListTile(
          title: const Text('Group Management',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          onTap: () => scrollToSection('group_management')),
      ListTile(
          title: const Text('Group Permissions',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          onTap: () => scrollToSection('permissions')),
      ListTile(
          title: const Text('Joining Events',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          onTap: () => scrollToSection('group_events')),
      ListTile(
          title: const Text('What are Alliances?',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          onTap: () => scrollToSection('alliances')),
      ListTile(
          title: const Text('Requesting Alliances',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          onTap: () => scrollToSection('alliance_requests')),
    ];

    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Groups',
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            ...tableOfContents,
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contents',
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Font')),
            ...tableOfContents,
            SizedBox(height: 24),
            Container(
              key: sectionKeys['groups'],
              child: buildSection(
                id: 'groups',
                title: 'What are Groups?',
                content:
                    'Groups are how you can organize your scouting team. Your groups will contain all of your scouting team members, and will automatically compile your data. Your group can also alliance with other groups to share data, all while keeping your scouts\' personal data safe.',
                imagePath: 'assets/documentation/groups.png',
              ),
            ),
            Container(
              key: sectionKeys['group_creation'],
              child: buildSection(
                id: 'group_creation',
                title: 'Creating a Group',
                content:
                    'Follow these steps to create a group: \n    1. Click on the account icon in the top right corner.\n    2. This will open a menu where you will click "Groups".\n    3. Click on the "Create Group" button.\n    4. Enter a name for your group and click "Create"',
                imagePath: 'assets/documentation/group_creation.png',
              ),
            ),
            Container(
              key: sectionKeys['adding_members'],
              child: buildSection(
                id: 'adding_members',
                title: 'Adding Members',
                content:
                    'To add members to a group: \n    1. Click on the add members button in the bottom left of your group page.\n    2. This will open a QR Code and will copy a join link to your clipboard.\n    3. When your scouts use this code, they will send a join request to your group.\n    4. Navigate to the "Members" tab to see all of your join requests, and accept them into your group.',
                imagePath: 'assets/documentation/adding_members.png',
              ),
            ),
            Container(
              key: sectionKeys['group_management'],
              child: buildSection(
                id: 'group_management',
                title: 'Group Management',
                content:
                    'To see all of the options you have for managing a user, click on the user\'s dropdown on the "Members" tab. You can then select to kick, promote, and demote users.',
                imagePath: 'assets/documentation/group_management.png',
              ),
            ),
            Container(
              key: sectionKeys['permissions'],
              child: buildSection(
                id: 'permissions',
                title: 'Group Permissions',
                content:
                    'There are three types of members in a group, and each have different permissions:\n    1. Member\n        \u2022 Submit pit scouting data\n        \u2022 Submit match scouting data\n        \u2022 Submit picture scouting data\n        \u2022 Access to data analysis tools\n        \u2022 Self data management\n    2. Admin\n        \u2022 All Member Permissions\n        \u2022 Access to Join Code/Link\n        \u2022 Accept/Decline Join Requests\n        \u2022 Submit/Delete Alliance Requests\n        \u2022 Accept/Decline Alliance Requests\n        \u2022 Join/Leave Alliances\n        \u2022 Delete/Edit Data\n        \u2022 Add/Remove Events\n        \u2022 Kick Members\n    3. Owner\n        \u2022 All Admin Permissions\n        \u2022 Promote/Demote Members and Admins\n        \u2022 Delete Group',
              ),
            ),
            Container(
              key: sectionKeys['group_events'],
              child: buildSection(
                id: 'group_events',
                title: 'Joining Events',
                content:
                    'To start compiling data for an event, an admin must add the event in the group dashboard. To add an event follow these steps:\n    1. Click on the "Events" tab in your group dashboard.\n    2. Click on the "Join An Event" button.\n    3. Enter the event key and click "Add".\n    4. Your group will now be able to submit data for this event, as well as alliance with groups at the event.',
                imagePath: 'assets/documentation/group_events.png',
              ),
            ),
            Container(
              key: sectionKeys['alliances'],
              child: buildSection(
                id: 'alliances',
                title: 'What are Alliances?',
                content:
                    'Alliances allow multiple groups who are attending the same event to easily share data. Allianced groups will be able to see each other\'s data, and will be able to submit data for each other. This allows for a more complete scouting experience, even for teams with less scouting bandwidth. Polar Forecast will automatically manage all data, including match scouting, pit scouting, and more.',
              ),
            ),
            Container(
              key: sectionKeys['alliance_requests'],
              child: buildSection(
                id: 'alliance_requests',
                title: 'Alliance Requests',
                content:
                    'When you click on the dropdown for a particular event in the events tab, you will see options regarding alliances. You can request an alliance from here, and any pending alliance requests will also populate here. By clicking on the dropdown of an alliance request, you can accept, decline, or delete the alliance requests.',
                imagePath: 'assets/documentation/alliance_requests.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
