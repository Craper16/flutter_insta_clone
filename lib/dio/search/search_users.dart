import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

searchUsers(String searchQuery) async {
  final String query = searchQuery.replaceAll(' ', '+');

  final apiKey = dotenv.env['API_KEY']!;
  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: dioRefreshTokenRequestInterceptor,
    ),
  );

  final response = await dio.get(
    '$apiKey/search?search_query=$query',
  );

  return response.data;
}
