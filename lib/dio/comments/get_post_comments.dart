import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

getPostComments(
  String? postId,
  int? page,
) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: dioRefreshTokenRequestInterceptor,
    ),
  );

  final response = await dio.get(
    '$apiKey/comment?post=$postId&page=$page',
  );

  return response.data;
}
