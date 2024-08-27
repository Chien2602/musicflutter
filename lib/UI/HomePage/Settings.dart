import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../font_provider.dart';
import '../ThemeNotifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var items = [
    'Roboto',
    'Lato',
    'Ubuntu',
    'JetBrainsMono',
    'NotoSerif',
    'RobotoRegular'
  ];
  String? dropdownvalue;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final fontProvider = Provider.of<FontProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          "Cài đặt",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chế độ tối',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      Provider.of<ThemeNotifier>(context, listen: false)
                          .toggleTheme();
                    },
                    activeColor: Colors.blueAccent,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade400,
                  ),
                ],
              ),
              Divider(thickness: 1, height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Chọn font chữ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownvalue,
                      icon: Icon(
                        FontAwesomeIcons.arrowDown,
                        size: 15,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      dropdownColor:
                          isDarkMode ? Colors.grey.shade800 : Colors.white,
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(
                            items,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                          fontProvider.updateFont(newValue);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

    );
  }
}
