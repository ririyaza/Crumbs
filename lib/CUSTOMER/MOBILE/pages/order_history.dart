import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  final String customerId;

  const OrderHistoryPage({super.key, required this.customerId});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  String customerStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case "pending":
      case "in progress":
        return "Submitted";
      case "completed":
        return "Picked up";
      case "cancelled":
        return "Cancelled";
      default:
        return "Submitted";
    }
  }

  Widget statusBadge(String status) {
    final label = customerStatusLabel(status);

    Color bg;
    Color fg;

    switch (label.toLowerCase()) {
      case 'picked up':
        bg = Colors.green.shade200;
        fg = Colors.green.shade800;
        break;
      case 'submitted':
        bg = Colors.yellow.shade200;
        fg = Colors.orange.shade800;
        break;
      default:
        bg = Colors.grey.shade300;
        fg = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  String formatDate(String dateStr) {
    try {
      return DateFormat('dd MMMM, yyyy')
          .format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  void fetchOrders() async {
    final dbRef = FirebaseDatabase.instance.ref().child('Order');
    final snapshot = await dbRef.get();
    List<Map<String, dynamic>> temp = [];

    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((_, item) {
        if (item['customer_ID'] == widget.customerId) {
          temp.add(_processOrderItem(item));
        }
      });
    }

    temp.sort((a, b) {
      final dA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
      final dB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
      return dB.compareTo(dA);
    });

    setState(() {
      _orders = temp;
      _loading = false;
    });
  }

  Map<String, dynamic> _processOrderItem(dynamic item) {
    final List<Map<String, dynamic>> products = [];

    if (item['items'] is List) {
      for (var p in item['items']) {
        products.add({
          'product_name': p['product_name'] ?? '',
          'product_price':
              double.tryParse(p['product_price'].toString()) ?? 0.0,
          'product_quantity': p['product_quantity'] ?? 0,
          'product_image': p['product_image'] ?? '',
        });
      }
    }

    return {
      'id': item['order_ID'] ?? '',
      'date': item['order_createdAt'] ?? '',
      'order_status': item['order_status'] ?? '',
      'products': products,
    };
  }

  Widget buildProductImage(String base64) {
    if (base64.isEmpty) return _imageFallback();

    try {
      final clean =
          base64.contains(',') ? base64.split(',').last : base64;
      return Image.memory(
        base64Decode(clean),
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      );
    } catch (_) {
      return _imageFallback();
    }
  }

  Widget _imageFallback() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget productOrderCard(
      Map<String, dynamic> order, Map<String, dynamic> product) {
    final total =
        product['product_price'] * product['product_quantity'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: buildProductImage(product['product_image']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['product_name'],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(formatDate(order['date']),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text('Qty: ${product['product_quantity']} pcs.',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(
                  'Total: ₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.green),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ID: #${order['id']}',
                  style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 8),
              statusBadge(order['order_status']),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Location', style: TextStyle(color: Colors.grey)),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tabuc Suba, Jaro, Iloilo City',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search orders',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_orders.isEmpty)
              const Center(child: Text('No orders found.'))
            else
              ..._orders.expand<Widget>((order) {
                final products = order['products'] as List;
                return products.map<Widget>((product) {
                  return productOrderCard(
                    order,
                    product as Map<String, dynamic>,
                  );
                });
              }).toList(),
          ],
        ),
      ),
    );
  }
}
