class FavoriteManager {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;

  FavoriteManager._internal();

  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  bool isFavorite(String productId) {
    return _favorites.any((item) => item['id'] == productId);
  }

  void toggleFavorite(Map<String, dynamic> product) {
    final exists = _favorites.any((item) => item['id'] == product['id']);

    if (exists) {
      _favorites.removeWhere((item) => item['id'] == product['id']);
    } else {
      _favorites.add(product);
    }
  }
}