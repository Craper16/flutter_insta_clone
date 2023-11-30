import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

editProfile(
  String countryCode,
  String fullName,
  String phoneNumber,
  String username,
) async {
  final apiKey = dotenv.env['API_KEY']!;
  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: dioRefreshTokenRequestInterceptor,
    ),
  );

  final response = await dio.put(
    '$apiKey/auth/me/edit-profile',
    data: {
      'countryCode': countryCode,
      'fullName': fullName,
      'username': username,
      'phoneNumber': phoneNumber,
    },
  );

  return response.data;
}
