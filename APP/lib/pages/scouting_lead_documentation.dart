import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';

class ScoutingLeadDocumentation extends StatelessWidget {
  const ScoutingLeadDocumentation({Key? key}) : super(key: key);

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
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (imagePath != null) Image.asset(imagePath, fit: BoxFit.fitWidth),
          if (imagePath != null) const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final Map<String, GlobalKey> sectionKeys = {
      'pit': GlobalKey(),
      'pictures': GlobalKey(),
      'followups': GlobalKey(),
      'editing': GlobalKey(),
      'auto': GlobalKey(),
      'data-checking': GlobalKey(),
      'data-display': GlobalKey(),
      'rankings': GlobalKey(),
      'charts': GlobalKey(),
      'schedule': GlobalKey(),
      'autos': GlobalKey(),
      'stats': GlobalKey(),
      'match-scouting': GlobalKey(),
      'deaths': GlobalKey(),
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
      Navigator.of(context).pop(); // Close the drawer after selection
    }

    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Scouting Lead Documentation',
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
            ListTile(
                title: const Text('Pit Scouting',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('pit')),
            ListTile(
                title: const Text('Capturing Pictures',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('pictures')),
            ListTile(
                title: const Text('Follow-Ups',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('followups')),
            ListTile(
                title: const Text('Editing Pit Scouting Data',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('editing')),
            ListTile(
                title: const Text('Auto Scouting',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('auto')),
            ListTile(
                title: const Text('Data Checking',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('data-checking')),
            ListTile(
                title: const Text('Data Display',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('data-display')),
            const Divider(color: Colors.white54),
            ListTile(
                title: const Text('Rankings',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('rankings')),
            ListTile(
                title:
                    const Text('Charts', style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('charts')),
            ListTile(
                title: const Text('Schedule',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('schedule')),
            ListTile(
                title:
                    const Text('Stats', style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('stats')),
            ListTile(
                title: const Text('Match Scouting Data',
                    style: TextStyle(color: Colors.white)),
                onTap: () => scrollToSection('match-scouting')),
          ],
        ),
      ),
      body: Expanded(
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                key: sectionKeys['pit'],
                child: buildSection(
                  id: 'pit',
                  title: 'Pit Scouting',
                  content:
                      'To reduce communication errors and duplicate entries, the Polar Forecast system uses a status-based method to mark teams as "Done", "Incomplete", or "Not Started".',
                  imagePath: 'assets/documentation/pit_scouting.png',
                ),
              ),
              Container(
                key: sectionKeys['pictures'],
                child: buildSection(
                  id: 'pictures',
                  title: 'Capturing Pictures',
                  content:
                      'Click "Capture Image" from the team’s picture form page to open the camera. Take a clear picture showing the robot’s vitals.',
                  imagePath: 'assets/documentation/pictures.png',
                ),
              ),
              Container(
                  key: sectionKeys['followups'],
                  child: buildSection(
                    id: 'followups',
                    title: 'Follow-Ups',
                    content:
                        'If a robot dies during a match, the system automatically creates a follow-up form for scouts to fill out.',
                    imagePath: 'assets/documentation/follow_ups.png',
                  )),
              Container(
                  key: sectionKeys['editing'],
                  child: buildSection(
                      id: 'editing',
                      title: 'Editing Pit Scouting Data',
                      content:
                          'You can revisit the pit scouting form to view and overwrite previous entries.')),
              Container(
                  key: sectionKeys['auto'],
                  child: buildSection(
                    id: 'auto',
                    title: 'Auto Scouting',
                    content:
                        'Click "Add Auto" in the pit scouting form to create and reorder autonomous steps.',
                    imagePath: 'assets/documentation/auto_scouting.png',
                  )),
              Container(
                  key: sectionKeys['rankings'],
                  child: buildSection(
                      id: 'rankings',
                      title: 'Rankings',
                      content:
                          'Displays team rank, RPs, auto and teleop coral points, climb rate, OPR, and death rate in sortable tables.',
                      imagePath: 'assets/documentation/rankings.png')),
              Container(
                  key: sectionKeys['charts'],
                  child: buildSection(
                      id: 'charts',
                      title: 'Charts',
                      content:
                          'Column graphs with OPR and cycle breakdowns. Teams can be directly compared by selecting them from a dropdown, and clicking the compare button.',
                      imagePath: 'assets/documentation/charts.png')),
              Container(
                  key: sectionKeys['schedule'],
                  child: buildSection(
                      id: 'schedule',
                      title: 'Schedule',
                      content:
                          'Shows qualification and elimination matches with results and predictions. Clickable links redirect to individual match pages.',
                      imagePath: 'assets/documentation/schedule.png')),
              Container(
                  key: sectionKeys['stats'],
                  child: buildSection(
                      id: 'stats',
                      title: 'Stats',
                      content: 'Displays all calculated metrics for each team.',
                      imagePath: 'assets/documentation/stats.png')),
              Container(
                  key: sectionKeys['match-scouting'],
                  child: buildSection(
                      id: 'match-scouting',
                      title: 'Match Scouting Data',
                      content:
                          'Lists all scouting entries with options to enable, disable, or delete entries.',
                      imagePath: 'assets/documentation/match_scouting.png')),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/documentation/scout');
                  },
                  child: Text('Read more on the Scout Documentation',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                          decorationColor: Colors.blue,
                          color: Colors.blue))),
            ],
          ),
        ),
      ),
    );
  }
}
