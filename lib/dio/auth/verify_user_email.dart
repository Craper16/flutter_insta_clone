import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

verifyUserEmail(
  String email,
  String verificationCode,
  String? login,
) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  final response = await dio.put('$apiKey/auth/verify?login=$login', data: {
    'email': email,
    'verificationCode': verificationCode,
  });

  return response.data;
}
