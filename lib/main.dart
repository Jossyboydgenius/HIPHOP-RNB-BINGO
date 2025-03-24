import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'themes/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/navigation_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/balance/balance_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    BlocProvider(
      create: (context) => BalanceBloc(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp with ScreenUtilInit
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iOS design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'HIPHOP & RNB BINGO',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.routes,
        );
      }
    );
  }
}
