
import 'user_model.dart';

class LoginResponseModel {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  const LoginResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final userJson = json['user'];

    if (userJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid user data in login response.',
      );
    }

    final token = json['access_token'];
    final type = json['token_type'];

    if (token is! String || token.isEmpty) {
      throw const FormatException(
        'Access token is missing.',
      );
    }

    if (type is! String || type.isEmpty) {
      throw const FormatException(
        'Token type is missing.',
      );
    }

    return LoginResponseModel(
      accessToken: token,
      tokenType: type,
      user: UserModel.fromJson(userJson),
    );
  }
}
