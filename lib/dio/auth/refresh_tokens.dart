import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

refreshTokens(String? refreshToken) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();
  final response = await dio.post('$apiKey/auth/refresh', data: {
    'refreshToken': refreshToken,
  });
  return response.data;
}
