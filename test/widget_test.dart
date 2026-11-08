import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fixnoww/main.dart';

const _longAddress =
    'No. 123/45, Very Long Temporary Street Name, Near The Old Bus Stand, Colombo 05';

/// Flutter tests use a placeholder font with very wide letters. Loading the
/// real one means a layout overflow here is an overflow on a real phone.
Future<void> _loadRealFont() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  final file =
      File('$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
  final loader = FontLoader('Roboto')
    ..addFont(file.readAsBytes().then((b) => ByteData.sublistView(b)));
  await loader.load();
}

Future<void> _startApp(WidgetTester t) async {
  t.view.physicalSize = const Size(720, 1600);
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
  await t.pumpWidget(const ProviderScope(child: FixNowwApp()));
  await t.pumpAndSettle();
}

/// Waits for any pop-up message to disappear.
Future<void> _settle(WidgetTester t) async {
  await t.pump(const Duration(seconds: 5));
  await t.pumpAndSettle();
}

Future<void> _tap(WidgetTester t, Finder finder) async {
  await _settle(t);
  await t.ensureVisible(finder);
  await t.pumpAndSettle();
  await t.tap(finder);
  await t.pumpAndSettle();
}

Future<void> _login(WidgetTester t, String phone) async {
  await t.enterText(find.byType(TextField), phone);
  await t.tap(find.textContaining('Send Code'));
  await t.pumpAndSettle();
  for (var i = 0; i < 4; i++) {
    await t.enterText(find.byType(TextField).at(i), '1234'[i]);
    await t.pump();
  }
  await t.tap(find.textContaining('Verify & Continue'));
  await t.pumpAndSettle();
}

Future<void> _logout(WidgetTester t) async {
  await _tap(t, find.text('Profile').last);
  await t.tap(find.text('Logout'));
  await t.pumpAndSettle();
}

Future<void> _createPlumbingBooking(WidgetTester t) async {
  await _tap(t, find.text('Plumbing').first);
  await t.enterText(find.byType(TextField).at(0), _longAddress);
  await t.enterText(find.byType(TextField).at(1), 'TEMP leaking tap');
  await _tap(t, find.text('Select date & time'));
  await t.tap(find.text('OK'));
  await t.pumpAndSettle();
  await t.tap(find.text('OK'));
  await t.pumpAndSettle();
  await _tap(t, find.text('Submit Request'));
  expect(find.text('TEMP leaking tap'), findsOneWidget);
}

Future<void> _openIncomingAsKasun(WidgetTester t) async {
  await _login(t, '0701111111');
  await _createPlumbingBooking(t);
  await _logout(t);
  await _login(t, '0771234567');
  expect(find.text('TEMP leaking tap'), findsOneWidget);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadRealFont();
  });

  testWidgets('any number and code reach role select in debug builds',
      (t) async {
    await _startApp(t);
    await t.enterText(find.byType(TextField), '0712345678');
    await t.tap(find.textContaining('Send Code'));
    await t.pumpAndSettle();

    expect(find.text('Enter the code for +94 712345678'), findsOneWidget);
    await t.tap(find.textContaining('Verify & Continue'));
    await t.pumpAndSettle();

    expect(find.text('How will you use fixNoww?'), findsOneWidget);
    await t.tap(find.text('I need a service'));
    await t.pumpAndSettle();
    expect(find.text('Amaya Silva'), findsOneWidget);
  });

  testWidgets('booking form requires every field', (t) async {
    await _startApp(t);
    await _login(t, '0701111111');
    await _tap(t, find.text('Plumbing').first);

    await _tap(t, find.text('Submit Request'));
    expect(find.text('Enter the job address'), findsOneWidget);
    expect(find.text('Choose a date and time'), findsOneWidget);
    expect(find.text('Describe the problem'), findsOneWidget);
    expect(find.text('New Booking'), findsOneWidget);
  });

  testWidgets('cancelling the date picker does not open the time picker',
      (t) async {
    await _startApp(t);
    await _login(t, '0701111111');
    await _tap(t, find.text('Plumbing').first);

    await _tap(t, find.text('Select date & time'));
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();

    expect(find.text('Select time'), findsNothing);
    expect(find.text('Select date & time'), findsOneWidget);
  });

  testWidgets('cancelling asks first and keeps the booking', (t) async {
    await _startApp(t);
    await _login(t, '0701111111');
    await _tap(t, find.text('My Requests'));
    await _tap(t, find.text('Fix living room lights'));

    await _tap(t, find.text('Cancel Booking'));
    await t.tap(find.text('Keep Booking'));
    await t.pumpAndSettle();
    expect(find.text('Booking Details'), findsOneWidget);

    await _tap(t, find.text('Cancel Booking'));
    await t.tap(find.text('Cancel Booking').last);
    await t.pumpAndSettle();
    expect(find.text('Fix living room lights'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
  });

  testWidgets('customer can call the assigned provider', (t) async {
    await _startApp(t);
    await _login(t, '0701111111');
    await _tap(t, find.text('Kitchen sink repair'));
    expect(find.text('Call Provider'), findsOneWidget);
  });

  testWidgets('long addresses fit and invalid prices are refused', (t) async {
    await _startApp(t);
    await _openIncomingAsKasun(t);

    // The request card shows when the job is scheduled.
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);

    await _tap(t, find.textContaining('Accept'));
    await t.tap(find.text('Confirm'));
    await t.pump();
    expect(find.text('Enter a price greater than 0'), findsOneWidget);

    await t.enterText(find.byType(TextField), '-100');
    await t.tap(find.text('Confirm'));
    await t.pump();
    expect(find.text('Enter a price greater than 0'), findsOneWidget);
    expect(find.text('Set Job Price'), findsOneWidget);
  });

  testWidgets('declined jobs disappear for that provider only', (t) async {
    await _startApp(t);
    await _openIncomingAsKasun(t);

    await _tap(t, find.textContaining('Decline'));
    expect(find.text('TEMP leaking tap'), findsNothing);

    await _logout(t);
    await _login(t, '0701111111');
    await _tap(t, find.text('My Requests'));
    expect(find.text('Pending'), findsNWidgets(2));
  });

  testWidgets('offline providers do not see requests', (t) async {
    await _startApp(t);
    await _openIncomingAsKasun(t);

    await t.tap(find.text('Online'));
    await t.pumpAndSettle();
    expect(find.text('TEMP leaking tap'), findsNothing);
    expect(
      find.text("You're offline. Go online to receive requests."),
      findsOneWidget,
    );

    await t.tap(find.text('Offline'));
    await t.pumpAndSettle();
    expect(find.text('TEMP leaking tap'), findsOneWidget);
  });

  testWidgets('completing a job adds to earnings once', (t) async {
    await _startApp(t);
    await _openIncomingAsKasun(t);
    expect(find.text('Rs. 8,500'), findsOneWidget);

    await _tap(t, find.textContaining('Accept'));
    await t.enterText(find.byType(TextField), '2500');
    await t.tap(find.text('Confirm'));
    await t.pumpAndSettle();
    expect(find.text('Job Details'), findsOneWidget);

    await _tap(t, find.text('Mark as Started'));
    await _tap(t, find.text('Mark as Completed'));
    expect(find.text('Job Completed ✓'), findsOneWidget);

    await _settle(t);
    await t.tap(find.byIcon(Icons.arrow_back_ios_new));
    await t.pumpAndSettle();
    expect(find.text('Rs. 11,000'), findsOneWidget);
  });
}
