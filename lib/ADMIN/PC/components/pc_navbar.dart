import 'package:flutter/material.dart';

class PcSideNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const PcSideNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> menuItems = [
      'Dashboard',
      'Order',
      'Favorite',
      'Order History',
      'Message',
      'Settings',
    ];

    final List<IconData> icons = [
      Icons.space_dashboard_outlined,
      Icons.local_dining,
      Icons.favorite_border,
      Icons.history,
      Icons.mail_outlined,
      Icons.settings,
    ];

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CRUMBS',
                      style: TextStyle(
                        fontFamily: 'Century',
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'BY M & C',
                      style: TextStyle(
                        fontFamily: 'Century',
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final bool isSelected = selectedIndex == index;
                return InkWell(
                  onTap: () => onItemSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: Colors.green[800],
                                  borderRadius: BorderRadius.circular(24),
                                )
                              : null,
                          child: Row(
                            children: [
                              Icon(
                                icons[index],
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                menuItems[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
