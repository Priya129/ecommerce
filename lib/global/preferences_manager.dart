import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const _isSignedKey = 'isSigned';

  static Future<void> setSignedIn(bool isSigned) async {
    try{
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSignedKey, isSigned);
    } catch(e) {
      print("Error saving sign-in status: $e");
    }
  }

  static Future<bool> getSignedInStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isSignedKey) ?? false;
    } catch(e){
      print("Error fetching sign-in status: $e");
      return false;
    }
  }
}