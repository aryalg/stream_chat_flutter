import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'mocks.dart';

void main() {
  testWidgets(
    'control test',
    (WidgetTester tester) async {
      final client = MockClient();
      final clientState = MockClientState();

      when(() => client.state).thenReturn(clientState);
      when(() => clientState.currentUser).thenReturn(OwnUser(id: 'user-id'));

      await tester.pumpWidget(MaterialApp(
        home: StreamChat(
          client: client,
          child: const Scaffold(
            body: Portal(
              child: SizedBox(
                child: StreamInfoTile(
                  showMessage: true,
                  message: 'message',
                  child: Text('test'),
                ),
              ),
            ),
          ),
        ),
      ));

      expect(find.text('message'), findsOneWidget);
    },
  );

  testWidgets(
    'it should hide when passing showMessage: false',
    (WidgetTester tester) async {
      final client = MockClient();
      final clientState = MockClientState();

      when(() => client.state).thenReturn(clientState);
      when(() => clientState.currentUser).thenReturn(OwnUser(id: 'user-id'));

      await tester.pumpWidget(MaterialApp(
        home: StreamChat(
          client: client,
          child: const Scaffold(
            body: Portal(
              child: SizedBox(
                child: StreamInfoTile(
                  showMessage: false,
                  message: 'message',
                  child: Text('test'),
                ),
              ),
            ),
          ),
        ),
      ));

      expect(find.text('message'), findsNothing);
    },
  );
}
