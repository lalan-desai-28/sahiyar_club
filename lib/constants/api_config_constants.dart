class ApiConstants {
  static const String baseUrl = 'http://103.174.103.74:5000/api/';
  static const String imageBaseUrl = 'http://103.174.103.74:5000';
  static const Duration connectTimeout = Duration(seconds: 5); // 5 seconds
  static const Duration receiveTimeout = Duration(seconds: 10); // 10 seconds
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
