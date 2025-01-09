class User {
  int? id;
  String? name;
  String? address;
  int? status;
  String? avatar;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? role;

  User(
      {this.id,
      this.name,
      this.address,
      this.status,
      this.avatar,
      this.createdAt,
      this.updatedAt,
      this.role});

  // Hàm từ JSON sang model
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      status: json['status'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      role: json['role'],
    );
  }

  // Hàm từ model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'status': status,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'role': role,
    };
  }
}
