// Widget tests for the role-based flows of the My Town App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/config/routes.dart';
import 'package:flutter_ui_taksi/screens/screen.dart';
import 'package:flutter_ui_taksi/services/api_service.dart';
import 'api_stub.dart';

extension on ApiService {
  ApiService build() => this;
}

/// Builds a stub API service seeded with the Nyeri foods + delivery catalog
/// that the food/delivery/groceries widget tests expect.
ApiService _foodDeliveryStub() {
  return ApiStub(
    restaurants: {
      1: {'id': 1, 'name': 'Gakere Road Kitchen', 'address': 'Gakere Road, Nyeri', 'rating': 4.6, 'eta_min': 25},
      2: {'id': 2, 'name': 'Kimathi Street Cafe', 'address': 'Kimathi Street, Nyeri', 'rating': 4.4, 'eta_min': 15},
      3: {'id': 3, 'name': 'Nyeri Choma Corner', 'address': 'Central Avenue, Nyeri', 'rating': 4.8, 'eta_min': 35},
    },
    menu: {
      1: [
        {'id': 1, 'name': 'Ugali & nyama choma', 'price': 450.0},
        {'id': 2, 'name': 'Githeri special', 'price': 250.0},
        {'id': 3, 'name': 'Pilau nyama', 'price': 400.0},
        {'id': 4, 'name': 'Chapati & beans', 'price': 120.0},
        {'id': 5, 'name': 'Maziwa lala', 'price': 80.0},
      ],
    },
  ).build();
}

/// Uses a phone-sized logical window so screens are not clipped in tests.
void _prepareScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Mirrors the app theme: `AppTextSearch` requires a divider color.
ThemeData _theme() {
  return ThemeData(
    brightness: Brightness.dark,
    dividerTheme: const DividerThemeData(color: Pallete.s),
  );
}

