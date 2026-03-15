import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/auth/auth_service.dart';
import 'package:scouting_app/pages/event_page.dart';
import 'package:scouting_app/pages/group_page.dart';
import 'package:scouting_app/pages/match_page.dart';
import 'package:scouting_app/pages/pit_scouting_page.dart';
import 'package:scouting_app/pages/scouter_documentation.dart';
import 'package:scouting_app/pages/group_documentation.dart';
import 'package:scouting_app/pages/scouting_report_page.dart';
import 'package:scouting_app/pages/team_page.dart';
import 'package:scouting_app/pages/home_page.dart';
import 'package:scouting_app/pages/death_page.dart';
import 'package:scouting_app/pages/picture_scouting_page.dart';
import 'package:scouting_app/theme/theme_provider.dart';
import 'package:scouting_app/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String APIURL = String.fromEnvironment('PF_API_ENDPOINT'),
        AUTHURL = String.fromEnvironment('PF_KEYCLOAK_LOGIN_IP'),
        APPURL = String.fromEnvironment('APP_DOMAIN'),
        REALM = String.fromEnvironment('KEYCLOAK_REALM'),
        TBA_KEY = String.fromEnvironment('APP_TBA_KEY'),
        CLIENT = String.fromEnvironment('KEYCLOAK_APP_CLIENT_ID');

    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(
            APIURL: APIURL,
            AUTHURL: AUTHURL,
            APPURL: APPURL,
            TBA_KEY: TBA_KEY,
            REALM: REALM,
            CLIENT: CLIENT,
            authService:
                createAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT),
            cacheDuration: Duration(minutes: 2),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeDataProvider()),
      ],
      child: MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  static final RouteObserver<PageRoute> observer = RouteObserver<PageRoute>();
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeDataProvider>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Polar Forecast',
          debugShowCheckedModeBanner: false,
          home: HomePage(),
          theme: themeNotifier.themeData,
          navigatorObservers: [observer],
          onGenerateRoute: (RouteSettings settings) {
            print('routing');
            var query = null;
            try {
              query = settings.name?.split('?')[1];
            } catch (e) {}
            final path = settings.name!.split('?')[0];
            final pathSegments = path.split('/');
            if (pathSegments.isNotEmpty) {
              if (pathSegments[1] == 'event') {
                if (pathSegments.length > 4) {
                  final eventKey = pathSegments[2];
                  if (pathSegments[3] == 'team') {
                    final teamKey = pathSegments[4];
                    return MaterialPageRoute(
                      builder: (context) =>
                          TeamPage.fromKeys(context, eventKey, teamKey),
                      settings: settings,
                    );
                  } else if (pathSegments[3] == 'match') {
                    final eventKey = pathSegments[2];
                    final matchKey = pathSegments[4];
                    return MaterialPageRoute(
                      builder: (context) =>
                          MatchPage.fromKeys(context, eventKey, matchKey),
                      settings: settings,
                    );
                  } else if (pathSegments[3] == 'deaths') {
                    final eventKey = pathSegments[2];
                    final teamKey = pathSegments[4];
                    return MaterialPageRoute(
                      builder: (context) =>
                          DeathPage.fromKeys(context, eventKey, teamKey),
                      settings: settings,
                    );
                  } else if (pathSegments[3] == 'pit_scouting') {
                    final eventKey = pathSegments[2];
                    final teamKey = pathSegments[4];
                    return MaterialPageRoute(
                      builder: (context) =>
                          PitScoutingPage.fromKeys(context, eventKey, teamKey),
                      settings: settings,
                    );
                  } else if (pathSegments[3] == 'pictures') {
                    final eventKey = pathSegments[2];
                    final teamKey = pathSegments[4];
                    return MaterialPageRoute(
                      builder: (context) => PictureScoutingPage.fromKeys(
                          context, eventKey, teamKey),
                      settings: settings,
                    );
                  }
                }
                if (pathSegments.length > 2) {
                  final eventKey = pathSegments[2];
                  return MaterialPageRoute(
                    builder: (context) =>
                        EventPage.fromEventKey(context, eventKey),
                    settings: settings,
                  );
                } else {
                  return null;
                }
              }
              if (pathSegments[1] == 'group') {
                if (pathSegments.length > 2) {
                  final groupKey = pathSegments[2];
                  String? code;
                  if (pathSegments.length == 5 && pathSegments[3] == 'join') {
                    code = pathSegments[4];
                    return MaterialPageRoute(
                      builder: (context) => GroupPage(groupKey, code),
                      settings: settings,
                    );
                    //Join Group
                  } else if (pathSegments.length > 5 &&
                      pathSegments[3] == 'events' &&
                      pathSegments[5] == 'scouting_report') {
                    print('scouting Report');
                    return MaterialPageRoute(
                      builder: (context) => ScoutingReportPage(
                        group: groupKey,
                        event: pathSegments[4],
                      ),
                      settings: settings,
                    );
                    //ScoutingReport
                  } else
                    return MaterialPageRoute(
                      builder: (context) => GroupPage(groupKey, code),
                      settings: settings,
                    );
                }
              }

              if (pathSegments[1] == 'documentation') {
                if (pathSegments.length > 2) {
                  if (pathSegments[2] == 'scout') {
                    return MaterialPageRoute(
                      builder: (context) => ScouterDocumentation(),
                      settings: settings,
                    );
                  } else if (pathSegments[2] == 'groups') {
                    return MaterialPageRoute(
                      builder: (context) => GroupsDocumentation(),
                      settings: settings,
                    );
                  }
                }
              }
            }
            if (query != null) {
              return MaterialPageRoute(
                  builder: (context) => HomePage(), settings: settings);
            }
            switch (path) {
              case '/':
              case '/home':
              case '/home/':
              case '':
                return null;
              default:
                return MaterialPageRoute(builder: (context) => HomePage());
            }
          },
        );
      },
    );
  }
}
