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
        await db.execute('''
           INSERT OR REPLACE INTO [ADMIN] ([username], [pass], [ID], [HoTen], [NgaySinh], [GioiTinh], [DiaChi], [SDT], [NgayNhamChuc], [Role])
           VALUES
           ('admin1', 'vophamtuanan', 'A001', 'Võ Phạm Tuấn An', '2003-10-22', 'Nam', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0123456789', '2024-08-01', 'admin'),
           ('admin2', 'nguyenthaoanh', 'A002', 'Nguyễn Thảo Anh', '2004-09-16', 'Nữ', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0987654321', '2024-08-01', 'admin'),
           ('admin3', 'labaochien', 'A003', 'La Bảo Chiến', '2004-02-26', 'Nam', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0112233445', '2024-08-01', 'admin'),
           ('admin4', 'nguyenvanhoang', 'A004', 'Nguyễn Văn Hoàng', '2004-10-07', 'Nam', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0667788999', '2024-08-01', 'admin'),
           ('admin5', 'nguyenquockhang', 'A005', 'Nguyễn Quốc Khang', '2004-01-01', 'Nam', '351 Lạc Long Quân, Phường 5, Quận 11, Thành phố Hồ Chí Minh', '0555666777', '2024-08-01', 'admin');
        ''');
        await db.execute('''
           INSERT OR REPLACE INTO [USER] ([TenDangNhap], [MatKhau], [MaNguoiDung], [TenNguoiDung], [DiaChi], [SDT], [Email], [GioiTinh], [Role])
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
        await db.execute('''
          INSERT OR REPLACE INTO [ACCOUNT] (Username, Password, Role)
          SELECT [username], [pass], 'admin'
          FROM [ADMIN];
        ''');

        // Thêm dữ liệu vào bảng ACCOUNT từ USER
        await db.execute('''
          INSERT OR REPLACE INTO [ACCOUNT] (Username, Password, Role)
          SELECT [TenDangNhap], [MatKhau], 'user'
          FROM [USER];
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
