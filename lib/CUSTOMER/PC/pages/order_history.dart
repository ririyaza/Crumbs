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
        return "Submitted";
      case "in progress":
        return "Submitted";
      case "completed":
        return "Picked up";
      case "cancelled":
        return "Cancelled";
      default:
        return "";
    }
  }

  String formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('MM/dd/yy hh:mm a').format(parsedDate);
    } catch (e) {
      return dateStr; // fallback if parsing fails
    }
  }

  void fetchOrders() async {
    final dbRef = FirebaseDatabase.instance.ref().child('Order');
    final snapshot = await dbRef.get();

    List<Map<String, dynamic>> tempOrders = [];

    if (snapshot.exists) {
      final data = snapshot.value;

      if (data is List) {
        for (var item in data) {
          if (item == null) continue;
          if (item['customer_ID'] == widget.customerId) {
            tempOrders.add(_processOrderItem(item));
          }
        }
      } else if (data is Map) {
        data.forEach((key, item) {
          if (item['customer_ID'] == widget.customerId) {
            tempOrders.add(_processOrderItem(item));
          }
        });
      }
    }

    setState(() {
      _orders = tempOrders;
      _loading = false;
    });
  }

  Map<String, dynamic> _processOrderItem(dynamic item) {
    int totalQty = 0;
    final itemsList = <Map<String, dynamic>>[];

    if (item['items'] != null && item['items'] is List) {
      for (var product in item['items']) {
        if (product != null) {
          int productQty = product['product_quantity'] ?? 0;
          totalQty += productQty;

          itemsList.add({
            'product_ID': product['product_ID'] ?? '',
            'product_name': product['product_name'] ?? '',
            'product_flavor': product['product_flavor'] ?? '',
            'product_price': double.tryParse(product['product_price']?.toString() ?? "0") ?? 0.0,
            'product_quantity': productQty,
          });
        }
      }
    }

    return {
      'id': item['order_ID'] ?? '',
      'customer_ID': item['customer_ID'] ?? '',
      'customer_name': item['customer_name'] ?? '',
      'date': item['order_createdAt'] ?? '',
      'payment_method': item['order_paymentMethod'] ?? '',
      'order_subTotal': item['order_subtotal'] ?? 0.0,
      'order_tax': item['order_tax'] ?? 0.0,
      'order_totalAmount': item['order_totalAmount'] ?? 0.0,
      'order_scheduledPickupTime': item['order_schedulePickup'] ?? '',
      'order_status': item['order_status'] ?? 'submitted',
      'lastUpdate': item['order_updatedAt'] ?? '',
      'products': itemsList,
      'qty': totalQty,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return const Center(child: Text('No orders found.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Orders',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('QTY', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(flex: 3, child: Text('Last Update', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(flex: 3, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Table Rows
                ..._orders.map((order) {
                  String status = customerStatusLabel(order['order_status']);
                  String createdAtFormatted = formatDate(order['date']);
                  String lastUpdateFormatted = formatDate(order['lastUpdate']);
                  double totalAmount = order['order_totalAmount'] ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(order['id'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(createdAtFormatted),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('₱${totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(order['qty'].toString(), textAlign: TextAlign.center),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastUpdateFormatted,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    showOrderDetailsModal(order);
                                  },
                                  child: const Text('View', style: TextStyle(color: Colors.green)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Order again', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

void showOrderDetailsModal(Map<String, dynamic> order) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.4, // responsive
            maxHeight: screenHeight * 3.0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close Button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Order ID
                  Text('#${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),

                  // Pick-up Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pick Up:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatDate(order['order_scheduledPickupTime']), style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Products Table
                  Row(
                    children: const [
                      Expanded(flex: 5, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(flex: 3, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                    ],
                  ),
                  const Divider(),

                  Column(
                    children: List.generate(order['products'].length, (index) {
                      final product = order['products'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text('${product['product_name']}${product['product_flavor'].isNotEmpty ? " - ${product['product_flavor']}" : ""}'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${product['product_quantity']}', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text('₱${product['product_price'].toStringAsFixed(2)}', textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const Divider(height: 24),

                  // Order Summary Title
                  const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  // Two-column summary
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column (Customer info)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(child: Text('Customer Name:')),
                                Expanded(child: Text('${order['customer_name']}')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(child: Text('Payment Method:')),
                                Expanded(child: Text('${order['payment_method']}')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(child: Text('Order Time:')),
                                Expanded(child: Text(formatDate(order['date']))),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16), // spacing between left & right

                      // Right Column (Financial info)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Expanded(child: Text('Subtotal:')),
                                Expanded(child: Text('₱${order['order_subTotal'].toStringAsFixed(2)}', textAlign: TextAlign.right)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(child: Text('Tax:')),
                                Expanded(child: Text('₱${order['order_tax'].toStringAsFixed(2)}', textAlign: TextAlign.right)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Expanded(child: Text('Discount:')),
                                Expanded(child: Text('₱0.00', textAlign: TextAlign.right)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Total Amount under right column
                            Row(
                              children: [
                                const Expanded(child: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: Text('₱${order['order_totalAmount'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}



}