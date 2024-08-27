import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicflutter/UI/HomePage/UserManagement.dart';

import 'HomePage/AdminAccount.dart';
import 'HomePage/Home.dart';
import 'HomePage/ListMusic.dart';
import 'HomePage/Settings.dart';
import 'Login.dart';

class HomePageAdmin extends StatefulWidget {
  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  final List<Widget> _widgetOptions = [
    HomePage(),
    ListPage(),
    UserManagement(),
    AdminAccount(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Tooltip(
          message: 'Back',
          child: IconButton(
            onPressed: () {
              showMyAlertDialog(context);
            },
            icon: Icon(FontAwesomeIcons.angleLeft),
          ),
        ),
        title: Center(child: Text('MUSIC APP')),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house, color: Colors.deepPurple),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.list, color: Colors.deepPurple),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.users, color: Colors.deepPurple),
            label: 'User Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userLarge, color: Colors.deepPurple),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gear, color: Colors.deepPurple),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void showMyAlertDialog(BuildContext context) {
    AlertDialog dialog = AlertDialog(
      title: Text("Thông báo", style: TextStyle(color: Colors.redAccent)),
      content: Text("Bạn muốn đăng xuất?"),
      actions: [
        ElevatedButton(
          child: Text("Yes"),
          onPressed: () {
            Navigator.pop(context, "Yes");
          },
        ),
        ElevatedButton(
          child: Text("No"),
          onPressed: () {
            Navigator.pop(context, "No");
          },
        ),
      ],
    );

    Future<String?> futureValue = showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );

    futureValue.then((String? data) {
      setState(() {
        if (data == "Yes") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      });
    }).catchError((error) {
      print("Error! " + error.toString());
    });
  }
}
