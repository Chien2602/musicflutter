import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Database/Data.dart';

class AdminAccount extends StatefulWidget {
  @override
  _AdminAccountState createState() => _AdminAccountState();
}

class _AdminAccountState extends State<AdminAccount> {
  late Future<String> _adminnameFuture;
  Map<String, dynamic>? _adminInfo;

  @override
  void initState() {
    super.initState();
    _adminnameFuture = _loadUsername();
  }

  Future<String> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'No username';
  }

  void _loadAdminInfo(String username) async {
    final adminData = await AppDatabase.getAdminByUsername(username);
    if (adminData != null) {
      setState(() {
        _adminInfo = adminData;
      });
    } else {
      print('Admin not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.info, color: Colors.white),
          onPressed: () {},
        ),
        title: Text("Thông tin tài khoản",
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: FutureBuilder<String>(
          future: _adminnameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == 'No username') {
              return Center(child: Text('Admin not found'));
            } else {
              final username = snapshot.data!;
              _loadAdminInfo(username);

              if (_adminInfo == null) {
                return Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          _buildInfoCard('Tên đăng nhập', _adminInfo!['username']),
                          _buildInfoCard('Mật khẩu', _adminInfo!['pass']),
                          _buildInfoCard('ID', _adminInfo!['ID']),
                          _buildInfoCard('Họ và tên', _adminInfo!['HoTen']),
                          _buildInfoCard('Ngày Sinh', _adminInfo!['NgaySinh']),
                          _buildInfoCard('Giới tính', _adminInfo!['GioiTinh']),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 160, // Reduced width for the button
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordPage(
                                  username: username,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Đổi mật khẩu',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
        leading: Icon(
          Icons.info_outline_rounded,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  final String username;

  ChangePasswordPage({required this.username});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _oldPassword = '';
  String _newPassword = '';

  void _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      bool success = await AppDatabase.changeAdminPassword(
          widget.username, _oldPassword, _newPassword);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('ĐỔI MẬT KHẨU',
                style: TextStyle(fontWeight: FontWeight.bold))),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: (){Navigator.pop(context);},
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent.shade100, Colors.blueAccent.shade200],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu cũ',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu cũ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _oldPassword = value ?? '';
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải nhiều hơn 6 ký tự';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _newPassword = value ?? '';
                  },
                ),
                SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[700],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
