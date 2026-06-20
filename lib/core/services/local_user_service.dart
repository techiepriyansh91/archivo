import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Generates and persists a stable device-local identifier on first launch.
/// This UUID is the owner uid stamped on every note row — no account needed.
/// When Google Drive sync is added later, this ID will be linked to the
/// user's Google identity without changing any stored rows.
class LocalUserService {
  LocalUserService({required SharedPreferences prefs, required Uuid uuid})
      : _prefs = prefs,
        _uuid = uuid;

  final SharedPreferences _prefs;
  final Uuid _uuid;

  static const _key = 'archivo_device_user_id';

  String get userId {
    var id = _prefs.getString(_key);
    if (id == null) {
      id = _uuid.v4();
      _prefs.setString(_key, id);
    }
    return id;
  }
}
