import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/mobile_auth_callback_redirect.dart';
import '../auth/mobile_auth_config.dart';

class MobileAuthCallbackPage extends StatefulWidget {
  const MobileAuthCallbackPage({super.key});

  @override
  State<MobileAuthCallbackPage> createState() => _MobileAuthCallbackPageState();
}

class _MobileAuthCallbackPageState extends State<MobileAuthCallbackPage> {
  late final Uri _appCallbackUri;

  @override
  void initState() {
    super.initState();
    _appCallbackUri = mobileAppCallbackUri(
      queryParameters: {
        for (final entry in Uri.base.queryParameters.entries)
          entry.key: entry.value,
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openApp();
    });
  }

  Future<void> _openApp() async {
    if (kIsWeb) {
      await handoffMobileAuthCallback(_appCallbackUri);
      return;
    }

    await launchUrl(_appCallbackUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = Uri.base.queryParameters.containsKey('error');

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasError ? 'Sign-in Needs Attention' : 'Returning To App',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasError
                          ? 'The browser received an authentication response, but the app may need you to reopen it.'
                          : 'If Polar Forecast does not reopen automatically, use the button below.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _openApp,
                      child: const Text('Open Polar Forecast'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
