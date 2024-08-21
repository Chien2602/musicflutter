import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicflutter/UI/Signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/Data.dart';
import 'HomePageAdmin.dart';
import 'HomePageUser.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Giả sử admin có quyền truy cập và bạn có một phương thức kiểm tra đăng nhập
      bool admin = await AppDatabase.authenticateAdmin(_username, _password);
      bool user = await AppDatabase.authenticateUser(_username, _password);

      if (admin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', _username);

        print('Login successful');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePageAdmin()),
        );
      }
      else if(user){
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('TenDangNhap', _username);

        print('Login successful');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePageUser()),
        );
      }
      else {
        thongbao();
      }

      }
    }

  void thongbao() async {
    // Hiển thị hộp thoại xác nhận
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      // Ngăn không cho đóng hộp thoại bằng cách nhấn ra ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo', style: TextStyle(color: Colors.redAccent)),
          content: Text(
              'Bạn đăng nhập không thành công!!!',
          style: TextStyle(fontWeight: FontWeight.bold),),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('OK', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }






  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Signup()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginPageTheme = ThemeData.light().copyWith(
      primaryColor: Colors.teal,
    );

    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                FontAwesomeIcons.lock,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 50),
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[400],
                ),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(FontAwesomeIcons.userLarge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        filled: true,
                        fillColor: Colors.white,

                      ),
                      style: TextStyle(color: Colors.black),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value ?? '';
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(FontAwesomeIcons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        filled: true,
                        fillColor: Colors.white,

                      ),
                      style: TextStyle(color: Colors.black),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value ?? '';
                      },
                    ),
                    SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent[400],
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: _navigateToSignup,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Create an Account',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}