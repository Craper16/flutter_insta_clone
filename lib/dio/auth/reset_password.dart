import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

resetPassword(
  String email,
  String newPassword,
  int verificationCode,
) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  final response = await dio.put('$apiKey/auth/reset-password', data: {
    'email': email,
    'newPassword': newPassword,
    'verificationCode': verificationCode,
  });

  return response.data;
}
