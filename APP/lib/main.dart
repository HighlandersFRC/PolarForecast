import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/pages/event_page.dart';
import 'package:scouting_app/pages/not_found_page.dart';
import '../pages/home_page.dart';
import 'theme/theme_provider.dart';
import 'api_service.dart'; // Make sure this file contains the ApiService class
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  usePathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Initialize ApiService with the base URL for API calls
        Provider<ApiService>(
          create: (_) => ApiService(dotenv.env['API_URL'].toString()),
        ),
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
            final pathSegments = settings.name!.split('/');
            if (pathSegments.isNotEmpty) {
              if (pathSegments[1] == 'event') {
                if (pathSegments.length > 2) {
                  final eventKey = pathSegments[2];
                  return MaterialPageRoute(
                    builder: (context) =>
                        EventPage.fromEventKey(context, eventKey),
                  );
                } else {
                  return null;
                }
              }
            }
            switch (settings.name) {
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
