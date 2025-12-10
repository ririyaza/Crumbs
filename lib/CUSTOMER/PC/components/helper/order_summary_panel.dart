import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_manager.dart';

class OrderSummaryPanel extends StatelessWidget {
  final String selectedPayment;

  const OrderSummaryPanel({super.key, required this.selectedPayment});

  @override
  Widget build(BuildContext context) {
    final cartManager = context.watch<CartManager>();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text("Order Summary",
                style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            DateTime now = DateTime.now();
            int year = cartManager.pickupTime?.year ?? now.year;
            int month = cartManager.pickupTime?.month ?? now.month;
            int day = cartManager.pickupTime?.day ?? now.day;
            int hour = cartManager.pickupTime?.hour ?? now.hour;
            int minute = cartManager.pickupTime?.minute ?? now.minute;
            String amPm = hour >= 12 ? 'PM' : 'AM';
            if (hour > 12) hour -= 12;
            if (hour == 0) hour = 12;

            await showDialog(
              context: context,
              builder: (_) => StatefulBuilder(
                builder: (context, setDialogState) {
                  // Compute dynamic limits
                  List<int> years = List.generate(5, (i) => now.year + i);
                  List<int> months = List.generate(12, (i) => i + 1)
                      .where((m) => year > now.year || m >= now.month)
                      .toList();
                  List<int> days = List.generate(31, (i) => i + 1)
                      .where((d) => (year > now.year || month > now.month) || d >= now.day)
                      .toList();

                  int compareHour = amPm == 'PM' ? hour + 12 : (hour == 12 ? 12 : hour);
                  List<int> hours = List.generate(12, (i) => i + 1)
                      .where((h) {
                        int h24 = amPm == 'PM' ? h + 12 : (h == 12 ? 12 : h);
                        return (year > now.year || month > now.month || day > now.day) || h24 >= now.hour;
                      }).toList();

                  List<int> minutes = List.generate(60, (i) {
                    return i;
                  }).where((m) {
                    return (year > now.year || month > now.month || day > now.day || compareHour > now.hour) || m >= now.minute;
                  }).toList();

                  return AlertDialog(
                    title: const Text("Set Date & Time Pickup"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Date selectors
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<int>(
                                value: month,
                                items: months.map((m) => DropdownMenuItem(value: m, child: Text("$m"))).toList(),
                                onChanged: (v) => setDialogState(() => month = v!),
                              ),
                            ),
                            Expanded(
                              child: DropdownButton<int>(
                                value: day,
                                items: days.map((d) => DropdownMenuItem(value: d, child: Text("$d"))).toList(),
                                onChanged: (v) => setDialogState(() => day = v!),
                              ),
                            ),
                            Expanded(
                              child: DropdownButton<int>(
                                value: year,
                                items: years.map((y) => DropdownMenuItem(value: y, child: Text("$y"))).toList(),
                                onChanged: (v) => setDialogState(() => year = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Time selectors
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<int>(
                                value: hour,
                                items: hours.map((h) => DropdownMenuItem(value: h, child: Text("$h"))).toList(),
                                onChanged: (v) => setDialogState(() => hour = v!),
                              ),
                            ),
                            Expanded(
                              child: DropdownButton<int>(
                                value: minute,
                                items: minutes.map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2,'0')))).toList(),
                                onChanged: (v) => setDialogState(() => minute = v!),
                              ),
                            ),
                            Expanded(
                              child: DropdownButton<String>(
                                value: amPm,
                                items: const [
                                  DropdownMenuItem(value: 'AM', child: Text('AM')),
                                  DropdownMenuItem(value: 'PM', child: Text('PM')),
                                ],
                                onChanged: (v) => setDialogState(() => amPm = v!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          int h = hour;
                          if (amPm == 'PM' && h != 12) h += 12;
                          if (amPm == 'AM' && h == 12) h = 0;
                          cartManager.setPickupTime(DateTime(year, month, day, h, minute));
                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  );
                },
              ),
            );
          },
          child: Row(
            children: [
              const Text("Pick up time", style: TextStyle(fontSize: 16)),
              const Spacer(),
              Text(
                cartManager.pickupTime != null
                    ? "${cartManager.pickupTime!.month}/${cartManager.pickupTime!.day}/${cartManager.pickupTime!.year} "
                      "${cartManager.pickupTime!.hour}:${cartManager.pickupTime!.minute.toString().padLeft(2,'0')}"
                    : "Select Time",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down_outlined),
            ],
          ),
        ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: cartManager.cartItems.length,
              itemBuilder: (_, i) {
                final item = cartManager.cartItems[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: item['image'] != null
                                ? MemoryImage(item['image'])
                                : const AssetImage('assets/no_image.png') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item['name'])),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => cartManager.decreaseQuantity(item),
                      ),
                      Text('${item['quantity']}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => cartManager.increaseQuantity(item),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Sub Total"),
              Text('₱${cartManager.subTotal.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tax"),
              Text('₱${cartManager.tax.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Discount"),
              Text('₱0.00'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₱${cartManager.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () => cartManager.setPayment('Cash'), 
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: cartManager.selectedPayment == 'Cash'
                        ? Colors.green
                        : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.money, color: Colors.green, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            // Card Icon
            GestureDetector(
              onTap: () => cartManager.setPayment('Card'), // updates CartManager
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: cartManager.selectedPayment == 'Card'
                        ? Colors.green
                        : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.credit_card, color: Colors.green, size: 28),
              ),
            ),
          ],
        ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cartManager.pickupTime != null
                    ? Colors.green
                    : Colors.grey, // greyed out if pickup not set
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: cartManager.pickupTime == null
                  ? null // disabled if no pickup time
                  : () async {
                      final cartManager = context.read<CartManager>();

                      if (cartManager.cartItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cart is empty!")),
                        );
                        return;
                      }

                      final dbRef = FirebaseDatabase.instance.ref().child('Order');

                      try {
                        final snapshot = await dbRef.get();
                        int lastKey = 0;

                        if (snapshot.exists && snapshot.value is Map) {
                          final orders = Map<String, dynamic>.from(snapshot.value as Map);
                          for (var key in orders.keys) {
                            final parsed = int.tryParse(key) ?? 0;
                            if (parsed > lastKey) lastKey = parsed;
                          }
                        }

                        final newKey = (lastKey + 1).toString().padLeft(2, '0');
                        final randomOrderId = (100000000 + (DateTime.now().millisecondsSinceEpoch % 900000000)).toString();
                        final now = DateTime.now();

                        final orderData = {
                          'order_ID': randomOrderId,
                          'customer_ID': cartManager.customerId,
                          'customer_name': cartManager.customerName,
                          'order_schedulePickup': cartManager.pickupTime!.toIso8601String(),
                          'order_paymentMethod': cartManager.selectedPayment,
                          'order_subtotal': cartManager.subTotal,
                          'order_tax': cartManager.tax,
                          'order_totalAmount': cartManager.total,
                          'order_createdAt': now.toIso8601String(),
                          'order_status': 'Pending',
                          'items': cartManager.cartItems.map((item) => {
                            'product_ID': item['id'],
                            'product_name': item['name'],
                            'product_quantity': item['quantity'],
                            'product_price': item['price'],
                            'product_flavor': item['flavor'] ?? '',
                          }).toList(),
                        };

                        await dbRef.child(newKey).set(orderData);
                        cartManager.clearCart();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Order has been successfully placed!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to place order: $e")),
                        );
                      }
                    },
              child: const Text(
                "Place Order",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
