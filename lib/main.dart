import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UI/Login.dart';
import 'font_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => FontProvider()),
      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeNotifier, FontProvider>(
      builder: (context, themeNotifier, fontProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Login UI',
          theme: themeNotifier.isDarkMode
              ? ThemeData.dark().copyWith(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontFamily: fontProvider.selectedFont, color: Colors.white),
              bodyMedium: TextStyle(fontFamily: fontProvider.selectedFont, color: Colors.white),
            ),
          )
              : ThemeData.light().copyWith(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontFamily: fontProvider.selectedFont),
              bodyMedium: TextStyle(fontFamily: fontProvider.selectedFont),
            ),
          ),
          home: LoginPage(),
        );
      },
    );
  }
}


class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}


