import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class CartManager extends ChangeNotifier {
  final String customerId;
  final String customerName; // Added customer name

  CartManager({required this.customerId, required this.customerName});

  final Map<String, List<Map<String, dynamic>>> _customerCarts = {};
  final Map<String, DateTime?> _customerPickupTimes = {};
  final Map<String, String> _customerPayments = {};

  // Get the current customer's cart items
  List<Map<String, dynamic>> get cartItems => _customerCarts[customerId] ?? [];

  // Pickup time for the current customer
  DateTime? get pickupTime => _customerPickupTimes[customerId];

  // Selected payment method for the current customer
  String get selectedPayment => _customerPayments[customerId] ?? 'Cash';

  // Add item to cart
  void addToCart(Map<String, dynamic> item) {
    _customerCarts.putIfAbsent(customerId, () => []);
    final cart = _customerCarts[customerId]!;
    final existingIndex = cart.indexWhere((i) => i['id'] == item['id']);
    if (existingIndex != -1) {
      cart[existingIndex]['quantity'] += item['quantity'];
    } else {
      cart.add(Map<String, dynamic>.from(item));
    }
    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(Map<String, dynamic> item) {
    final cart = _customerCarts[customerId];
    if (cart == null) return;
    cart.removeWhere((i) => i['id'] == item['id']);
    notifyListeners();
  }

  // Increase quantity of an item
  void increaseQuantity(Map<String, dynamic> item) {
    final cart = _customerCarts[customerId];
    if (cart == null) return;
    final index = cart.indexWhere((i) => i['id'] == item['id']);
    if (index != -1) {
      cart[index]['quantity']++;
      notifyListeners();
    }
  }

  // Decrease quantity of an item
  void decreaseQuantity(Map<String, dynamic> item) {
    final cart = _customerCarts[customerId];
    if (cart == null) return;
    final index = cart.indexWhere((i) => i['id'] == item['id']);
    if (index != -1) {
      if (cart[index]['quantity'] > 1) {
        cart[index]['quantity']--;
      } else {
        cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Cart calculations
  double get subTotal =>
      cartItems.fold(0.0, (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int));

  double get tax => subTotal * 0.12;
  double get discount => 0.0;
  double get total => subTotal + tax - discount;

  // Clear cart
  void clearCart() {
    _customerCarts[customerId]?.clear();
    notifyListeners();
  }

  // Set pickup time
  void setPickupTime(DateTime time) {
    _customerPickupTimes[customerId] = time;
    notifyListeners();
  }

  // Set payment method
  void setPayment(String payment) {
    _customerPayments[customerId] = payment;
    notifyListeners();
  }
}
