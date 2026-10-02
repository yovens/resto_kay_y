class User {
  final int id;
  final String name;
  final String email;
  final String? telephone;
  final String? role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.telephone,
    this.role,
  });

  factory User.fromJson(
    Map<String, dynamic> json,
  ) {
    return User(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email:
          json['email']?.toString() ?? '',
      telephone:
          json['telephone']?.toString(),
      role:
          json['role']?.toString(),
    );
  }
}