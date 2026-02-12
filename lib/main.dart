import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'common/network/dio_client.dart';
import 'common/router/my_router.dart';
import 'common/storage/token_storage.dart';
import 'data/login/api.dart';
import 'data/login/repo_impl.dart';
import 'data/register/api.dart';
import 'data/register/repo_impl.dart';
import 'data/tracking/api.dart';
import 'data/tracking/local /app_db.dart';
import 'data/tracking/repo_impl.dart';
import 'features/activity/cubit/activity_cubit.dart';
import 'features/login/cubit/login_cubit.dart';
import 'features/register/cubit/register_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = TokenStorage();
  final dio = DioClient(storage).dio;

  // ✅ Floor DB build
  final db = await $FloorAppDatabase
      .databaseBuilder('app.db')
      .build();

  final loginRepo = LoginRepoImpl(api: LoginApi(dio), storage: storage);
  final registerRepo = RegisterRepoImpl(api: RegisterApi(dio));

  // ✅ sessionDao berildi
  final trackingRepo = TrackingRepoImpl(
    api: TrackingApi(dio),
    sessionDao: db.sessionDao,
  );

  runApp(
    MyApp(
      loginRepo: loginRepo,
      registerRepo: registerRepo,
      trackingRepo: trackingRepo,
    ),
  );
}

class MyApp extends StatelessWidget {
  final LoginRepoImpl loginRepo;
  final RegisterRepoImpl registerRepo;
  final TrackingRepoImpl trackingRepo;

  const MyApp({
    super.key,
    required this.loginRepo,
    required this.registerRepo,
    required this.trackingRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LoginRepoImpl>.value(value: loginRepo),
        RepositoryProvider<RegisterRepoImpl>.value(value: registerRepo),
        RepositoryProvider<TrackingRepoImpl>.value(value: trackingRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LoginCubit(loginRepo)),
          BlocProvider(create: (_) => RegisterCubit(registerRepo)),
          BlocProvider(create: (_) => ActivityCubit(trackingRepo)),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: Routing.router,
        ),
      ),
    );
  }
}
