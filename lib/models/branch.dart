class Branch {
  final String id;
  final String name;
  final String adminName;

  Branch({
    required this.id,
    required this.name,
    required this.adminName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'adminName': adminName,
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      adminName: map['adminName'] ?? '',
    );
  }
}
