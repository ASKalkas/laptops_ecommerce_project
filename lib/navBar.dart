import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './Providers/authProvider.dart' as AuthProvider;

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selectedIndex = 0;
  String? role;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // maybe pop first?
    switch (selectedIndex) {
      case 0:
        Navigator.pushNamed(
          context,
          "/home",
        );
        break;
      case 1:
        Navigator.pushNamed(
          context,
          '/cart',
        );
        break;
      case 2:
        Navigator.pushNamed(
          context,
          '/profile',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider.AuthenticationProvider>(context, listen: true);
    role = authProvider.role;
    print(role);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(1.00, 0.00),
          end: Alignment(-1, 0),
          colors: [Colors.white, Color.fromARGB(255, 48, 46, 46)],
        ),
      ),
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: role?.toLowerCase() == "vendor"
                ? const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.black,
                  )
                : const Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                  ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              color: Colors.black,
            ),
            label: '',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        iconSize: 30.0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
