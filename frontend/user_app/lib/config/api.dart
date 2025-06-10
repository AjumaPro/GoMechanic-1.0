class Api {
  static const String baseUrl = 'http://localhost:8007/api';
  static String? token;

  static void setToken(String newToken) {
    token = newToken;
  }

  static void clearToken() {
    token = null;
  }
}
