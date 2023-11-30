import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

logUserIn(
  String emailOrUsername,
  String password,
) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  final response = await dio.post('$apiKey/auth/signin', data: {
    'emailOrUsername': emailOrUsername,
    'password': password,
  });

  return response.data;
}
