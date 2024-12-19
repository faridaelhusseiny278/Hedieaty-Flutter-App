import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:hedieatyfinalproject/database.dart';
import 'package:hedieatyfinalproject/event_list_page.dart';
import 'package:hedieatyfinalproject/Event.dart';
import 'package:hedieatyfinalproject/gift_list_page.dart';

class MockDatabaseService extends Mock implements DatabaseService {
  @override
  Future<List<Event>> getAllEventsForUser(int userid) =>
      super.noSuchMethod(
        Invocation.method(#getAllEventsForUser, [userid]),
        returnValue: Future.value(<Event>[]), // Ensure correct return type
        returnValueForMissingStub: Future.value(<Event>[]),
      );
  @override
  Future<int> addEventForUser(int userid, Event event) =>
      super.noSuchMethod(
        Invocation.method(#addEventForUser, [userid, event]),
        returnValue: Future.value(1), // Ensure correct return type
        returnValueForMissingStub: Future.value(1),
      );
  @override
  Future<void> deleteEventsForUser(int userId, List<Event> eventsToDelete) =>
      super.noSuchMethod(
        Invocation.method(#deleteEventsForUser, [userId, eventsToDelete]),
        returnValue: Future.value(), // Ensure correct return type
        returnValueForMissingStub: Future.value(),
      );
}


void main() {
  // group('EventListPage Tests', () {
  //   late MockDatabaseService mockDbService;
  //
  //   setUp(() {
  //     mockDbService = MockDatabaseService();
  //   });

  final mockDbService = MockDatabaseService();

  testWidgets('Test initialization and event loading', (WidgetTester tester) async {
    // Mock the database response
    when(mockDbService.getAllEventsForUser(1)).thenAnswer((_) async => <Event>[
      Event(
        id: 1,
        name: "Event 1",
        category: "Category 1",
        status: "upcoming",
        location: "Location 1",
        date: DateTime.now(),
      ),
    ]);


    // Create the EventListPage widget
    await tester.pumpWidget(
      MaterialApp(
        home: EventListPage(userid: 1, db: mockDbService),
      ),
    );

    // Wait for the widget to load
    await tester.pumpAndSettle();

    // Verify that the events are loaded by checking for event names
    expect(find.text('Event 1'), findsOneWidget);
  });


    testWidgets('Test event selection', (WidgetTester tester) async {
    //   // Mock the database response for events
     when(mockDbService.getAllEventsForUser(1)).thenAnswer((_) async => <Event>[
        Event(
         id: 1,
         name: "Event 1",
          category: "Category 1",
           status: "upcoming",
           location: "Location 1",
           date: DateTime.now(),
        ),
       Event(
           id: 2,
           name: "Event 2",
          category: "Category 2",
          status: "past",
          location: "Location 2",
          date: DateTime.now(),
        ),
      ]);

      // Create the EventListPage widget
      await tester.pumpWidget(
        MaterialApp(
          home: EventListPage(userid: 1, db: mockDbService),
        ),
      );

      // Wait for the widget to load
      await tester.pumpAndSettle();

      // Tap the checkbox of the first event to select it
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // Verify that the checkbox is checked
      expect(find.byType(Checkbox), findsNWidgets(2));
    });

    testWidgets('Test event sorting', (WidgetTester tester) async {
      // Mock the database response for events
      when(mockDbService.getAllEventsForUser(1)).thenAnswer((_) async =><Event> [
        Event(
          id: 1,
          name: "Event 2",
          category: "Category 2",
          status: "past",
          location: "Location 2",
          date: DateTime.now(),
        ),
        Event(
          id: 2,
          name: "Event 1",
          category: "Category 1",
          status: "upcoming",
          location: "Location 1",
          date: DateTime.now(),
        ),
      ]);

      // Create the EventListPage widget
      await tester.pumpWidget(
        MaterialApp(
          home: EventListPage(userid: 1, db: mockDbService),
        ),
      );

      // Wait for the widget to load
      await tester.pumpAndSettle();

      // Open the sorting options
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Tap on "Name" to sort events by name
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      // Verify the events are sorted by name
      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 2'), findsOneWidget);
    });

  testWidgets('Test event deletion', (WidgetTester tester) async {
    // Mock the database response for events
    when(mockDbService.getAllEventsForUser(1)).thenAnswer((_) async => <Event>[
      Event(
        id: 1,
        name: "Event 1",
        category: "Category 1",
        status: "upcoming",
        location: "Location 1",
        date: DateTime.now(),
      ),
      Event(
        id: 2,
        name: "Event 2",
        category: "Category 2",
        status: "past",
        location: "Location 2",
        date: DateTime.now(),
      ),
    ]);

    // Create the EventListPage widget
    await tester.pumpWidget(
      MaterialApp(
        home: EventListPage(userid: 1, db: mockDbService),
      ),
    );

    await tester.pumpAndSettle();

    // Step 1: Verify delete icon is initially disabled
    final Finder deleteButton = find.byIcon(Icons.delete);
    // expect(deleteButton, findsNothing);

    // Step 2: Select the first event
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Step 3: Verify delete icon is enabled after selecting
    expect(deleteButton, findsOneWidget);

    // Step 4: Tap the delete button to remove the selected event
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // then click on the delete button to delete the event in the dialog
    await tester.tap(find.text("Delete"));
    await tester.pumpAndSettle();

    // Step 5: Verify "Event 1" is deleted, and "Event 2" still exists
    expect(find.text('Event 1'), findsNothing);
    expect(find.text('Event 2'), findsOneWidget);
  });

  testWidgets('Add Event Button test - should open EventForm and add event', (WidgetTester tester) async {
    // Arrange
    const testUserId = 1;
    final fakeEvent = Event(
      id: 1,
      name: 'Birthday Party',
      category: 'Celebration',
      status: 'upcoming',
      location: 'Home',
      date: DateTime.now(),
    );

    when(mockDbService.getAllEventsForUser(testUserId))
        .thenAnswer((_) async => <Event>[]);

    when(mockDbService.addEventForUser(testUserId, fakeEvent))
        .thenAnswer((_) async => 1); // Mock the new event ID

    // Act
    await tester.pumpWidget(MaterialApp(
      home: EventListPage(userid: testUserId, db: mockDbService),
    ));

    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('My Events'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    // Tap the Add Event button
    final addButtonFinder = find.byIcon(Icons.add); // Assuming IconButton for "Add Event"
    expect(addButtonFinder, findsOneWidget);

    await tester.tap(addButtonFinder);
    await tester.pumpAndSettle();

    // Expect EventForm opens
    // expect(find.text('Event Form'), findsOneWidget);

    // Simulate filling the EventForm
    await tester.enterText(find.byKey(Key('eventNameField')), 'Birthday Party');
    await tester.tap(find.byKey(Key('eventCategoryField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Birthday').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('eventStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upcoming').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('eventLocationField')), 'Home');

    // Trigger the Date Picker
    await tester.tap(find.text('Select Date'));
    await tester.pumpAndSettle();

    // Simulate selecting a date from the picker
    final datePickerFinder = find.byType(DatePickerDialog);
    // expect(datePickerFinder, findsOneWidget);

    // Select the current date (or mock a date selection)
    // tap the ok button
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Submit the form
    final saveButtonFinder = find.text('Add Event'); // Assuming a button with text 'Save Changes'
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    // Verify that the event was added
    // verify(mockDbService.addEventForUser(testUserId, fakeEvent)).called(1);

    // Check if the event name and category are displayed on the list
    expect(find.text('Birthday Party'), findsOneWidget);
    expect(find.text('Birthday'), findsOneWidget);
  });



  // });
}
