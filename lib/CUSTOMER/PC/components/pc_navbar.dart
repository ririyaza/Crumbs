import 'package:flutter/material.dart';
import '../pc_login_page.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust width based on screen size
    double sidebarWidth = screenWidth > 800 ? 250 : screenWidth * 0.7;

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
      width: sidebarWidth,
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
                Flexible(
                  child: Column(
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
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'BY M & C',
                        style: TextStyle(
                          fontFamily: 'Century',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
                          width: sidebarWidth * 0.72, // scale with sidebar width
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
                              Flexible(
                                child: Text(
                                  menuItems[index],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const PcLoginPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
