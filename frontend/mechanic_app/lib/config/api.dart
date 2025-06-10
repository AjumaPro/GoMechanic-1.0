class Api {
  static String? _token;
  static const String baseUrl = 'https://api.gomechanic.com/v1';

  static String? get token => _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}
