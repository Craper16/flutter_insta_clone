import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

postLike(
  String? postId,
  String? commentId,
) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: dioRefreshTokenRequestInterceptor,
    ),
  );

  if (postId != null) {
    final response = await dio.post(
      '$apiKey/like?post=$postId',
    );

    return response.data;
  }

  final response = await dio.post(
    '$apiKey/like?comment=$commentId',
  );

  return response.data;
}
