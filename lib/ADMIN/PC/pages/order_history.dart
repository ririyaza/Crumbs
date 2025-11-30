import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String? selectedOrderId;

  List<Map<String, dynamic>> newOrders = [
    {
      'id': '#0123',
      'items': 7,
      'total': 1570.00,
      'time': '10 mins ago',
      'status': 'New',
      'orderDetails': [
        {'name': 'Sourdough - olives & cheese', 'qty': 1, 'price': 350.00},
        {'name': 'Baguette', 'qty': 1, 'price': 120.00},
        {'name': 'Biscotti - Plain', 'qty': 1, 'price': 200.00},
        {'name': 'Focaccia', 'qty': 1, 'price': 250.00},
      ],
      'customer': 'Fiona X.',
      'paymentMethod': 'Cash',
      'orderTime': '04/15/2025 1:04 PM',
    },
  ];

  List<Map<String, dynamic>> inProgressOrders = [
    {
      'id': '#0121',
      'items': 8,
      'total': 3574.00,
      'time': '1 hour ago',
      'status': 'In Progress',
    }
  ];

  List<Map<String, dynamic>> completedOrders = [
    {
      'id': '#0119',
      'items': 5,
      'total': 2127.00,
      'time': '7 hours ago',
      'status': 'Completed',
    }
  ];

  void acceptOrder(Map<String, dynamic> order) {
    setState(() {
      newOrders.removeWhere((o) => o['id'] == order['id']);
      inProgressOrders.add({...order, 'status': 'In Progress'});
      selectedOrderId = null;
    });
  }

  void cancelOrder(Map<String, dynamic> order) {
    setState(() {
      newOrders.removeWhere((o) => o['id'] == order['id']);
      inProgressOrders.removeWhere((o) => o['id'] == order['id']);
      selectedOrderId = null;
    });
  }

  void completeOrder(Map<String, dynamic> order) {
    setState(() {
      inProgressOrders.removeWhere((o) => o['id'] == order['id']);
      completedOrders.add({...order, 'status': 'Completed'});
      selectedOrderId = null;
    });
  }

  @override
Widget build(BuildContext context) {
  final Map<String, dynamic>? selectedOrder = [
    ...newOrders,
    ...inProgressOrders,
    ...completedOrders
  ].cast<Map<String, dynamic>?>()
    .firstWhere(
      (o) => o?['id'] == selectedOrderId,
      orElse: () => null,
    );

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
              Text('NEW ORDERS', style: TextStyle(color: Colors.grey.shade700, fontSize: 22)),
              const SizedBox(height: 6),
              ...newOrders.map((order) => _buildOrderCard(order, Colors.green)),
              const SizedBox(height: 12),

              Text('IN PROGRESS', style: TextStyle(color: Colors.grey.shade700, fontSize: 22)),
              const SizedBox(height: 6),
              ...inProgressOrders.map((order) => _buildOrderCard(order, Colors.orange)),
              const SizedBox(height: 12),

              Text('COMPLETED', style: TextStyle(color: Colors.grey.shade700, fontSize: 22)),
              const SizedBox(height: 6),
              ...completedOrders.map((order) => _buildOrderCard(order, Colors.grey)),
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
    onTap: () => setState(() => selectedOrderId = order['id']),
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
                    Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('₱${order['total'].toStringAsFixed(2)}', style: TextStyle(color: const Color.fromARGB(255, 21, 153, 25), fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${order['items']} items', style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w900)),
                    Text(order['time'], style: const TextStyle(fontSize: 14, color: Colors.black87)),
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
  double subtotal = 0;
  order['orderDetails']?.forEach((item) {
    subtotal += item['price'] * item['qty'];
  });
  double tax = subtotal * 0.12; 
  double discount = 0;
  double total = subtotal + tax - discount;

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
            Text(order['id'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),

        Text(order['status'], style: TextStyle(fontSize: 16, color: Colors.green)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          color: Colors.green.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pick Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Order Date: ${order['orderTime'] ?? '-'}', style: const TextStyle(fontSize: 14)),
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
            itemCount: order['orderDetails']?.length ?? 0,
            itemBuilder: (context, index) {
              final item = order['orderDetails'][index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(item['name'], style: const TextStyle(fontSize: 16))),
                    Expanded(flex: 1, child: Text(item['qty'].toString(), style: const TextStyle(fontSize: 16))),
                    Expanded(flex: 1, child: Text('₱${item['price'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 16))),
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
                    Text('Customer Name: ${order['customer'] ?? '-'}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Payment Method: ${order['paymentMethod'] ?? '-'}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Order Time: ${order['orderTime'] ?? '-'}', style: const TextStyle(fontSize: 14)),
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
                    Text('Discount: ₱${discount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
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
            if (order['status'] == 'New')
              Expanded(
                child: OutlinedButton(
                  onPressed: () => cancelOrder(order),
                  child: const Text('Cancel Order'),
                ),
              ),
            if (order['status'] == 'New') const SizedBox(width: 16),
            if (order['status'] == 'New')
              Expanded(
                child: ElevatedButton(
                  onPressed: () => acceptOrder(order),
                  child: const Text('Accept Order'),
                ),
              ),
            if (order['status'] == 'In Progress')
              Expanded(
                child: ElevatedButton(
                  onPressed: () => completeOrder(order),
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
