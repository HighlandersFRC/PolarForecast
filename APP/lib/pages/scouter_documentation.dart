import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';

class ScouterDocumentation extends StatelessWidget {
  ScouterDocumentation({Key? key}) : super(key: key);
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
          if (imagePath != null)
            Column(
              children: [
                Image.asset(imagePath, fit: BoxFit.cover),
                const SizedBox(height: 12),
              ],
            ),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final Map<String, GlobalKey> sectionKeys = {
      'general': GlobalKey(),
      'pit': GlobalKey(),
      'pictures': GlobalKey(),
      'followups': GlobalKey(),
      'editing': GlobalKey(),
      'auto': GlobalKey(),
      'data-checking': GlobalKey(),
      'data-display': GlobalKey(),
      'event-rankings': GlobalKey(),
      'match-predictions': GlobalKey(),
      'team-comparisons': GlobalKey(),
      'scouting-tips': GlobalKey(),
      'charts': GlobalKey(),
      'schedule': GlobalKey(),
      'autos': GlobalKey(),
      'stats': GlobalKey(),
      'pictures_display': GlobalKey(),
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
        title: const Text('General', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('general'),
      ),
      ListTile(
        title:
            const Text('Pit Scouting', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('pit'),
      ),
      ListTile(
        title: const Text('Capturing Pictures',
            style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('pictures'),
      ),
      ListTile(
        title: const Text('Follow-Ups', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('followups'),
      ),
      ListTile(
        title: const Text('Editing Pit Scouting Data',
            style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('editing'),
      ),
      ListTile(
        title:
            const Text('Auto Scouting', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('auto'),
      ),
      ListTile(
        title:
            const Text('Data Checking', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('data-checking'),
      ),
      ListTile(
        title:
            const Text('Event Rankings', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('event-rankings'),
      ),
      ListTile(
        title: const Text('Match Predictions',
            style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('match-predictions'),
      ),
      ListTile(
        title: const Text('Team Comparisons',
            style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('team-comparisons'),
      ),
      ListTile(
        title: const Text('Charts', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('charts'),
      ),
      ListTile(
        title: const Text('Schedule', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('schedule'),
      ),
      ListTile(
        title: const Text('Autos', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('autos'),
      ),
      ListTile(
        title: const Text('Stats', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('stats'),
      ),
      ListTile(
        title: const Text('Pictures', style: TextStyle(color: Colors.white)),
        onTap: () => scrollToSection('pictures_display'),
      ),
    ];

    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'How to Scout',
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
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            ...tableOfContents,
            Container(
              key: sectionKeys['general'],
              child: buildSection(
                id: 'general',
                title: 'General',
                content:
                    'To see event data, use the search button on the top right from any page. From there, here are a set of guidelines:\n\n    - Any blue underlined elements link to new pages.\n\n    - Tabs on any given page can be found on the bottom of the page.\n\n    - Many Features are locked behind an account. Create one by clicking on the profile icon in the top right, and clicking login. From there, you can click to create a new account, and go from there.\n\n    -Some locked behind a group. Make sure to check out that documentation as well.(Question Mark icon in the top right)',
              ),
            ),
            Container(
              key: sectionKeys['pit'],
              child: buildSection(
                id: 'pit',
                title: 'Pit Scouting',
                content:
                    'To reduce communication errors and duplicate entries a way to check this information beforehand is built into Polar Forecast. The status system is built so that whenever a team has been pit scouted, their pit scouting status goes from “Not Started” to “Done”. If the form was left incomplete, then it shows “Incomplete”. A similar thing is done with picture collection, and upon upload, the backend changes the picture status to “Done”. Click on a status to open its respective form.',
                imagePath: 'assets/documentation/pit_scouting.png',
              ),
            ),
            Container(
              key: sectionKeys['pictures'],
              child: buildSection(
                id: 'pictures',
                title: 'Capturing Pictures',
                content:
                    'Click on the add image buttons from the team’s picture form page. This will open your device’s camera app. Make sure you take at least one picture per section.',
                imagePath: 'assets/documentation/pictures.png',
              ),
            ),
            Container(
              key: sectionKeys['followups'],
              child: buildSection(
                id: 'followups',
                title: 'Follow-Ups',
                content:
                    'If a robot dies (and is reported as dead in match scouting), a form appears in the follow-ups of that team. A scout is then sent to inquire about this robot’s failures and their respective severity.',
                imagePath: 'assets/documentation/follow_ups.png',
              ),
            ),
            Container(
              key: sectionKeys['editing'],
              child: buildSection(
                id: 'editing',
                title: 'Match Scouting',
                content:
                    'A list of all of tha match scouting forms entered by scouts',
                imagePath: 'assets/documentation/match_scouting.png',
              ),
            ),
            Container(
              key: sectionKeys['auto'],
              child: buildSection(
                id: 'auto',
                title: 'Auto Scouting',
                content:
                    'When you are trying to scout an auto, click on the team’s pit scouting area and in that form locate the add auto button. Use the labelled areas for each scoring area. There will be a list of all the steps that the auto takes once you start clicking the buttons. You can delete the steps or hold and drag the right side of them to reorder.',
                imagePath: 'assets/documentation/auto_scouting.png',
              ),
            ),
            Container(
              key: sectionKeys['data-checking'],
              child: buildSection(
                id: 'data-checking',
                title: 'Data Checking',
                content:
                    'To ensure that scouts are entering good data, simple checks are run on the metadata fields. The backend checks if the given match has the given team number. If the scout passes these checks, the system will submit the entry instantly. If not, the form will display the error for correction.',
                imagePath: 'assets/documentation/data_checking.png',
              ),
            ),
            Container(
              key: sectionKeys['event-rankings'],
              child: buildSection(
                id: 'event-rankings',
                title: 'Event Rankings',
                content:
                    'The rankings tab of the event page shows a table with major stats for each team. You can sort by any stat and also click on underlined cells for additional info.',
                imagePath: 'assets/documentation/rankings.png',
              ),
            ),
            Container(
              key: sectionKeys['match-predictions'],
              child: buildSection(
                id: 'match-predictions',
                title: 'Match Predictions',
                content:
                    'The match predictions can be found on each match\'s page. It shows a full breakdown of the match, including different scoring aspects, as well as RPs. The other two tabs can be used to analyze autonomous. The draw button in the bottom right opens a drawing board to help visualize match strategies.',
                imagePath: 'assets/documentation/match_predictions.png',
              ),
            ),
            Container(
              key: sectionKeys['team-comparisons'],
              child: buildSection(
                id: 'team-comparisons',
                title: 'Team Comparisons',
                content:
                    'The team comparison tool allows you to compare two teams side-by-side by game pieces in a match. These graphs are generated purely from scouting data. It can be found in the charts tab of the event page.',
                imagePath: 'assets/documentation/team_comparisons.png',
              ),
            ),
            Container(
              key: sectionKeys['charts'],
              child: buildSection(
                id: 'charts',
                title: 'Charts',
                content:
                    'The charts tab of the event page contains a list of all the charts generated from scouting data. You can click on any chart to view it in detail.',
                imagePath: 'assets/documentation/charts.png',
              ),
            ),
            Container(
              key: sectionKeys['schedule'],
              child: buildSection(
                id: 'schedule',
                title: 'Schedule',
                content:
                    'The event page has two tabs for displaying schedules, “quals” and “eliminations”. These contain tables that show results or predictions for each match.',
                imagePath: 'assets/documentation/schedule.png',
              ),
            ),
            Container(
              key: sectionKeys['autos'],
              child: buildSection(
                id: 'autos',
                title: 'Autos',
                content:
                    'The autos tab displays all of the autonomous routines scouted during the tournament, allowing quick and easy searches.',
                imagePath: 'assets/documentation/auto_scouting.png',
              ),
            ),
            Container(
              key: sectionKeys['stats'],
              child: buildSection(
                id: 'stats',
                title: 'Stats',
                content:
                    'The team page includes a “Team Stats” tab displaying every metric calculated in the analysis, making it easy to view all attributes.',
                imagePath: 'assets/documentation/stats.png',
              ),
            ),
            Container(
              key: sectionKeys['pictures_display'],
              child: buildSection(
                id: 'pictures_display',
                title: 'Pictures',
                content:
                    'On the “Pictures” tab, all pictures captured by scouts are displayed. You can click to enlarge or right-click to delete images.',
                imagePath: 'assets/documentation/pictures_display.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
