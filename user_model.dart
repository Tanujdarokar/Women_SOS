class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String phone;
  final String? password;
  final String role;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.password,
    this.role = "User",
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? "User",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      if (password != null) 'password': password,
      'role': role,
    };
  }
}