Widget _app() {
  return MaterialApp(
    theme: _theme(),
    home: const RolesPage(),
    onGenerateRoute: Routes.generateRoute,
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  testWidgets('roles page lists client, driver, admin and my rides',
      (WidgetTester tester) async {
    _prepareScreen(tester);
    await tester.pumpWidget(_app());

    expect(find.text('Client'), findsOneWidget);
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('My rides'), findsOneWidget);
  });

  testWidgets('roles page opens driver home', (WidgetTester tester) async {
    _prepareScreen(tester);
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Driver'));
    await tester.pumpAndSettle();

    expect(find.text('Peter Hetfield'), findsOneWidget);
    expect(find.text('Incoming requests'), findsOneWidget);

    // Accepting a request removes it from the incoming list...
    await _tapVisible(tester, find.text('ACCEPT').first);
    expect(find.text('Rina Saputra'), findsNothing);

    // ...and moves it into the trips tab (once the confirmation snackbar
    // has finished showing and timed out).
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    expect(find.text('Just now'), findsOneWidget);

    // Offline mode replaces the request list with a go-online prompt.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('GO ONLINE'), findsOneWidget);
  });

  testWidgets('roles page opens admin dashboard', (WidgetTester tester) async {
    _prepareScreen(tester);
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Rides today'), findsOneWidget);
    expect(find.text('Live activity'), findsOneWidget);

    // Approving a pending driver updates their status chip.
    await tester.tap(find.text('Drivers'));
    await tester.pumpAndSettle();
    expect(find.text('PENDING'), findsNWidgets(2));
    expect(find.text('APPROVE'), findsNWidgets(2));

    await _tapVisible(tester, find.text('APPROVE').first);
    await tester.pumpAndSettle();
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('ACTIVE'), findsNWidgets(2));
  });

  testWidgets('my rides opens client activity tabs',
      (WidgetTester tester) async {
    _prepareScreen(tester);
    await tester.pumpWidget(_app());

    await tester.tap(find.text('My rides'));
    await tester.pumpAndSettle();

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Nyeri County Referral Hospital'), findsOneWidget);
  });

  testWidgets('trip progress finishes trip and asks for rating',
      (WidgetTester tester) async {
    _prepareScreen(tester);
    await tester.pumpWidget(MaterialApp(
      theme: _theme(),
      home: const TripProgressPage(),
      onGenerateRoute: Routes.generateRoute,
    ));

    expect(find.text('Trip in progress'), findsOneWidget);

    await _tapVisible(tester, find.text('END TRIP'));
    await tester.pump();

    expect(find.text('Rate your trip'), findsOneWidget);

    // Submitting the rating returns to the client home.
    await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
    await tester.pump();
    await _tapVisible(tester, find.text('SUBMIT RATING'));
    await tester.pumpAndSettle();

    expect(find.text('Good Evening Peyman'), findsOneWidget);
  });

  testWidgets('trip progress renders the ride passed from pick up',
      (WidgetTester tester) async {
    _prepareScreen(tester);
    await tester.pumpWidget(MaterialApp(
      theme: _theme(),
      home: const SizedBox(),
      onGenerateRoute: Routes.generateRoute,
    ));

    Navigator.pushNamed(
      tester.element(find.byType(SizedBox)),
      Routes.tripProgress,
      arguments: {
        'pickup': 'Kenyatta Avenue, Nyeri',
        'destination': 'Nyeri County Referral Hospital',
        'fare': 600.0,
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('Trip in progress'), findsOneWidget);
    expect(find.text('Kenyatta Avenue, Nyeri'), findsOneWidget);
    expect(find.text('Nyeri County Referral Hospital'), findsOneWidget);
    expect(find.text('600 KES'), findsOneWidget);
  });

  testWidgets('home service cards open groceries, delivery and food',
      (WidgetTester tester) async {
    _prepareScreen(tester);
    final api = _foodDeliveryStub().build();
    await tester.pumpWidget(MaterialApp(
      theme: _theme(),
      home: HomePage(api: api),
      onGenerateRoute: (settings) {
        if (settings.name == Routes.groceries) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => GroceriesPage(api: api),
          );
        }
        if (settings.name == Routes.delivery) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DeliveryPage(api: api),
          );
        }
        if (settings.name == Routes.food) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => FoodPage(api: api),
          );
        }
        return Routes.generateRoute(settings);
      },
    ));

    // Groceries flow: pick items and place an order.
    await tester.tap(find.text('Need groceries?'));
    await tester.pumpAndSettle();
    expect(find.text('Buy me groceries'), findsOneWidget);
    expect(find.text('Naivas Nyeri'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    await _tapVisible(tester, find.text('PLACE GROCERIES ORDER'));
    await tester.pump();
    expect(find.textContaining('on the way'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();
    expect(find.text('Good Evening Peyman'), findsOneWidget);

    // Delivery flow.
    await tester.tap(find.text('Need a delivery?'));
    await tester.pumpAndSettle();
    expect(find.text('Send a delivery'), findsOneWidget);
    expect(find.textContaining('REQUEST COURIER'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();

    // Food flow.
    await tester.tap(find.text('Hmm... Hungry?!'));
    await tester.pumpAndSettle();
    expect(find.text('Order food'), findsOneWidget);
    expect(find.text('ORDER FOOD'), findsOneWidget);
    expect(find.text('Gakere Road Kitchen'), findsOneWidget);
  });

  testWidgets('unknown route shows the fallback screen',
      (WidgetTester tester) async {
    _prepareScreen(tester);
    await tester.pumpWidget(MaterialApp(
      theme: _theme(),
      home: const SizedBox(),
      onGenerateRoute: Routes.generateRoute,
    ));

    Navigator.pushNamed(
        tester.element(find.byType(SizedBox)), '/does-not-exist');
    await tester.pumpAndSettle();

    expect(find.text('Routes Not Found'), findsOneWidget);
  });
}
