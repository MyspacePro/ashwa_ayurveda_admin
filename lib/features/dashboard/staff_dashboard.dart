import 'package:flutter/material.dart';
import '../orders/order_screen.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

    const List<Widget> screens = [
      OrderScreen(),
    ];

    const List<String> menuItems = [
      "Orders",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Staff Panel")),
      body: Row(
        children: [
          // 🔹 Sidebar
          Container(
            width: 220,
            color: Colors.blueGrey.shade800,
            child: Column(
              children: [
                const SizedBox(height: 20),
                for (int i = 0; i < menuItems.length; i++)
                  _NavItem(
                    title: menuItems[i],
                    index: i,
                    selectedIndex: selectedIndex,
                  ),
              ],
            ),
          ),

          // 🔹 Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder<int>(
                valueListenable: selectedIndex,
                builder: (context, index, _) => screens[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Sidebar Item
class _NavItem extends StatelessWidget {
  final String title;
  final int index;
  final ValueNotifier<int> selectedIndex;

  const _NavItem({
    required this.title,
    required this.index,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, currentIndex, _) {
        final isSelected = currentIndex == index;

        return ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          tileColor: isSelected ? Colors.black26 : null,
          onTap: () => selectedIndex.value = index,
        );
      },
    );
  }
}