import 'package:flutter/material.dart';

class MobileNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MobileNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<IconData> normalIcons = [
      Icons.home_outlined,
      Icons.favorite_border,
      Icons.shopping_bag_outlined,
      Icons.history,
      Icons.mail_outline,
      Icons.person_outline,
    ];

    final List<IconData> selectedIcons = [
      Icons.home,
      Icons.favorite,
      Icons.shopping_bag,
      Icons.history_rounded,
      Icons.mail,
      Icons.person,
    ];

    return Container(
      height: 60,
      color: const Color.fromARGB(255, 232, 228, 228),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(normalIcons.length, (index) {
          final bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: Icon(
              isSelected ? selectedIcons[index] : normalIcons[index],
              size: 28,
              color: isSelected ? Colors.green[800] : Colors.grey[700],
            ),
          );
        }),
      ),
    );
  }
}