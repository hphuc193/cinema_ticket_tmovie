// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        elevation: 0, // We're using custom shadow
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home, 0, isDarkMode),
            activeIcon: _buildNavIcon(Icons.home, 0, isDarkMode, isActive: true),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.confirmation_number, 1, isDarkMode),
            activeIcon: _buildNavIcon(Icons.confirmation_number, 1, isDarkMode, isActive: true),
            label: 'Vé của tôi',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.person, 2, isDarkMode),
            activeIcon: _buildNavIcon(Icons.person, 2, isDarkMode, isActive: true),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, bool isDarkMode, {bool isActive = false}) {
    final isSelected = currentIndex == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isSelected && isActive)
            ? Colors.blue.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: isSelected ? 26 : 24,
        color: isSelected
            ? Colors.blue
            : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
      ),
    );
  }
}