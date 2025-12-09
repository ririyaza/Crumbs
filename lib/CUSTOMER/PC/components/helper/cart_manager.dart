class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  List<Map<String, dynamic>> cartItems = [];

  void addItem(Map<String, dynamic> item) {
    final index = cartItems.indexWhere((i) => i['name'] == item['name']);
    if (index != -1) {
      cartItems[index]['quantity']++;
    } else {
      cartItems.add({...item, 'quantity': 1});
    }
  }

  void addToCart(Map<String, dynamic> item) => addItem(item);

  void removeItem(String name) {
    cartItems.removeWhere((i) => i['name'] == name);
  }

  void clear() {
    cartItems.clear();
  }

  void increaseQuantity(Map<String, dynamic> item) {
    final index = cartItems.indexWhere((i) => i['name'] == item['name']);
    if (index != -1) {
      cartItems[index]['quantity']++;
    }
  }

  void decreaseQuantity(Map<String, dynamic> item) {
    final index = cartItems.indexWhere((i) => i['name'] == item['name']);
    if (index != -1) {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        cartItems.removeAt(index);
      }
    }
  }
}
