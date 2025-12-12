import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String? selectedOrderId;

  List<Map<String, dynamic>> newOrders = [];
  List<Map<String, dynamic>> inProgressOrders = [];
  List<Map<String, dynamic>> completedOrders = [];

  final dbRef = FirebaseDatabase.instance.ref().child('Order');

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      List<Map<String, dynamic>> fetchedOrders = data.entries.map((e) {
        final order = Map<String, dynamic>.from(e.value as Map);

        order['firebaseKey'] = e.key;

        if (order['items'] != null) {
          if (order['items'] is Map) {
            order['items'] = (order['items'] as Map).values
                .map((i) => Map<String, dynamic>.from(i as Map))
                .toList();
          } else if (order['items'] is List) {
            order['items'] = List<Map<String, dynamic>>.from(
                (order['items'] as List)
                    .map((i) => Map<String, dynamic>.from(i as Map)));
          }
        } else {
          order['items'] = [];
        }

        order['orderDetails'] = order['items']
            .map<Map<String, dynamic>>((i) => {
                  'name':
                      '${i['product_name']} ${i['product_flavor'] ?? ''}'.trim(),
                  'qty': i['product_quantity'],
                  'price': i['product_price'],
                })
            .toList();

        return order;
      }).toList();

      setState(() {
        newOrders =
            fetchedOrders.where((o) => o['order_status'] == 'Pending').toList();
        inProgressOrders = fetchedOrders
            .where((o) => o['order_status'] == 'In Progress')
            .toList();
        completedOrders = fetchedOrders
            .where((o) => o['order_status'] == 'Completed')
            .toList();
      });
    } else {
      print('No orders found in Firebase.');
    }
  }

Future<void> updateOrderStatus(Map<String, dynamic> order, String newStatus) async {
  final now = DateTime.now();
  final firebaseKey = order['firebaseKey'];

  if (firebaseKey == null) {
    print("ERROR: firebaseKey missing for order!");
    return;
  }

  await dbRef.child(firebaseKey).update({
    'order_status': newStatus,
    'order_updatedAt': now.toIso8601String(),
  });

  if (newStatus == 'Completed') {
    final productRef = FirebaseDatabase.instance.ref().child('Product');

    final productSnapshot = await productRef.get();
    if (!productSnapshot.exists) {
      print("No products found in Firebase.");
      return;
    }

    final productValue = productSnapshot.value;
    Map<String, dynamic> products = {};

    if (productValue is Map) {
      products = Map<String, dynamic>.from(productValue);
    } else if (productValue is List) {
      for (int i = 0; i < productValue.length; i++) {
        if (productValue[i] != null) {
          products[i.toString()] = Map<String, dynamic>.from(productValue[i]);
        }
      }
    } else {
      print("Unexpected Product node type: ${productValue.runtimeType}");
      return;
    }

    for (var item in order['items'] ?? []) {
      final itemName = item['product_name']?.toString().trim().toLowerCase() ?? '';
      final itemFlavor = (item['product_flavor'] ?? '').toString().trim().toLowerCase();

      String? matchingProductKey;

      for (var entry in products.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        final name = data['product_name']?.toString().trim().toLowerCase() ?? '';
        final flavor = (data['flavor'] ?? '').toString().trim().toLowerCase();

        if (name == itemName && flavor == itemFlavor) {
          matchingProductKey = entry.key;
          break;
        }
      }

      if (matchingProductKey != null) {
        final productData = Map<String, dynamic>.from(products[matchingProductKey]!);

        final newQty = (productData['quantity'] ?? 0) - (item['product_quantity'] ?? 0);
        final newSold = (productData['item_sold'] ?? 0) + (item['product_quantity'] ?? 0);

        await productRef.child(matchingProductKey).update({
          'quantity': newQty < 0 ? 0 : newQty,
          'item_sold': newSold,
        });


      } else {
        print("Warning: No matching product found for ${item['product_name']} ${item['product_flavor'] ?? ''}");
      }
    }
  }

  setState(() {
    newOrders.removeWhere((o) => o['order_ID'] == order['order_ID']);
    inProgressOrders.removeWhere((o) => o['order_ID'] == order['order_ID']);
    completedOrders.removeWhere((o) => o['order_ID'] == order['order_ID']);

    final updated = {...order, 'order_status': newStatus};

    if (newStatus == 'Pending') newOrders.add(updated);
    if (newStatus == 'In Progress') inProgressOrders.add(updated);
    if (newStatus == 'Completed') completedOrders.add(updated);

    selectedOrderId = null;
  });
}







