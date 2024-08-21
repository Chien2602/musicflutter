import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../Database/Data.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _tenNguoiDung = '';
  String _diaChi = '';
  String _sdt = '';
  String _email = '';
  bool _nam = true;
  bool _nu = false;


  Future<String> _generateMaNguoiDung() async {
    final dbHelper = AppDatabase();
    int userCount = await dbHelper.getUserCount();
    String maNguoiDung = 'U000${userCount + 1}';
    return maNguoiDung;
  }

  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Tự động gán MaNguoiDung
      String maNguoiDung = await _generateMaNguoiDung();

      print('TenDangNhap: $_username');
      print('MatKhau: $_password');
      print('MaNguoiDung: $maNguoiDung');
      print('TenNguoiDung: $_tenNguoiDung');
      print('DiaChi: $_diaChi');
      print('SDT: $_sdt');
      print('Email: $_email');
      print('GioiTinh: ${_nam ? 'Nam' : 'Nữ'}');

      // Khởi tạo sqflite FFI và mở cơ sở dữ liệu
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final databasePath = join(await getDatabasesPath(), 'music.db');
      final database = await databaseFactory.openDatabase(databasePath);

      // Thêm dữ liệu vào bảng USER
      await database.execute('''
      INSERT INTO USER (TenDangNhap, MatKhau, MaNguoiDung, TenNguoiDung, DiaChi, SDT, Email, GioiTinh, role)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
        _username,
        _password,
        maNguoiDung,
        _tenNguoiDung,
        _diaChi,
        _sdt,
        _email,
        _nam ? 'Nam' : 'Nữ',
        'user'
      ]);

      // Thêm dữ liệu vào bảng ACCOUNT
      await database.execute('''
      INSERT INTO ACCOUNT (Username, Password, Role)
      VALUES (?, ?, ?)
    ''', [
        _username,
        _password,
        'user'
      ]);

      // Truy vấn và in dữ liệu từ bảng ACCOUNT
      List<Map<String, dynamic>> accountList = await database.query('ACCOUNT');
      print('Account data: $accountList');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Tooltip(
          message: 'back',
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(FontAwesomeIcons.angleLeft),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
              Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 50),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tên Đăng Nhập',
                  prefixIcon: Icon(FontAwesomeIcons.userLarge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mật Khẩu',
                  prefixIcon: Icon(FontAwesomeIcons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải ít nhất 6 ký tự';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tên Người Dùng',
                  prefixIcon: Icon(FontAwesomeIcons.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người dùng';
                  }
                  return null;
                },
                onSaved: (value) {
                  _tenNguoiDung = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Địa Chỉ',
                  prefixIcon: Icon(FontAwesomeIcons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
                onSaved: (value) {
                  _diaChi = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Số Điện Thoại',
                  prefixIcon: Icon(FontAwesomeIcons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
                onSaved: (value) {
                  _sdt = value ?? '';
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(FontAwesomeIcons.envelope),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Giới Tính:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _nam,
                        onChanged: (bool? value) {
                          setState(() {
                            _nam = value ?? true;
                            _nu = !value!;
                          });
                        },
                      ),
                      Text('Nam'),
                    ],
                  ),
                  SizedBox(width: 5),
                  Row(
                    children: [
                      Checkbox(
                        value: _nu,
                        onChanged: (bool? value) {
                          setState(() {
                            _nu = value ?? true;
                            _nam = !value!;
                          });
                        },
                      ),
                      Text('Nữ'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding:
                  EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Đăng ký',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 20), // Thêm khoảng cách giữa nút và đáy
            ],
          ),
        ),
      ),
    );
  }
}
