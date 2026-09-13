class Servant {
  final String id;
  final String name;
  final String phone;
  final String branchId;
  final bool active;

  Servant({
    required this.id,
    required this.name,
    required this.phone,
    required this.branchId,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'branchId': branchId,
      'active': active,
    };
  }

  factory Servant.fromMap(Map<String, dynamic> map) {
    return Servant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      branchId: map['branchId'] ?? '',
      active: map['active'] ?? true,
    );
  }
}
