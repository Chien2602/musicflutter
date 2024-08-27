import 'package:flutter/material.dart';
import '../../Database/Data.dart';

class UserManagement extends StatefulWidget {
  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = AppDatabase.getAllUsers();
  }

  void _deleteUser(String userId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo', style: TextStyle(color: Colors.redAccent)),
          content: Text('Bạn muốn xóa người dùng này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Hủy', style: TextStyle(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Xóa', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await AppDatabase.deleteUser(userId);
      setState(() {
        _usersFuture = AppDatabase.getAllUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: IconButton(
          icon: Icon(Icons.person),
          onPressed: () {},
        ),
        title: Text(
          "Quản lý người dùng",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white70,
              Colors.green,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Không tìm thấy người dùng'));
              } else {
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            user['TenNguoiDung'][0].toUpperCase(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          user['TenNguoiDung'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          user['Email'],
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            _deleteUser(user['MaNguoiDung']);
                          },
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Thông tin người dùng', style: TextStyle(color: Colors.teal)),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Tên đăng nhập: ${user['TenDangNhap']}'),
                                    SizedBox(height: 8),
                                    Text('Mật khẩu: ${user['MatKhau']}'),
                                    SizedBox(height: 8),
                                    Text('Họ tên: ${user['TenNguoiDung']}'),
                                    SizedBox(height: 8),
                                    Text('Mã người dùng: ${user['MaNguoiDung']}'),
                                    SizedBox(height: 8),
                                    Text('Email: ${user['Email']}'),
                                    SizedBox(height: 8),
                                    Text('Địa chỉ: ${user['DiaChi']}'),
                                    SizedBox(height: 8),
                                    Text('SĐT: ${user['SDT']}'),
                                    SizedBox(height: 8),
                                    Text('Giới tính: ${user['GioiTinh']}'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Đóng', style: TextStyle(color: Colors.teal)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
