import 'dart:convert';
import 'package:maxwell/core/api/base_url_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'socket_provider.g.dart';

@riverpod
Stream<Map<String, dynamic>> socket(SocketRef ref) async* {
  final baseUrl = ref.watch(baseUrlProvider);
  
  // Convert http/https to ws/wss
  final baseUri = Uri.parse(baseUrl);
  final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
  final wsUri = baseUri.replace(scheme: wsScheme, path: '/ws');

  final channel = WebSocketChannel.connect(wsUri);

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
