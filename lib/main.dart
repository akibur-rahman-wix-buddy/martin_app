// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:auto_animated/auto_animated.dart';
// import 'constants/custome_theme.dart';
// import 'gen/colors.gen.dart';
// import 'helpers/all_routes.dart';
// import 'helpers/di.dart';
// import 'helpers/helper_methods.dart';
// import 'helpers/navigation_service.dart';
// import 'loading_screen.dart';
// import 'networks/dio/dio.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   //await _requestPermissions();
//   await GetStorage.init();
//   diSetup();
//   // initiInternetChecker();

//   DioSingleton.instance.create();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     rotation();
//     setInitValue();
//     return AnimateIfVisibleWrapper(
//       showItemInterval: const Duration(milliseconds: 150),
//       child: PopScope(
//         canPop: false,
//         onPopInvoked: (bool didPop) async {
//           showMaterialDialog(context);
//         },
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return const UtillScreenMobile();
//           },
//         ),
//       ),
//     );
//   }
// }

// class UtillScreenMobile extends StatelessWidget {
//   const UtillScreenMobile({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (_, child) {
//         return PopScope(
//           canPop: false,
//           onPopInvokedWithResult: (bool didPop, _) async {
//             showMaterialDialog(context);
//           },
//           child: GetMaterialApp(
//               color: AppColors.allPrimaryColor,
//               //    showPerformanceOverlay: true,
//               theme: ThemeData(
//                   unselectedWidgetColor: Colors.white,
//                   primarySwatch: CustomTheme.kToDark,
//                   useMaterial3: false,
//                   scaffoldBackgroundColor: AppColors.allPrimaryColor,
//                   appBarTheme: const AppBarTheme(
//                       color: AppColors.allPrimaryColor, elevation: 0)),
//               debugShowCheckedModeBanner: false,
//               builder: (context, widget) {
//                 return MediaQuery(data: MediaQuery.of(context), child: widget!);
//               },
//               navigatorKey: NavigationService.navigatorKey,
//               onGenerateRoute: RouteGenerator.generateRoute,
//               home: Loading()),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:auto_animated/auto_animated.dart';

import 'constants/custome_theme.dart';
import 'features/theme_controller/theme_controller.dart';
import 'gen/colors.gen.dart';
import 'helpers/all_routes.dart';
import 'helpers/di.dart';
import 'helpers/helper_methods.dart';
import 'helpers/navigation_service.dart';
import 'loading_screen.dart';
import 'networks/dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Initialize GetStorage for theme persistence
  diSetup();
  DioSingleton.instance.create();

  // Initialize ThemeController
  final ThemeController themeController = Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    rotation();
    setInitValue();

    return AnimateIfVisibleWrapper(
      showItemInterval: const Duration(milliseconds: 150),
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          showMaterialDialog(context);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return const UtillScreenMobile();
          },
        ),
      ),
    );
  }
}

class UtillScreenMobile extends StatelessWidget {
  const UtillScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Obx(() => GetMaterialApp(
              color: AppColors.allPrimaryColor,
              theme: ThemeData(
                brightness: Brightness.light, // Light Mode
                primarySwatch: CustomTheme.kToDark,
                scaffoldBackgroundColor: Color(0xFFF5F5F5), // Light background
                appBarTheme: const AppBarTheme(
                  color: Colors.white,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.black),
                ),
                textTheme: TextTheme(
                    // bodyText1: TextStyle(color: Colors.black),
                    // bodyText2: TextStyle(color: Colors.black87),
                    // headline6: TextStyle(color: Colors.black),
                    ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                      // primary: Colors.blue, // Button Color for Light Mode
                      // onPrimary: Colors.white, // Text color
                      ),
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark, // Dark Mode
                // primarySwatch: Colors.blueAccent,
                scaffoldBackgroundColor: Color(0xFF121212), // Dark background
                appBarTheme: const AppBarTheme(
                  color: Color.fromARGB(255, 14, 13, 13),
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.white),
                ),
                textTheme: TextTheme(
                    // bodyText1: TextStyle(color: Colors.white),
                    // bodyText2: TextStyle(color: Colors.white70),
                    // headline6: TextStyle(color: Colors.white),
                    ),
              ),
              themeMode: themeController.isDarkMode.value
                  ? ThemeMode.dark
                  : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              builder: (context, widget) {
                return MediaQuery(data: MediaQuery.of(context), child: widget!);
              },
              navigatorKey: NavigationService.navigatorKey,
              onGenerateRoute: RouteGenerator.generateRoute,
              home: Loading(),
            ));
      },
    );
  }
}
