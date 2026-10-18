
import 'dart:convert';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  factory ApiException.fromResponse({
    required int statusCode,
    required String body,
  }) {
    var message = 'Something went wrong. Please try again.';

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];

        if (detail is String && detail.isNotEmpty) {
          message = detail;
        } else if (detail is List) {
          final messages = detail
              .whereType<Map>()
              .map((item) => item['msg'])
              .whereType<String>()
              .where((item) => item.isNotEmpty)
              .toList();

          if (messages.isNotEmpty) {
            message = messages.join('\n');
          }
        }
      }
    } on FormatException {
      // Keep the default message.
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
