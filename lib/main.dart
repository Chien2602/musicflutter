import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UI/SpotifyAuthPage.dart';
import 'UI/ThemeNotifier.dart';
import 'font_provider.dart';



Future<void> main() async {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final fontProvider = Provider.of<FontProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: fontProvider.selectedFont,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: fontProvider.selectedFont,
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SpotifyAuthPage(),
    );
  }
}


