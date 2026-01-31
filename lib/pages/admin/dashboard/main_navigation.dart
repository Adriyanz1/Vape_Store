import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vape_store/pages/admin/dashboard/dashboard_content.dart';
import 'package:vape_store/pages/admin/inventory/inventory_screen.dart';
import 'package:vape_store/pages/admin/sales/sales_history_screen.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final Color primaryBlue = const Color(0xFF5AB9E6);
  final Color accentPink = const Color(0xFFF48FB1);
  final Color background = const Color(0xFFF7F9FC);

  final List<Widget> _pages = [
    const DashboardContent(),
    InventoryScreen(),
    const SalesHistoryScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Scaffold(
          backgroundColor: background,
          appBar: isMobile
              ? AppBar(
                  title: const Text("RWP CLOUD"),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 1,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                )
              : null,
          drawer: isMobile
              ? SizedBox(width: 260, child: _buildSidebar(isMobile: true))
              : null,
          body: Row(
            children: [
              if (!isMobile)
                SizedBox(width: 260, child: _buildSidebar(isMobile: false)),
              Expanded(
                child: Container(
                  color: background,
                  child: _pages[_selectedIndex],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  backgroundColor: Colors.white,
                  selectedItemColor: primaryBlue,
                  unselectedItemColor: Colors.grey,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"),
                    BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Stok"),
                    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Sales"),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildSidebar({required bool isMobile}) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
              'assets/images/logo.png',
              height: 60,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.cloud, size: 100, color: Color.fromARGB(255, 245, 246, 247)),
            ),
                  const Text(
                    "RWP CLOUD",
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),
            ),
            _menuTile(Icons.dashboard, "Dashboard", 0),
            _menuTile(Icons.inventory, "Inventory", 1),
            _menuTile(Icons.shopping_cart, "Sales History", 2), 
            const Spacer(),
            _menuTile(Icons.logout, "Logout", -1, color: accentPink),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, int index, {Color? color}) {
    bool isSelected = _selectedIndex == index;

    return ListTile(
      selected: isSelected,
      selectedTileColor: primaryBlue.withOpacity(0.1),
      leading: Icon(
        icon,
        color: color ?? (isSelected ? primaryBlue : Colors.grey),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isSelected ? Colors.black : Colors.grey),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () async {
        if (index == -1) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('isLoggedIn'); 
          if (!mounted) return;
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        } else {
          setState(() => _selectedIndex = index);
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      },
    );
  }
}