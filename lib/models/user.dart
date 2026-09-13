class AppUser {
  final String username;
  final String password;
  final String name;
  final String role; // 'super_admin' or 'branch_admin'
  final String branchId; // 'SUPER_ADMIN' or branch id

  AppUser({
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.branchId,
  });

  bool get isSuperAdmin => role == 'super_admin';

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'role': role,
      'branchId': branchId,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'branch_admin',
      branchId: map['branchId'] ?? '',
    );
  }
}
