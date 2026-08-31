import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'socket_provider.g.dart';

@riverpod
Stream<Map<String, dynamic>> socket(SocketRef ref) async*
{
  final uri = Uri.parse('ws://localhost:8000/ws');
  final channel = WebSocketChannel.connect(uri);

  ref.onDispose(() => channel.sink.close());

  await for (final message in channel.stream) {
    try {
      final data = jsonDecode(message as String);
      if (data is Map<String, dynamic>) {
        yield data;
      }
    } catch (e) {
      // ignore malformed messages
    }
  }
}
