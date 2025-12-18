import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../components/helper/favorite_manager.dart';

class FavoritePage extends StatefulWidget {
  final String customerId;

  const FavoritePage({super.key, required this.customerId});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favorites = [];

  @override
  void initState() {
    super.initState();
    FavoriteManager().setCurrentUser(widget.customerId);
    loadFavorites();
  }

  void loadFavorites() {
    setState(() {
      favorites = FavoriteManager().favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      hintText: 'Search favorites',
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
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Favorites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (favorites.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 260,
                ),
                itemCount: favorites.length,
                itemBuilder: (_, i) {
                  final item = favorites[i];
                  return _FavoriteCard(
                    product: item,
                    onUnfavorite: () {
                      setState(() {
                        FavoriteManager().toggleFavorite(item);
                        loadFavorites();
                      });
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onUnfavorite;

  const _FavoriteCard({
    required this.product,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    final imageData = product['image'];

    if (imageData is Uint8List && imageData.isNotEmpty) {
      imageProvider = MemoryImage(imageData);
    } else if (imageData is String && imageData.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(imageData));
      } catch (_) {
        imageProvider = const AssetImage('assets/no_image.png');
      }
    } else {
      imageProvider = const AssetImage('assets/no_image.png');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image(
                  image: imageProvider,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: onUnfavorite,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'No name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${product['price'].toString()}',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                    },
                    child: const Text(
                      'Order again',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
