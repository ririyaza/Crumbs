import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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

   void fetchOrders() async {
    final dbRef = FirebaseDatabase.instance.ref().child('Orders'); // Replace 'Orders' with your node
    final snapshot = await dbRef.orderByChild('customerId').equalTo(widget.customerId).get();

    List<Map<String, dynamic>> tempOrders = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        tempOrders.add({
          'id': value['id'] ?? '',
          'date': value['date'] ?? '',
          'total': double.tryParse(value['total'].toString()) ?? 0.0,
          'qty': value['qty'] ?? 0,
          'lastUpdate': value['lastUpdate'] ?? '',
        });
      });
    }

        setState(() {
        _orders = tempOrders;
        _loading = false;
      });
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
                // Extract status and the rest of lastUpdate
                List<String> lastUpdateParts = order['lastUpdate'].split(' ');
                String status = lastUpdateParts[0]; // 'Submitted' or 'Picked'
                String lastUpdateDate = lastUpdateParts.sublist(1).join(' '); // rest of the text

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
                        // ID
                        Expanded(
                          flex: 2,
                          child: Text(
                            order['id'],
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Date
                        Expanded(
                          flex: 2,
                          child: Text(order['date']),
                        ),
                        // Total
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₱${order['total'].toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                        // QTY
                        Expanded(
                          flex: 1,
                          child: Text(
                            order['qty'].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Last Update with status on top
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
                                lastUpdateDate,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {},
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
}
