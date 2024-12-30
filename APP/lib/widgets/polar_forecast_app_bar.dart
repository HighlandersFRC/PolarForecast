import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tournament.dart';
import '../pages/event_page.dart';
import '../api_service.dart';

bool isMobile() {
  if (kIsWeb) {
    return false;
  }
  return Platform.isAndroid || Platform.isIOS;
}

class PolarForecastSliverBar extends SliverAppBar {
  PolarForecastSliverBar({required BuildContext context, String? extraText})
      : super(
          automaticallyImplyLeading: true,
          title: !isMobile()
              ? Row(
                  children: [
                    Image.asset(
                      'assets/PolarBearHead.png',
                      height: kToolbarHeight *
                          0.8, // Adjust size based on screen width
                    ),
                    const SizedBox(
                        width: 8), // Add some spacing between image and text
                    Flexible(
                      child: Text(
                        'Polar Forecast ${extraText ?? ''}',
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
                  height:
                      kToolbarHeight * 0.8, // Adjust size based on screen width
                ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _openSearch(context);
              },
            ),
          ],
          backgroundColor: Colors.blue,
        );
}

void _openSearch(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SearchAnchor.bar(
      suggestionsBuilder: (context, searchController) async =>
          await _getSuggestions(searchController, context),
    ),
  );
}

Future<List<Widget>> _getSuggestions(
    SearchController searchController, BuildContext context) async {
  ApiService apiService = Provider.of<ApiService>(context, listen: false);
  List<Tournament> tournaments = await apiService.fetchTournaments();
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

class PolarForecastAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String? extraText;

  const PolarForecastAppBar({super.key, this.extraText})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() {
    return _PolarForecastAppBarState();
  }
}

class _PolarForecastAppBarState extends State<PolarForecastAppBar> {
  List<Tournament> tournaments = [];

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.fetchTournaments().then((tournaments) {
      setState(() {
        this.tournaments = tournaments;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isMobile() {
      if (kIsWeb) {
        return false;
      }
      return Platform.isAndroid || Platform.isIOS;
    }

    return AppBar(
      automaticallyImplyLeading: true,
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
