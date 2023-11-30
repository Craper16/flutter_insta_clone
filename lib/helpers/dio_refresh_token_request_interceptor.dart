import 'package:dio/dio.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/auth/refresh_tokens.dart';
import 'package:flutter_insta/main.dart';

void dioRefreshTokenRequestInterceptor(
    RequestOptions options, RequestInterceptorHandler handler) async {
  final access = await storage.read(key: accessToken);
  final refresh = await storage.read(key: refreshToken);
  final expiryTime = await storage.read(key: expiresAt);
  final expiryDate = DateTime.parse(expiryTime!);

  if (expiryDate.compareTo(DateTime.now()) == -1 ||
      expiryDate.compareTo(DateTime.now()) == 0) {
    try {
      final response = await refreshTokens(refresh);

      final responseAccessToken = response['access_token'];
      final responseRefreshToken = response['refresh_token'];
      final responseExpiresAt = response['expires_at'];

      await storage.write(
        key: accessToken,
        value: responseAccessToken,
      );
      await storage.write(
        key: refreshToken,
        value: responseRefreshToken,
      );
      await storage.write(
        key: expiresAt,
        value: responseExpiresAt,
      );
      options.headers['Authorization'] = 'Bearer $responseAccessToken';

      return handler.next(options);
    } on DioException catch (e) {
      print(e.response?.data);
    }
  }

  options.headers['Authorization'] = 'Bearer $access';

  return handler.next(options);
}
