import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/data/user_model.dart';
import 'package:api_task/app/lang/app_translations.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:api_task/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox('auth');

  Get.put(AuthService());
  Get.put(ApiServices());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      translations: AppTranslations(),

      locale: const Locale('en'),

      title: "Application",
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "Cairo",
        appBarTheme: AppBarThemeData(
          iconTheme: IconThemeData(color: Colors.white),

          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF71B24D),
            elevation: 0,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
