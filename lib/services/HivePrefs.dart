import 'package:hive/hive.dart';

class HivePrefs {
  static const _preferencesBox = '_preferencesBox';
  static const _userIDKey = '_userIDKey';
  final Box<dynamic> _box;

  HivePrefs._(this._box);

  // This doesn't have to be a singleton.
  // We just want to make sure that the box is open, before we start getting/setting objects on it
  static Future<HivePrefs> getInstance() async {
    final box = await Hive.openBox<dynamic>(_preferencesBox);
    return HivePrefs._(box);
  }

  String getUserID() => _getValue(_userIDKey);

  Future<void> setUserID(String userID) => _setValue(_userIDKey, userID);

  T _getValue<T>(dynamic key, {T defaultValue}) =>
      _box.get(key, defaultValue: defaultValue) as T;

  Future<void> _setValue<T>(dynamic key, T value) => _box.put(key, value);
}
