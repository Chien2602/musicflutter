class Admin {
  final String username;
  final String pass;
  final String id;
  final String hoTen;
  final DateTime ngaySinh;
  final String gioiTinh;
  final String diaChi;
  final String sdt;
  final DateTime ngayNhamChuc;
  final String role;

  Admin({
    required this.username,
    required this.pass,
    required this.id,
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    required this.diaChi,
    required this.sdt,
    required this.ngayNhamChuc,
    this.role = 'admin',
  });

  // Chuyển đổi từ một Map (cơ sở dữ liệu) thành đối tượng Admin
  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      username: map['username'],
      pass: map['pass'],
      id: map['ID'],
      hoTen: map['HoTen'],
      ngaySinh: DateTime.parse(map['NgaySinh']),
      gioiTinh: map['GioiTinh'],
      diaChi: map['DiaChi'],
      sdt: map['SDT'],
      ngayNhamChuc: DateTime.parse(map['NgayNhamChuc']),
      role: map['Role'] ?? 'admin',
    );
  }

  // Chuyển đổi từ đối tượng Admin thành Map (cơ sở dữ liệu)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'pass': pass,
      'ID': id,
      'HoTen': hoTen,
      'NgaySinh': ngaySinh.toIso8601String(),
      'GioiTinh': gioiTinh,
      'DiaChi': diaChi,
      'SDT': sdt,
      'NgayNhamChuc': ngayNhamChuc.toIso8601String(),
      'Role': role,
    };
  }
}
