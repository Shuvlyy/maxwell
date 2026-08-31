import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'base_url_provider.g.dart';

@Riverpod(keepAlive: true)
class BaseUrl extends _$BaseUrl {
  static const _key = 'api_base_url';
  static const _defaultUrl = 'http://shuvly.freeboxos.fr:50067';

  @override
  String build() {
    _init();
    return _defaultUrl;
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_key);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      state = savedUrl;
    }
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
    state = url;
  }
}
