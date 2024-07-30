import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Login.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String answer = '?';
  void showMyAlertDialog(BuildContext context) {
    // Create AlertDialog
    AlertDialog dialog = AlertDialog(
      title: Text("Thông báo"),
      content: Text("Bạn đăng kí thành công.\n Quay lại trang đăng nhập?"),
      actions: [
        ElevatedButton(
          child: Text("Yes"),
          onPressed: () {
            Navigator.pop(context, "Yes");
          },
        ),
        ElevatedButton(
          child: Text("No"),
          onPressed: () {
            Navigator.pop(context, "No");
          },
        ),
      ],
    );

    // Call showDialog function to show dialog.
    Future<String?> futureValue = showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );

    futureValue.then((String? data) {
      setState(() {
        answer = data ?? "?";
        if(answer == "Yes"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      });
    }).catchError((error) {
      print("Error! " + error.toString());
    });
  }
  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      print('Username: $_username');
      print('Email: $_email');
      print('Password: $_password');
      print('Confirm Password: $_confirmPassword');
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              icon: Icon(FontAwesomeIcons.angleLeft)),
        ),
        //title: Center(child: Text('MUSIC APP'),),
        backgroundColor: Colors.white,
      ),
      body:
       SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image.asset(
              //   'assets/logo.png',
              //   height: 100,
              // ),
              //SizedBox(height: 30),
              Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 80),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(FontAwesomeIcons.userLarge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
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
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value ?? '';
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value ?? '';
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
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
                          return 'Please confirm your password';
                        } else if (value == _password) {
                          return 'Passwords do not match';
                          // print(_password);
                          // print(value);
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _confirmPassword = value ?? '';
                      },
                    ),

                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {showMyAlertDialog(context); _signup();},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Đăng kí',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

    );
  }
}
