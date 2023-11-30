import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

resendVerificationCode(
  String email,
) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  final response =
      await dio.put('$apiKey/auth/resend-verification-code', data: {
    'email': email,
  });

  return response.data;
}
