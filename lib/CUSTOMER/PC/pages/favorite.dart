import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../components/helper/cart_manager.dart';
import '../components/helper/favorite_manager.dart';
import '../components/helper/order_summary_panel.dart';

class FavoritePage extends StatefulWidget {
  final String customerId;
  const FavoritePage({super.key, required this.customerId});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  @override
  void initState() {
    super.initState();
    FavoriteManager().setCurrentUser(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = context.watch<CartManager>();
    final favorites = FavoriteManager().favorites;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: favorites.isEmpty
                ? const Center(
                    child: Text(
                      'No favorite products',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 30,
                      mainAxisExtent: 300,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final product = favorites[index];
                      final Uint8List image = product['image'] ?? Uint8List(0);
                      final name = product['name'] ?? 'No Name';
                      final price = product['price'] ?? 0.0;
                      final stock = product['stock'] ?? 0; 

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    image: DecorationImage(
                                      image: image.isNotEmpty
                                          ? MemoryImage(image)
                                          : const AssetImage('assets/no_image.png') as ImageProvider,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text('₱${(price as double).toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                      stock > 0
                                          ? SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  cartManager.addToCart({
                                                    'id': product['id'],
                                                    'name': name,
                                                    'price': price,
                                                    'image': image,
                                                    'quantity': 1,
                                                  });
                                                },
                                                child: const Text("Add to Cart",
                                                    style: TextStyle(color: Colors.white, fontSize: 16)),
                                              ),
                                            )
                                          : Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.red, width: 2),
                                              ),
                                              child: const Text(
                                                "Out of Stock",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  FavoriteManager().toggleFavorite(product);
                                  cartManager.removeFromCart(product);
                                });
                              },
                              child: const Icon(Icons.favorite, size: 30, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        SizedBox(
          width: 400,
          child: OrderSummaryPanel(selectedPayment: cartManager.selectedPayment),
        ),
      ],
    );
  }
}
