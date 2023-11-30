import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

signupUser(
  String email,
  String password,
  String username,
  String fullName,
  String countryCode,
  String phoneNumber,
) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  final response = await dio.post('$apiKey/auth/signup', data: {
    'email': email,
    'password': password,
    'username': username,
    'fullName': fullName,
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
  });

  return response.data;
}
