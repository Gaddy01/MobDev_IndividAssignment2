import 'package:flutter/foundation.dart';

class SettingsProvider with ChangeNotifier {
  bool _locationNotificationsEnabled = false;

  bool get locationNotificationsEnabled => _locationNotificationsEnabled;

  Future<void> toggleLocationNotifications(bool value) async {
    _locationNotificationsEnabled = value;
    notifyListeners();
    // In a production app, you would save this to SharedPreferences or Firestore
  }
}
