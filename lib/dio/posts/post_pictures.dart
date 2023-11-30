import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_insta/helpers/dio_refresh_token_request_interceptor.dart';

postPictures(
  FormData data,
) async {
  final apiKey = dotenv.env['API_KEY']!;
  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: dioRefreshTokenRequestInterceptor,
    ),
  );

  final response = await dio.post(
    '$apiKey/post',
    data: data,
    options: Options(
      headers: {'Content-Type': 'multipart/form-data'},
    ),
  );

  return response.data;
}
