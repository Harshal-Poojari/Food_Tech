import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/string_helpers.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  UserProfile? _currentUser;

  AuthService(this._prefs) {
    _loadUser();
  }

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> _loadUser() async {
    final userJson = _prefs.getString('current_user');
    if (userJson != null) {
      try {
        _currentUser = UserProfile.fromJson(userJson);
        notifyListeners();
      } catch (e) {
        print('Error loading user: $e');
      }
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = StringHelpers.hashPassword(password);
      
      final newUser = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        preferences: UserPreferences(
          dailyCalorieTarget: 2000,
          darkMode: true,
          dietaryRestrictions: [],
          allergens: [],
          notifications: {
            'mealReminders': true,
            'scanReminders': true,
            'weeklyReports': true,
          },
        ),
        stats: UserStats(
          joinDate: DateTime.now(),
          lastActive: DateTime.now(),
          streakDays: 0,
          totalEntries: 0,
          nutritionAverages: {
            'calories': 0,
            'protein': 0,
            'carbs': 0,
            'fat': 0,
          },
          activityLevel: 'moderate',
        ),
      );

      // Store password hash
      await _prefs.setString('user_${email}', hashedPassword);
      
      // Store user data
      await _prefs.setString('user_data_${email}', newUser.toJson());
      
      // Login the user
      await _loginUser(newUser);
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final storedHash = _prefs.getString('user_${email}');
      final hashedPassword = StringHelpers.hashPassword(password);

      if (storedHash == null || storedHash != hashedPassword) {
        return false; // Invalid credentials
      }

      final userJson = _prefs.getString('user_data_${email}');
      if (userJson == null) return false;

      final user = UserProfile.fromJson(userJson);
      await _loginUser(user);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> _loginUser(UserProfile user) async {
    _currentUser = user;
    await _prefs.setString('current_user', user.toJson());
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove('current_user');
    notifyListeners();
  }

  Future<void> updateUserPreferences(UserPreferences preferences) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(preferences: preferences);
      await _prefs.setString('current_user', _currentUser!.toJson());
      
      // Also update in the user_data storage
      final email = _currentUser!.email;
      await _prefs.setString('user_data_${email}', _currentUser!.toJson());
      
      notifyListeners();
    }
  }

  Future<void> updateUserStats(UserStats stats) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(stats: stats);
      await _prefs.setString('current_user', _currentUser!.toJson());
      
      // Also update in the user_data storage
      final email = _currentUser!.email;
      await _prefs.setString('user_data_${email}', _currentUser!.toJson());
      
      notifyListeners();
    }
  }
}
