import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/auth/refresh_tokens.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  void _refreshUser() async {
    try {
      final previousRefreshToken = await storage.read(key: refreshToken);
      final data = await refreshTokens(previousRefreshToken);

      await storage.write(key: accessToken, value: data['access_token']);
      await storage.write(key: refreshToken, value: data['refresh_token']);
      await storage.write(key: expiresAt, value: data['expires_at']);

      ref.read(authProvider.notifier).setAuthData(
            AuthUser(
              userId: data['user']['userId'],
              email: data['user']['email'],
              countryCode: data['user']['countryCode'],
              fullName: data['user']['fullName'],
              phoneNumber: data['user']['phoneNumber'],
              username: data['user']['username'],
              profilePicture: data['user']['profilePicture'],
              followers: data['user']['followers'],
              following: data['user']['following'],
              accessToken: data['access_token'],
              expiresAt: data['expires_at'],
              refreshToken: data['refresh_token'],
            ),
          );
      if (context.mounted) {
        context.go(
          '/posts',
        );
      }

      Timer.periodic(const Duration(milliseconds: 350), (timer) {
        timer.cancel();
        return FlutterNativeSplash.remove();
      });
    } on DioException catch (_) {
      context.go('/auth/signin');
      Timer.periodic(
        const Duration(
          milliseconds: 350,
        ),
        (timer) {
          timer.cancel();
          return FlutterNativeSplash.remove();
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
