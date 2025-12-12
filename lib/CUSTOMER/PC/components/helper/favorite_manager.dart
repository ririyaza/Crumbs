import 'package:flutter/material.dart';

class FavoriteManager extends ChangeNotifier {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;

  FavoriteManager._internal();

  // Map of userId -> list of favorite products
  final Map<String, List<Map<String, dynamic>>> _userFavorites = {};
  String? _currentUserId;

  // Set the current user
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    _userFavorites.putIfAbsent(userId, () => []);
  }

  // Get favorites for the current user
  List<Map<String, dynamic>> get favorites {
    if (_currentUserId == null) return [];
    return _userFavorites[_currentUserId!]!;
  }

  // Check if a product is a favorite for the current user
  bool isFavorite(String productId) {
    if (_currentUserId == null) return false;
    return _userFavorites[_currentUserId!]!.any((item) => item['id'] == productId);
  }

  // Add/remove a product from favorites for the current user
  void toggleFavorite(Map<String, dynamic> product) {
    if (_currentUserId == null) return;

    final exists = _userFavorites[_currentUserId!]!
        .any((item) => item['id'] == product['id']);

    if (exists) {
      _userFavorites[_currentUserId!]!
          .removeWhere((item) => item['id'] == product['id']);
    } else {
      _userFavorites[_currentUserId!]!.add(product);
    }
  }

  // Optional: remove from cart if needed
  void removeFromCart(Map<String, dynamic> product) {}
}
