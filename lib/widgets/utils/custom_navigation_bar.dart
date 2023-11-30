import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final void Function(int index) onDestinationSelected;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: destinations.map((destination) {
          final index = destinations.indexOf(destination);

          return GestureDetector(
            onTap: () => onDestinationSelected(index),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  selectedIndex == index
                      ? destination.selectedIcon!
                      : destination.icon,
                  const SizedBox(height: 4),
                  Text(
                    destination.label,
                    style: TextStyle(
                      color: appColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
