import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    // Load user data from SharedPreferences when service initializes
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      
      if (userData != null) {
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, we'll use hardcoded credentials
      // In a real app, you'd validate against a backend
      if (email == 'admin@example.com' && password == 'password') {
        _currentUser = User(
          id: '1',
          name: 'Admin User',
          email: email,
          userType: 'admin',
        );
      } else if (email == 'supplier@example.com' && password == 'password') {
        _currentUser = User(
          id: '2',
          name: 'Supplier User',
          email: email,
          userType: 'supplier',
        );
      } else if (email == 'customer@example.com' && password == 'password') {
        _currentUser = User(
          id: '3',
          name: 'Customer User',
          email: email,
          userType: 'customer',
        );
      } else {
        return false;
      }

      // Save user to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', _currentUser!.toJson());
      
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, String userType) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, create a new user
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        userType: userType,
      );

      // Save user to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', _currentUser!.toJson());
      
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = null;
      
      // Clear user from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}