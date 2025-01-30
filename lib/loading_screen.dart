import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'features/home/presentation/home.dart';
import 'helpers/di.dart';
import 'helpers/helper_methods.dart';
import 'helpers/post_login.dart';
import 'networks/dio/dio.dart';

final class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool _isLoading = true;
  bool isFirstTime = true;

  @override
  void initState() {
    loadInitialData();

    super.initState();
  }

  loadInitialData() async {
    //AutoAppUpdateUtil.instance.checkAppUpdate();
    await setInitValue();

    if (appData.read(kKeyIsLoggedIn)) {
      String token = appData.read(kKeyAccessToken);
      DioSingleton.instance.update(token);
      performPostLoginActions();
    } else {
      //  NotificationService().cancelAllNotifications();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return HomeScreen();
    } else {
      return appData.read(kKeyIsLoggedIn)
          ? HomeScreen()
          : appData.read(kKeyfirstTime)
              ? HomeScreen()
              : HomeScreen();
    }
  }
}
