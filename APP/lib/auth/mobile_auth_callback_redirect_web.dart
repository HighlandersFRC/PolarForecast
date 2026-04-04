// ignore_for_file: deprecated_member_use

import 'dart:html' as html;

Future<void> handoffMobileAuthCallbackImpl(Uri uri) async {
  html.window.location.href = uri.toString();
}
