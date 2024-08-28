import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Future<Database> initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final databasePath = join(await getDatabasesPath(), 'music.db');
    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE [ADMIN] (
            [username] NVARCHAR(50) NOT NULL PRIMARY KEY,
            [pass] NVARCHAR(50) NOT NULL,
            [ID] NVARCHAR(5) NOT NULL,
            [HoTen] NVARCHAR(50) NOT NULL,
            [NgaySinh] DATE NOT NULL,
            [GioiTinh] NVARCHAR(3) NOT NULL,
            [DiaChi] NVARCHAR(100) NOT NULL,
            [SDT] NVARCHAR(11) NOT NULL,
            [NgayNhamChuc] DATE NOT NULL,
            [Role] NVARCHAR(5) NOT NULL DEFAULT 'admin'
          )
        ''');

        await db.execute('''
          CREATE TABLE [USER] (
            [TenDangNhap] NVARCHAR(50) NOT NULL UNIQUE,
            [MatKhau] NVARCHAR(50) NOT NULL,
            [MaNguoiDung] NVARCHAR(10) NOT NULL PRIMARY KEY,
            [TenNguoiDung] NVARCHAR(50) NOT NULL,
            [DiaChi] NVARCHAR(100) NOT NULL,
            [SDT] NVARCHAR(12) NOT NULL,
            [Email] NVARCHAR(50) NOT NULL,
            [GioiTinh] NVARCHAR(4) NOT NULL,
            [Role] NVARCHAR(5) NOT NULL DEFAULT 'user'
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS [ACCOUNT] (
            [IdTK] INTEGER PRIMARY KEY AUTOINCREMENT,
            [Username] NVARCHAR(50) NOT NULL UNIQUE,
            [Password] NVARCHAR(50) NOT NULL,
            [Role] NVARCHAR(10) NOT NULL CHECK (Role IN ('admin', 'user'))
          )
        ''');
      },
    );
  }

  // Methods for ADMIN table
  static Future<List<Map<String, dynamic>>> getAdminData() async {
    final db = await initDatabase();
    return await db.query('[ADMIN]');
  }

  // Methods for USER table
  static Future<List<Map<String, dynamic>>> getUserData() async {
    final db = await initDatabase();
    return await db.query('[USER]');
  }

  // Methods for ACCOUNT table
  static Future<int> addAccount(Map<String, dynamic> account) async {
    final db = await initDatabase();
    return await db.insert('[ACCOUNT]', account);
  }

  static Future<int> updateAccount(int idTK, Map<String, dynamic> updates) async {
    final db = await initDatabase();
    return await db.update('[ACCOUNT]', updates, where: '[IdTK] = ?', whereArgs: [idTK]);
  }

  static Future<int> deleteAccount(int idTK) async {
    final db = await initDatabase();
    return await db.delete('[ACCOUNT]', where: '[IdTK] = ?', whereArgs: [idTK]);
  }

  static Future<List<Map<String, dynamic>>> getAccountData() async {
    final db = await initDatabase();
    return await db.query('[ACCOUNT]');
  }

  static Future<Map<String, dynamic>?> getAccountById(int idTK) async {
    final db = await initDatabase();
    final result = await db.query('[ACCOUNT]', where: '[IdTK] = ?', whereArgs: [idTK]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await initDatabase();
    return await db.query('[USER]');
  }

  // Xóa người dùng theo mã người dùng
  static Future<int> deleteUser(String userId) async {
    final db = await initDatabase();
    return await db.delete('[USER]', where: 'MaNguoiDung = ?', whereArgs: [userId]);
  }

  static Future<bool> authenticateAdmin(String username, String password) async {
    final db = await initDatabase();
    final result = await db.query(
      'ADMIN',
      where: 'username = ? AND pass = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  static Future<bool> authenticateUser(String TenDangNhap, String MatKhau) async {
    final db = await initDatabase();
    final result = await db.query(
      'USER',
      where: 'TenDangNhap = ? AND MatKhau = ?',
      whereArgs: [TenDangNhap, MatKhau],
    );
    return result.isNotEmpty;
  }

  Future<int> getUserCount() async {
    final db = await initDatabase();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM USER'),
    );
    return count ?? 0;
  }


  static Future<Map<String, dynamic>?> getAdminByUsername(String username) async {
    final db = await initDatabase();
    final result = await db.query(
      'ADMIN',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }




  static Future<bool> changeAdminPassword(String username, String oldPassword, String newPassword) async {
    final db = await initDatabase();

    // Kiểm tra xem mật khẩu cũ có đúng không
    final result = await db.query(
      'ADMIN',
      where: 'username = ? AND pass = ?',
      whereArgs: [username, oldPassword],
    );

    if (result.isNotEmpty) {
      // Nếu đúng, cập nhật mật khẩu mới
      final count = await db.update(
        'ADMIN',
        {'pass': newPassword},
        where: 'username = ?',
        whereArgs: [username],
      );
      return count > 0;
    }

    // Mật khẩu cũ không đúng
    return false;
  }

  static Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await initDatabase();
    final result = await db.query(
      'USER',
      where: 'TenDangNhap = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }




  static Future<bool> changeUserPassword(String username, String oldPassword, String newPassword) async {
    final db = await initDatabase();

    // Kiểm tra xem mật khẩu cũ có đúng không
    final result = await db.query(
      'USER',
      where: 'TenDangNhap = ? AND MatKhau = ?',
      whereArgs: [username, oldPassword],
    );

    if (result.isNotEmpty) {
      // Nếu đúng, cập nhật mật khẩu mới
      final count = await db.update(
        'USER',
        {'MatKhau': newPassword},
        where: 'TenDangNhap = ?',
        whereArgs: [username],
      );
      return count > 0;
    }

    // Mật khẩu cũ không đúng
    return false;
  }

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await initDatabase();
    final result = await db.query(
      '[ACCOUNT]',
      where: 'Username = ? AND Password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
