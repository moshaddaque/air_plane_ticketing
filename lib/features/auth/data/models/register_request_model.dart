
class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String role;

  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    this.role = 'passenger',
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName.trim(),
      'email': email.trim(),
      'password': password,
      'role': role,
    };
  }
}
