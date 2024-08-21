class User {
  final String tenDangNhap;
  final String matKhau;
  final String maNguoiDung;
  final String tenNguoiDung;
  final String diaChi;
  final String sdt;
  final String email;
  final String gioiTinh;
  final String role;

  User({
    required this.tenDangNhap,
    required this.matKhau,
    required this.maNguoiDung,
    required this.tenNguoiDung,
    required this.diaChi,
    required this.sdt,
    required this.email,
    required this.gioiTinh,
    this.role = 'user',
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      tenDangNhap: map['TenDangNhap'],
      matKhau: map['MatKhau'],
      maNguoiDung: map['MaNguoiDung'],
      tenNguoiDung: map['TenNguoiDung'],
      diaChi: map['DiaChi'],
      sdt: map['SDT'],
      email: map['Email'],
      gioiTinh: map['GioiTinh'],
      role: map['Role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'TenDangNhap': tenDangNhap,
      'MatKhau': matKhau,
      'MaNguoiDung': maNguoiDung,
      'TenNguoiDung': tenNguoiDung,
      'DiaChi': diaChi,
      'SDT': sdt,
      'Email': email,
      'GioiTinh': gioiTinh,
      'Role': role,
    };
  }
}
