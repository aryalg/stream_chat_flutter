import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class MockClient extends Mock implements StreamChatClient {
  MockClient() {
    when(() => wsConnectionStatus).thenReturn(ConnectionStatus.connected);
    when(() => wsConnectionStatusStream)
        .thenAnswer((_) => Stream.value(ConnectionStatus.connected));
  }
}

class MockClientState extends Mock implements ClientState {}

class MockChannel extends Mock implements Channel {
  @override
  Future<bool> get initialized async => true;

  @override
  // ignore: prefer_expression_function_bodies
  Future<void> keyStroke([String? parentId]) async {
    return;
  }

  @override
  List<String> get ownCapabilities => ['send-message'];
}

class MockChannelState extends Mock implements ChannelClientState {
  MockChannelState() {
    when(() => typingEvents).thenReturn({});
    when(() => typingEventsStream).thenAnswer((_) => Stream.value({}));
  }
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockVoidCallback extends Mock {
  void call();
}
