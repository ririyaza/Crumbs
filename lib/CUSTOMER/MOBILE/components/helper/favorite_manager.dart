import 'package:flutter/material.dart';

class FavoriteManager extends ChangeNotifier {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;

  FavoriteManager._internal();

  final Map<String, List<Map<String, dynamic>>> _userFavorites = {};
  String? _currentUserId;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    _userFavorites.putIfAbsent(userId, () => []);
  }

  List<Map<String, dynamic>> get favorites {
    if (_currentUserId == null) return [];
    return _userFavorites[_currentUserId!]!;
  }

  bool isFavorite(String productId) {
    if (_currentUserId == null) return false;
    return _userFavorites[_currentUserId!]!.any((item) => item['id'] == productId);
  }

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

  void removeFromCart(Map<String, dynamic> product) {}
}
