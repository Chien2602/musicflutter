import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicflutter/UI/Login.dart';

import 'HomePage/Home.dart';
import 'HomePage/ListMusic.dart';
import 'HomePage/Settings.dart';
import 'HomePage/User.dart';

class HomePageUser extends StatefulWidget {
  @override
  _HomePageUserState createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  int _selectedIndex = 0;
  String answer = "?";

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ListPage(),
    UserPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Tooltip(
          message: 'back',
          child: IconButton(onPressed: (){
            showMyAlertDialog(context);
          }, icon: Icon(FontAwesomeIcons.angleLeft)),
        ),
        title: Text('My App'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house, color: Colors.blue,),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.list, color: Colors.blue,),
            label: 'List',
          ),

          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user, color: Colors.blue,),
            label: 'User',
          ),

          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gear, color: Colors.blue,),
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
    // Create AlertDialog
    AlertDialog dialog = AlertDialog(
      title: Text("Thông báo"),
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

    // Call showDialog function to show dialog.
    Future<String?> futureValue = showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );

    futureValue.then((String? data) {
      setState(() {
        answer = data ?? "?";
        if(answer == "Yes"){
          Navigator.push(
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


