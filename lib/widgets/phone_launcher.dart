import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone's dialler with the number filled in. It doesn't place the
/// call, so the user still has to press call.
Future<void> openDialler(BuildContext context, String number) async {
  final messenger = ScaffoldMessenger.of(context);
  final digits = number.replaceAll(RegExp(r'[^0-9+]'), '');

  var opened = false;
  try {
    opened = await launchUrl(Uri(scheme: 'tel', path: digits));
  } catch (_) {
    // Handled below, so devices without a dialler still get a message.
  }

  if (!opened) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not open the dialler. Call $number.')),
    );
  }
}
