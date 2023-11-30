import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

getPostOrCommentLikes(
  String? postId,
  int? page,
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
    final response = await dio.get(
      '$apiKey/like/all?post=$postId&page=$page',
    );

    return response.data;
  }

  final response = await dio.get(
    '$apiKey/like/all?comment=$commentId&page=$page',
  );

  return response.data;
}
