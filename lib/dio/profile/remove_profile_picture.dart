import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

removeProfilePicture() async {
  final apiKey = dotenv.env['API_KEY']!;
  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: dioRefreshTokenRequestInterceptor,
    ),
  );

  final response = await dio.delete(
    '$apiKey/auth/me/remove-profile-picture',
  );

  return response.data;
}
