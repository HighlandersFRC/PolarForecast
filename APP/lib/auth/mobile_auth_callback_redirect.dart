import 'mobile_auth_callback_redirect_stub.dart'
    if (dart.library.html) 'mobile_auth_callback_redirect_web.dart';

Future<void> handoffMobileAuthCallback(Uri uri) =>
    handoffMobileAuthCallbackImpl(uri);
