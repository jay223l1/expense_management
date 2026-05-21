// This is a basic Flutter widget test for the Expense Management app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_management/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash screen redirects to ListingScreen and displays properly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that Splash screen is displayed first
    expect(find.text('Cash Mate'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the 3-second splash timer to fire and complete transition
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that Listing Screen is now displayed
    // It should have the AppBar title "Cash Mate"
    expect(find.text('Cash Mate'), findsOneWidget);
    
    // It should display the empty state message
    expect(find.text('No entries found.\nTap Cash In or Cash Out to add one.'), findsOneWidget);

    // It should display the filters
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);

    // It should display the Cash In / Cash Out buttons
    expect(find.widgetWithText(ElevatedButton, 'Cash In'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Cash Out'), findsOneWidget);
  });

  testWidgets('Flow of adding an entry', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Settle splash screen
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Tap Cash In button specifically using widgetWithText
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cash In'));
    await tester.pumpAndSettle();

    // Verify Add Entry Screen is shown
    expect(find.text('Add Entry'), findsOneWidget);

    // Fill in Title and Amount using TextFields
    await tester.enterText(find.byType(TextField).at(0), 'Salary');
    await tester.enterText(find.byType(TextField).at(1), '50000');

    // Tap Save button
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify we are back on Listing Screen and the entry is shown
    expect(find.text('Salary'), findsOneWidget);
    // Since it's Cash In, the amount should be displayed under Cash In column
    expect(find.text('₹50000.0'), findsOneWidget);
  });
}

