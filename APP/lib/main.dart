import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/auth/auth_service.dart';
import 'package:scouting_app/pages/event_page.dart';
import 'package:scouting_app/pages/group_page.dart';
import 'package:scouting_app/pages/match_page.dart';
import 'package:scouting_app/pages/not_found_page.dart';
import 'package:scouting_app/pages/pit_scouting_page.dart';
import 'package:scouting_app/pages/team_page.dart';
import '../pages/home_page.dart';
import 'pages/death_page.dart';
import 'pages/picture_scouting_page.dart';
import 'theme/theme_provider.dart';
import 'api_service.dart'; // Make sure this file contains the ApiService class
// import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  // await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String APIURL = const String.fromEnvironment('PF_API_ENDPOINT'),
        AUTHURL = const String.fromEnvironment('PF_KEYCLOAK_LOGIN_IP'),
        APPURL = const String.fromEnvironment('APP_DOMAIN'),
        REALM = const String.fromEnvironment('KEYCLOAK_REALM'),
        CLIENT = const String.fromEnvironment('KEYCLOAK_APP_CLIENT_ID');
    return MultiProvider(
      providers: [
        // Initialize ApiService with the base URL for API calls

        Provider<ApiService>(
            create: (_) => ApiService(
                  APIURL: APIURL,
                  AUTHURL: AUTHURL,
                  APPURL: APPURL,
                  REALM: REALM,
                  CLIENT: CLIENT,
                  authService:
                      createAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT),
                  cacheDuration: Duration(minutes: 5),
                )),
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
          // initialRoute: '/home',
          onGenerateRoute: (RouteSettings settings) {
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
                    // Team Page
                    final teamKey = pathSegments[4];
                    return MaterialPageRoute(
                        builder: (context) =>
                            TeamPage.fromKeys(context, eventKey, teamKey),
                        settings: settings);
                  } else if (pathSegments[3] == 'match') {
                    // Match Page
                    final eventKey = pathSegments[2];
                    final matchKey = pathSegments[4];
                    return MaterialPageRoute(
                        builder: (context) =>
                            MatchPage.fromKeys(context, eventKey, matchKey),
                        settings: settings);
                  } else if (pathSegments[3] == 'deaths') {
                    // Death Page
                    final eventKey = pathSegments[2];
                    final teamKey = pathSegments[4];
                    return MaterialPageRoute(
                        builder: (context) =>
                            DeathPage.fromKeys(context, eventKey, teamKey),
                        settings: settings);
                  } else if (pathSegments[3] == 'pit_scouting') {
                    // Death Page
                    final eventKey = pathSegments[2];
                    final teamKey = pathSegments[4];
                    return MaterialPageRoute(
                        builder: (context) => PitScoutingPage.fromKeys(
                            context, eventKey, teamKey),
                        settings: settings);
                  } else if (pathSegments[3] == 'pictures') {
                    final eventKey = pathSegments[2];
                    final teamKey = pathSegments[4];
                    return MaterialPageRoute(
                        builder: (context) => PictureScoutingPage.fromKeys(
                            context, eventKey, teamKey),
                        settings: settings);
                  }
                }
                if (pathSegments.length > 2) {
                  // Event Page
                  final eventKey = pathSegments[2];
                  return MaterialPageRoute(
                      builder: (context) =>
                          EventPage.fromEventKey(context, eventKey),
                      settings: settings);
                } else {
                  return null;
                }
              }
              if (pathSegments[1] == 'group') {
                if (pathSegments.length > 2) {
                  // Group Page
                  final groupKey = pathSegments[2];
                  String? code;
                  if (pathSegments.length > 4) {
                    if (pathSegments[3] == 'join') {
                      code = pathSegments[4];
                    }
                  }
                  return MaterialPageRoute(
                      builder: (context) => GroupPage(groupKey, code),
                      settings: settings);
                }
              }
            }
            if (query != null) {
              return MaterialPageRoute(
                  builder: (context) => HomePage(), settings: settings);
            }
            switch (path) {
              case '/':
                return null;
              case '/home':
                return null;
              case '/home/':
                return null;
              case '':
                return null;
              default:
                return MaterialPageRoute(
                    builder: (context) => NotFoundPage(), settings: settings);
            }
          },
        );
      },
    );
  }
}
