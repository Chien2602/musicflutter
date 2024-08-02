//import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../font_provider.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  var items = ['Roboto', 'Lato', 'Ubuntu', 'JetBrainsMono', 'NotoSerif', 'RobotoRegular'];
  String? dropdownvalue;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final fontProvider = Provider.of<FontProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              SizedBox(width: 20),
              Text(
                'Chế độ tối',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(isDarkMode
                    ? FontAwesomeIcons.toggleOn
                    : FontAwesomeIcons.toggleOff),
                iconSize: 45,
                onPressed: () {
                  Provider.of<ThemeNotifier>(context, listen: false)
                      .toggleTheme();
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              SizedBox(width: 20),
              Text(
                "Chọn font chữ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 20),
              DropdownButton(
                // Initial Value
                value: dropdownvalue,

                icon: const Icon(
                  FontAwesomeIcons.arrowDown,
                  size: 15,
                ),

                items: items.map((String items) {
                  return DropdownMenuItem(
                      value: items,
                      child: Text(
                        items,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ));
                }).toList(),

                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                    fontProvider.updateFont(newValue);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
