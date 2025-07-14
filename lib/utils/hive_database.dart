import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveDatabase {
  static const String _boxName = 'appBox';
  static final HiveDatabase _instance = HiveDatabase._internal();
  Box? _box;

  HiveDatabase._internal();

  factory HiveDatabase() {
    return _instance;
  }

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    _box = await Hive.openBox(_boxName);
    _isInitialized = true;
  }

  Future<void> saveString(String key, String value) async {
    if (!_isInitialized) await init();
    await _box!.put(key, value);
  }

  Future<String?> getString(String key) async {
    if (!_isInitialized) await init();
    return _box!.get(key) as String?;
  }

  Future<void> remove(String key) async {
    if (!_isInitialized) await init();
    await _box!.delete(key);
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    if (!_isInitialized) await init();
    await _box!.put("User", user);
  }

  Future<Map<String, dynamic>?> getUser() async {
    if (!_isInitialized) await init();
    final storedUser = _box!.get("User");
    if (storedUser is Map) {
      return Map<String, dynamic>.from(storedUser);
    }
    return null;
  }

  Future<void> removeUser() async {
    if (!_isInitialized) await init();
    await _box!.delete("User");
    await removeToken();
  }

  Future<void> saveToken(String token) async {
    if (!_isInitialized) await init();
    await saveString("Token", token);
  }

  Future<void> removeToken() async {
    if (!_isInitialized) await init();
    await remove("Token");
  }

  String? getToken() {
    return _box?.get("Token") as String?;
  }
}
