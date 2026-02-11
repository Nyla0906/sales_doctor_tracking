import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';
import '../../features/login/login.dart';
import '../../features/register/register.dart';
import '../../features/main/main_shell.dart';
import '../../features/activity/activity_page.dart';
import '../../features/profile/profile_page.dart';

class Routing {
  static final _rootKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(path: '/', redirect: (_, __) => AppRoutes.login),

      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterPage(),
      ),


      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.activity,
            builder: (_, __) => const ActivityPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
    ],
    debugLogDiagnostics: true,
  );
}
