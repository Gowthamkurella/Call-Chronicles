import 'package:flutter/material.dart';
import 'main.dart'; // Import your CallLogsPage widget
import 'contact_list_page.dart'; // Import your ContactsPage widget
import 'custom_dialer_page.dart'; // Import your CustomDialerPage widget

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // Default to showing the CallLogScreen

  // Screens for each tab
  final List<Widget> _screens = [CallLogScreen(), ContactListPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => CustomDialerPage()));
          },
          child: Icon(Icons.dialpad),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.grey[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.history, color: _selectedIndex == 0 ? Colors.white : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.contacts, color: _selectedIndex == 1 ? Colors.white : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}
