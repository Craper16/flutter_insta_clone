import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

getUserFollowing(String userId) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: dioRefreshTokenRequestInterceptor,
    ),
  );

  final response = await dio.get(
    '$apiKey/user/following/$userId',
  );

  return response.data;
}
