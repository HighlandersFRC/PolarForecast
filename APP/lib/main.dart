import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/auth/auth_service.dart';
import 'package:scouting_app/pages/event_page.dart';
import 'package:scouting_app/pages/not_found_page.dart';
import '../pages/home_page.dart';
import 'theme/theme_provider.dart';
import 'api_service.dart'; // Make sure this file contains the ApiService class
// import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  // await dotenv.load(fileName: '.env');
  usePathUrlStrategy();
  runApp(MyApp());
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
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeDataProvider>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
          theme: themeNotifier.themeData,
          // initialRoute: '/home',
          onGenerateRoute: (RouteSettings settings) {
            var query = null;
            try {
              query = settings.name?.split('?')[1];
            } catch (e) {}
            final path = settings.name!.split('?')[0];
            print(path);
            final pathSegments = path.split('/');
            if (pathSegments.isNotEmpty) {
              if (pathSegments[1] == 'event') {
                if (pathSegments.length > 2) {
                  final eventKey = pathSegments[2].split('?')[0];
                  return MaterialPageRoute(
                    builder: (context) =>
                        EventPage.fromEventKey(context, eventKey),
                  );
                } else {
                  return null;
                }
              }
            }
            if (query != null) {
              return MaterialPageRoute(builder: (context) => HomePage());
            }
            switch (path) {
              case '/':
                return null;
              case '/home':
                return null;
              case '':
                return null;
              default:
                return MaterialPageRoute(builder: (context) => NotFoundPage());
            }
          },
        );
      },
    );
  }
}
