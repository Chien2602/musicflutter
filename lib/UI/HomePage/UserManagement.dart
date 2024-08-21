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
    // Hiển thị hộp thoại xác nhận
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Ngăn không cho đóng hộp thoại bằng cách nhấn ra ngoài
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

    // Xóa người dùng nếu được xác nhận
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
        title: Text('User List'),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!;
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(user['TenNguoiDung'][0], style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(
                    user['TenNguoiDung'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(user['Email']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      _deleteUser(user['MaNguoiDung']);
                    },
                  ),
                  onTap: () {
                    // Xem chi tiết người dùng
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Thông tin người dùng', style: TextStyle(color: Colors.teal)),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Tên đăng nhập: ${user['TenDangNhap']}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Mật khẩu: ${user['MatKhau']}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Họ tên: ${user['TenNguoiDung']}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Mã người dùng: ${user['MaNguoiDung']}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Email: ${user['Email']}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Địa chỉ: ${user['DiaChi']}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('SĐT: ${user['SDT']}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Giới tính: ${user['GioiTinh']}', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close', style: TextStyle(color: Colors.teal)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
