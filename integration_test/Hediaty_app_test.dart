import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieatyfinalproject/home_page.dart';  // Import your HomePage widget
import 'package:mockito/mockito.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';



class MockDatabaseService extends Mock implements DatabaseService {}
class MockTickerProvider extends Mock implements TickerProvider {}

void main() {
  testWidgets('HomePage displays loading spinner initially', (WidgetTester tester) async {
    final mockDbService = MockDatabaseService();
    final mockTickerProvider = MockTickerProvider();

    // Provide mock data or behavior for the DatabaseService
    when(mockDbService.getUserFriendsIDs(1)).thenAnswer((_) async => Future.value([1]));
    when(mockDbService.getUserByIdforFriends(1)).thenAnswer((_) async => Future.value({'userid': '1', 'name': 'John Doe'}));
    when(mockDbService.getEventCountForUserFriends("1")).thenAnswer((_) async => Future.value(2));

    // Build the widget tree for HomePage
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          userid: 1,
          dbService: mockDbService,
          motionTabBarController: MotionTabBarController(
            initialIndex: 1,
            length: 4,
            vsync: mockTickerProvider, // Use the mockTickerProvider here
          ),
        ),
      ),
    );

    // Your assertions
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

}
