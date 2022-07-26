// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'mocks.dart';

void main() {
  testWidgets(
    'it should show basic channel information',
    (WidgetTester tester) async {
      final client = MockClient();
      final clientState = MockClientState();
      final channel = MockChannel();
      final channelState = MockChannelState();
      final user = OwnUser(id: 'user-id');
      final lastMessageAt = DateTime.parse('2020-06-22 12:00:00');

      when(() => channel.cid).thenReturn('cid');
      when(() => client.state).thenReturn(clientState);
      when(() => clientState.currentUser).thenReturn(user);
      when(() => clientState.currentUserStream)
          .thenAnswer((_) => Stream.value(user));
      when(() => channel.lastMessageAtStream)
          .thenAnswer((_) => Stream.value(lastMessageAt));
      when(() => channel.lastMessageAt).thenReturn(lastMessageAt);
      when(() => channel.state).thenReturn(channelState);
      when(() => channel.client).thenReturn(client);
      when(() => channel.isMuted).thenReturn(false);
      when(() => channel.isMutedStream).thenAnswer((i) => Stream.value(false));
      when(() => channel.nameStream)
          .thenAnswer((i) => Stream.value('test name'));
      when(() => channel.name).thenReturn('test name');
      when(() => channel.imageStream)
          .thenAnswer((i) => Stream.value('https://bit.ly/321RmWb'));
      when(() => channel.image).thenReturn('https://bit.ly/321RmWb');
      when(() => clientState.channels).thenReturn({
        channel.cid!: channel,
      });
      when(() => channelState.unreadCount).thenReturn(1);
      when(() => channelState.unreadCountStream)
          .thenAnswer((i) => Stream.value(1));
      when(() => channelState.membersStream).thenAnswer((i) => Stream.value([
            Member(
              userId: 'user-id',
              user: User(id: 'user-id'),
            )
          ]));
      when(() => channelState.members).thenReturn([
        Member(
          userId: 'user-id',
          user: User(id: 'user-id'),
        ),
      ]);
      when(() => channelState.messages).thenReturn([
        Message(
          text: 'hello',
          user: User(id: 'other-user'),
        )
      ]);
      when(() => channelState.messagesStream).thenAnswer((i) => Stream.value([
            Message(
              text: 'hello',
              user: User(id: 'other-user'),
            )
          ]));

      await tester.pumpWidget(MaterialApp(
        home: StreamChat(
          client: client,
          child: StreamChannel(
            channel: channel,
            child: Scaffold(
              body: ChannelPreview(
                channel: channel,
              ),
            ),
          ),
        ),
      ));

      expect(find.text('6/22/2020'), findsOneWidget);
      expect(find.text('test name'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
      expect(find.byType(StreamChannelAvatar), findsOneWidget);
    },
  );
}
