class User {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'],
    );
  }
}
