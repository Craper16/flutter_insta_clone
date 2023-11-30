import 'package:flutter/cupertino.dart';
import 'package:flutter_insta/screens/auth/forgot_password_screen.dart';
import 'package:flutter_insta/screens/auth/reset_password_screen.dart';
import 'package:flutter_insta/screens/auth/signin_screen.dart';
import 'package:flutter_insta/screens/auth/signup_screen.dart';
import 'package:flutter_insta/screens/auth/verify_email_screen.dart';
import 'package:flutter_insta/screens/home/home_screen.dart';
import 'package:flutter_insta/screens/likes/post_or_comment_likes_screen.dart';
import 'package:flutter_insta/screens/notifications/notifications_screen.dart';
import 'package:flutter_insta/screens/posts/post_details_screen.dart';
import 'package:flutter_insta/screens/search/search_screen.dart';
import 'package:flutter_insta/screens/splash_screen.dart';
import 'package:flutter_insta/screens/tabs/tabs_screen.dart';
import 'package:flutter_insta/screens/user/user_profile_screen.dart';
import 'package:flutter_insta/screens/users/users_followers_or_following_screen.dart';
import 'package:flutter_insta/screens/users/users_profile_screen.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');
final _shellNavigatorDKey = GlobalKey<NavigatorState>(debugLabel: 'shellD');
final _shellNavigatorEKey = GlobalKey<NavigatorState>(debugLabel: 'shellE');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => TabsScreen(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey,
          routes: [
            GoRoute(
              path: '/posts',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/post/:postId',
              builder: (context, state) => PostDetailsScreen(
                postId: state.pathParameters['postId'],
                userFullName: state.queryParameters['user'],
              ),
            ),
            GoRoute(
              path: '/notifications/:userId',
              builder: (context, state) => NotificationsScreen(
                userId: state.pathParameters['userId'],
              ),
            ),
            GoRoute(
              path: '/likes',
              builder: (context, state) => PostOrCommentsScreen(
                commentId: state.queryParameters['comment'],
                postId: state.queryParameters['post'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorCKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/user/:userId',
              builder: (context, state) => UsersProfileScreen(
                username: state.queryParameters['username']!,
                userId: state.pathParameters['userId']!,
              ),
            ),
            GoRoute(
              path: '/user/followers-and-following/:userId',
              builder: (context, state) => UsersFollowersOrFollowingScreen(
                userId: state.pathParameters['userId'],
                type: state.queryParameters['type'],
              ),
            ),
            GoRoute(
              path: '/post/:postId',
              builder: (context, state) => PostDetailsScreen(
                postId: state.pathParameters['postId'],
                userFullName: state.queryParameters['user'],
              ),
            ),
            GoRoute(
              path: '/likes',
              builder: (context, state) => PostOrCommentsScreen(
                commentId: state.queryParameters['comment'],
                postId: state.queryParameters['post'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorEKey,
          routes: [
            GoRoute(
              path: '/posts',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/post/:postId',
              builder: (context, state) => PostDetailsScreen(
                postId: state.pathParameters['postId'],
                userFullName: state.queryParameters['user'],
              ),
            ),
            GoRoute(
              path: '/likes',
              builder: (context, state) => PostOrCommentsScreen(
                commentId: state.queryParameters['comment'],
                postId: state.queryParameters['post'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDKey,
          routes: [
            GoRoute(
              path: '/reels',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/post/:postId',
              builder: (context, state) => PostDetailsScreen(
                postId: state.pathParameters['postId'],
                userFullName: state.queryParameters['user'],
              ),
            ),
            GoRoute(
              path: '/likes',
              builder: (context, state) => PostOrCommentsScreen(
                commentId: state.queryParameters['comment'],
                postId: state.queryParameters['post'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const UserProfileScreen(),
            ),
            GoRoute(
              path: '/user/followers-and-following/:userId',
              builder: (context, state) => UsersFollowersOrFollowingScreen(
                userId: state.pathParameters['userId'],
                type: state.queryParameters['type'],
              ),
            ),
            GoRoute(
              path: '/user/:userId',
              builder: (context, state) => UsersProfileScreen(
                username: state.queryParameters['username']!,
                userId: state.pathParameters['userId']!,
              ),
            ),
            GoRoute(
              path: '/post/:postId',
              builder: (context, state) => PostDetailsScreen(
                postId: state.pathParameters['postId'],
                userFullName: state.queryParameters['user'],
              ),
            ),
            GoRoute(
              path: '/likes',
              builder: (context, state) => PostOrCommentsScreen(
                commentId: state.queryParameters['comment'],
                postId: state.queryParameters['post'],
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth/signin',
      builder: (context, state) => const SigninScreen(),
    ),
    GoRoute(
      path: '/auth/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/verify-email',
      builder: (context, state) => VerifyEmailScreen(
        email: state.queryParameters['email'] ?? '',
        login: state.queryParameters['login'],
      ),
    ),
    GoRoute(
      path: '/auth/reset-password',
      builder: (context, state) => ResetPasswordScreen(
        verificationCode: state.queryParameters['code']!,
        email: state.queryParameters['email']!,
      ),
    ),
  ],
);
