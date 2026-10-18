
class User {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final String? profilePicture;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    this.profilePicture,
    this.createdAt,
  });
}
