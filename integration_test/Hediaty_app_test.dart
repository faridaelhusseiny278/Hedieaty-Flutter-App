import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieatyfinalproject/home_page.dart'; // Import your HomePage widget
import 'package:mockito/mockito.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hedieatyfinalproject/welcome_screen.dart';
import 'package:hedieatyfinalproject/signup_screen.dart';
import 'package:hedieatyfinalproject/login_screen.dart';
import 'package:hedieatyfinalproject/main.dart';



class MockDatabaseService extends Mock implements DatabaseService {

  @override
  Future<List<int>> getUserFriendsIDs(int userid) =>
      super.noSuchMethod(
        Invocation.method(#getUserFriendsIDs, [userid]),
        returnValue: Future.value(<int>[]), // Ensure correct return type
        returnValueForMissingStub: Future.value(<int>[]),
      );

  @override
  Future<Map<String, dynamic>?> getUserByIdforFriends(int userid) =>
      super.noSuchMethod(
        Invocation.method(#getUserByIdforFriends, [userid]),
        returnValue: Future.value(<String, dynamic>{}), // Ensure correct return type
        returnValueForMissingStub: Future.value(<String, dynamic>{}),
      );

  @override
  Future<int> getEventCountForUserFriends(String userid) =>
      super.noSuchMethod(
        Invocation.method(#getEventCountForUserFriends, [userid]),
        returnValue: Future.value(0), // Ensure correct return type
        returnValueForMissingStub: Future.value(0),
      );
  @override
//   printdatabase that returns Future void
Future<void> printDatabase() =>
      super.noSuchMethod(
        Invocation.method(#printDatabase, []),
        returnValue: Future.value(), // Ensure correct return type
        returnValueForMissingStub: Future.value(),
      );



}
class MockTickerProvider extends Mock implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(); // Initialize Firebase for tests
  });
  final mockDbService = MockDatabaseService();
  final mockTickerProvider = MockTickerProvider();
  final testVSync = TestVSync();

  // first test the login then display the homepage
  testWidgets('displays welcome message and navigates to signup screen , then logins then navigates to home page', (
      WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: WelcomeScreen()));

    // Check welcome message
    expect(find.text("Welcome to Hedieaty"), findsOneWidget);

    // Check the "Get Started" button exists
    expect(find.text("Get Started"), findsOneWidget);

    // Tap the button
    await tester.tap(find.text("Get Started"));
    await tester.pumpAndSettle();

    // Ensure navigation to Signup Screen
    expect(find.byType(SignupScreen), findsOneWidget);

    // click on login
    // click on elevated button called login
    // const Text("Already have an account? Login"),
    await tester.tap(find.text("Already have an account? Login"));
    await tester.pumpAndSettle();

    // Step 1: Login screen test
    await tester.pumpWidget(MaterialApp(home: LoginScreen(testing: true)));

    // Check for the text fields and button
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
    expect(find.text("Login"), findsOneWidget);

    // Enter email and password
    await tester.enterText(find
        .byType(TextField)
        .first, 'alice@example.com'); // Email field
    await tester.enterText(find
        .byType(TextField)
        .last, '12345678'); // Password field

    // Tap the login button
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle();


    // // Step 2: HomePage loading spinner test
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          userid: 1,
          dbService: mockDbService,
          motionTabBarController: MotionTabBarController(
            initialIndex: 1,
            length: 4,
            vsync: testVSync,
          ),
          testing: true
        ),
      ),
    );


    await Future.delayed(Duration(seconds: 10));

    // Step 3: Simulate loading completion
    await tester.pumpAndSettle(); // Wait for all async operations to finish

    // Step 4: Ensure the loading spinner is no longer visible
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Step 5: Check if HomePage content is displayed
    expect(find.text("Home Page"), findsOneWidget); // Adjust text based on actual content


    // Assertions to verify friends are displayed
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);

  //   check if the permissions dialog is displayed, if so, click on allow
  //   await tester.tap(find.text("Allow"));
  //   await tester.pumpAndSettle();

  });
}

