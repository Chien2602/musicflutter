class Account {
  final int idTk;
  final String username;
  final String password;
  final String role;

  Account({
    required this.idTk,
    required this.username,
    required this.password,
    this.role = 'user',
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      idTk: map['IdTK'],
      username: map['Username'],
      password: map['Password'],
      role: map['Role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IdTK': idTk,
      'Username': username,
      'Password': password,
      'Role': role,
    };
  }
}
