class ApiConstants {
  static const String baseUrl = 'https://sahiyarclub.com/api/';
  static const String imageBaseUrl = 'https://sahiyarclub.com';
  static const Duration connectTimeout = Duration(seconds: 100); // 5 seconds
  static const Duration receiveTimeout = Duration(seconds: 100); // 10 seconds
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
