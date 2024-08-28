import 'package:flutter/material.dart';
import 'package:musicflutter/Database/Data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';

import 'UI/SpotifyAuthPage.dart';
import 'UI/ThemeNotifier.dart';
import 'font_provider.dart';


Future<void> insertAdminData(Database database) async {
  await database.execute('''
    INSERT OR REPLACE INTO [ADMIN] ([username], [pass], [ID], [HoTen], [NgaySinh], [GioiTinh], [DiaChi], [SDT], [NgayNhamChuc], [role])
    VALUES
    ('admin1', 'vophamtuanan', 'A001', 'Võ Phạm Tuấn An', '2003-10-22', 'Nam', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0123456789', '2024-08-01', 'admin'),
    ('admin2', 'nguyenthaoanh', 'A002', 'Nguyễn Thảo Anh', '2004-09-16', 'Nữ', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0987654321', '2024-08-01', 'admin'),
    ('admin3', 'labaochien', 'A003', 'La Bảo Chiến', '2004-02-26', 'Nam', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0112233445', '2024-08-01', 'admin'),
    ('admin4', 'nguyenvanhoang', 'A004', 'Nguyễn Văn Hoàng', '2004-10-07', 'Nam', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0667788999', '2024-08-01', 'admin'),
    ('admin5', 'nguyenquockhang', 'A005', 'Nguyễn Quốc Khang', '2004-01-01', 'Nam', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0555666777', '2024-08-01', 'admin');
  ''');
}

// Hàm để thêm dữ liệu vào bảng USER
Future<void> insertUserData(Database database) async {
  await database.execute('''
    INSERT OR REPLACE INTO [USER] ([TenDangNhap], [MatKhau], [MaNguoiDung], [TenNguoiDung], [DiaChi], [SDT], [Email], [GioiTinh], [role])
    VALUES
    ('user1', 'password1', 'U001', 'Nguyễn Thị Anh', '303 Đường Nguyễn Trãi, Quận 1, TP.HCM', '0777888999', 'user1@example.com', 'Nữ', 'user'),
    ('user2', 'password2', 'U002', 'Nguyễn Văn Bình', '404 Đường Kim Mã, Quận Ba Đình, Hà Nội', '0888999000', 'user2@example.com', 'Nam', 'user'),
    ('user3', 'password3', 'U003', 'Lê Thị Cẩm', '505 Đường Bạch Đằng, Quận Hải Châu, Đà Nẵng', '0999000111', 'user3@example.com', 'Nữ', 'user'),
    ('user4', 'password4', 'U004', 'Hồ Văn Dũng', '606 Đường Nguyễn Trãi, Quận Ninh Kiều, Cần Thơ', '1000111222', 'user4@example.com', 'Nam', 'user'),
    ('user5', 'password5', 'U005', 'Vũ Thị Hạnh', '707 Đường Lạch Tray, Quận Ngô Quyền, Hải Phòng', '1111222333', 'user5@example.com', 'Nữ', 'user'),
    ('user6', 'password6', 'U006', 'Phạm Văn Khoa', '808 Đường Cộng Hòa, Quận Tân Bình, TP.HCM', '1222333444', 'user6@example.com', 'Nam', 'user'),
    ('user7', 'password7', 'U007', 'Trần Thị Lan', '909 Đường Trần Duy Hưng, Quận Cầu Giấy, Hà Nội', '1333444555', 'user7@example.com', 'Nữ', 'user'),
    ('user8', 'password8', 'U008', 'Nguyễn Thị Minh', '010 Đường Điện Biên Phủ, Quận Thanh Khê, Đà Nẵng', '1444555666', 'user8@example.com', 'Nữ', 'user'),
    ('user9', 'password9', 'U009', 'Lê Văn Nam', '121 Đường Trần Hưng Đạo, Quận Ninh Kiều, Cần Thơ', '1555666777', 'user9@example.com', 'Nam', 'user'),
    ('user10', 'password10', 'U010', 'Hồ Thị Phương', '232 Đường Tô Hiệu, Quận Lê Chân, Hải Phòng', '1666777888', 'user10@example.com', 'Nữ', 'user');
  ''');
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final databasePath = join(await getDatabasesPath(), 'music.db');
  final database = await openDatabase(databasePath);

  // Gọi các hàm để thêm dữ liệu
  await insertAdminData(database);
  await insertUserData(database);
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
  // List<Map<String, dynamic>> accountList = await database.query('ACCOUNT');
  // print('Account data: $accountList');

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


