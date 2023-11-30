import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

removeLike(
  String? postId,
  String? commentId,
  String? likeId,
) async {
  final apiKey = dotenv.env['API_KEY']!;

  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: dioRefreshTokenRequestInterceptor,
    ),
  );

  if (likeId != null) {
    final response = await dio.delete(
      '$apiKey/like?likeId=$likeId',
    );

    return response;
  }

  if (postId != null) {
    final response = await dio.delete(
      '$apiKey/like?post=$postId',
    );

    return response;
  }

  final response = await dio.delete(
    '$apiKey/like?comment=$commentId',
  );

  return response.data;
}
