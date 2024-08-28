import 'package:flutter/material.dart';
import 'package:musicflutter/Database/Data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';

import 'UI/SpotifyAuthPage.dart';
import 'UI/ThemeNotifier.dart';
import 'font_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  AppDatabase  db = new AppDatabase();
  final databasePath = join(await getDatabasesPath(), 'music.db');
  final database = await openDatabase(databasePath);

  // Gọi các hàm để thêm dữ liệu
  await db.insertAdminData(database);
  await db.insertUserData(database);
  await database.execute('''
    INSERT OR REPLACE INTO [ACCOUNT] (Username, Password, Role)
    SELECT [username], [pass], 'admin'
    FROM [ADMIN];
  ''');

  // Thêm dữ liệu vào bảng ACCOUNT từ USER
  await database.execute('''
    INSERT OR REPLACE INTO [ACCOUNT] (Username, Password, Role)
    SELECT [TenDangNhap], [MatKhau], 'user'
    FROM [USER];
  ''');

  // Truy vấn và in dữ liệu từ bảng ACCOUNT
  List<Map<String, dynamic>> accountList = await database.query('ACCOUNT');
  print('Account data: $accountList');

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