Future<void> acceptOrder(Map<String, dynamic> order) =>
    updateOrderStatus(order, 'In Progress');

Future<void> cancelOrder(Map<String, dynamic> order) =>
    updateOrderStatus(order, 'Cancelled');

Future<void> completeOrder(Map<String, dynamic> order) =>
    updateOrderStatus(order, 'Completed');

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? selectedOrder = [
      ...newOrders,
      ...inProgressOrders,
      ...completedOrders
    ].cast<Map<String, dynamic>?>()
        .firstWhere((o) => o?['order_ID'] == selectedOrderId, orElse: () => null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('NEW ORDERS',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 22)),
                const SizedBox(height: 6),
                ...newOrders.map((order) => _buildOrderCard(order, Colors.green)),
                const SizedBox(height: 12),
                Text('IN PROGRESS',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 22)),
                const SizedBox(height: 6),
                ...inProgressOrders
                    .map((order) => _buildOrderCard(order, Colors.orange)),
                const SizedBox(height: 12),
                Text('COMPLETED',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 22)),
                const SizedBox(height: 6),
                ...completedOrders
                    .map((order) => _buildOrderCard(order, Colors.grey)),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: selectedOrder != null
              ? _buildOrderDetails(selectedOrder)
              : const Center(child: Text('Select an order to view details')),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, Color borderColor) {
    return GestureDetector(
      onTap: () => setState(() => selectedOrderId = order['order_ID']),
      child: SizedBox(
        width: 300,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#${order['order_ID']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                        '₱${(order['order_totalAmount'] ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 21, 153, 25),
                            fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(order['items'] as List).length} items',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w900)),
                    Text(order['order_createdAt'] ?? '',
                        style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order) {
    final DateFormat displayFormat = DateFormat('MM/dd/yyyy hh:mm a');

    double subtotal = 0;
    List items = order['items'] ?? [];
    for (var item in items) {
      subtotal += (item['product_price'] ?? 0) * (item['product_quantity'] ?? 0);
    }
    double tax = subtotal * 0.12;
    double total = order['order_totalAmount'] != null
        ? double.tryParse(order['order_totalAmount'].toString()) ?? subtotal + tax
        : subtotal + tax;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedOrderId = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text('#${order['order_ID']}',
                  style:
                      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(order['order_status'] ?? '-', style: TextStyle(fontSize: 16, color: Colors.green)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: Colors.green.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pick Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                    'Order Date: ${order['order_schedulePickup'] != null ? displayFormat.format(DateTime.parse(order['order_schedulePickup'])) : order['order_createdAt'] != null ? displayFormat.format(DateTime.parse(order['order_createdAt'])) : '-'}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
            color: Colors.grey.shade200,
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Expanded(flex: 1, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Expanded(flex: 1, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item['product_name'] ?? '-', style: const TextStyle(fontSize: 16))),
                      Expanded(flex: 1, child: Text(item['product_quantity']?.toString() ?? '0', style: const TextStyle(fontSize: 16))),
                      Expanded(flex: 1, child: Text('₱${item['product_price']?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Name: ${order['customer_name'] ?? '-'}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Payment Method: ${order['order_paymentMethod'] ?? '-'}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                          'Order Time: ${order['order_createdAt'] != null ? displayFormat.format(DateTime.parse(order['order_createdAt'])) : '-'}',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Subtotal: ₱${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Tax: ₱${tax.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Total: ₱${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (order['order_status'] == 'Pending')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await cancelOrder(order);
                    },
                    child: const Text('Cancel Order'),
                  ),
                ),
              if (order['order_status'] == 'Pending') const SizedBox(width: 16),
              if (order['order_status'] == 'Pending')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await acceptOrder(order);
                    },
                    child: const Text('Accept Order'),
                  ),
                ),
              if (order['order_status'] == 'In Progress') const SizedBox(width: 16),
              if (order['order_status'] == 'In Progress')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await completeOrder(order);
                    },
                    child: const Text('Mark as Complete'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
