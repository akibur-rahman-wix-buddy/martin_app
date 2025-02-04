import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:martin_app/features/home/presentation/home.dart';
import 'package:martin_app/features/lock_notes/presentation/lock_notes.dart';
import 'package:martin_app/features/recycle_bin/presentation/recycle_bin.dart';
import 'package:martin_app/features/starred/presentation/starred_screen.dart';

final class Routes {
  static final Routes _routes = Routes._internal();
  Routes._internal();
  static Routes get instance => _routes;

  static const String recycleBinScreen = '/recycle_bin_screen';
  static const String homeScreen = '/home_screen';
  static const String starredScreen = '/starred_screen';
  static const String lockNotesScreen = '/lock_notes_screen';
}

final class RouteGenerator {
  static final RouteGenerator _routeGenerator = RouteGenerator._internal();
  RouteGenerator._internal();
  static RouteGenerator get instance => _routeGenerator;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.recycleBinScreen:
        return Platform.isAndroid
            ? _FadedTransitionRoute(
                widget: RecycleBinScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => RecycleBinScreen());

      case Routes.homeScreen:
        return Platform.isAndroid
            ? _FadedTransitionRoute(widget: HomeScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => HomeScreen());

      case Routes.starredScreen:
        return Platform.isAndroid
            ? _FadedTransitionRoute(
                widget: StarredNotesScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => StarredNotesScreen());

      case Routes.lockNotesScreen:
        return Platform.isAndroid
            ? _FadedTransitionRoute(
                widget: LockNotesScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => LockNotesScreen());

      // // case Routes.categorySearchScreen:
      // //   return Platform.isAndroid
      // //       ? _FadedTransitionRoute(
      // //           widget: const CategoryScreen(), settings: settings)
      // //       : CupertinoPageRoute(builder: (context) => const CategoryScreen());
      // case Routes.pricingPlanScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const PricingPlanScreen(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const PricingPlanScreen());
      // case Routes.dailyRemainder:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const SetRemainderScreen(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const SetRemainderScreen());
      // case Routes.pricingListScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const PricingListScreen(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const PricingListScreen());
      // case Routes.makeMixScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const MakeMixScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const MakeMixScreen());
      // case Routes.homeScreenWidget:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const HomeScreenWidget(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const HomeScreenWidget());
      // case Routes.navigationScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const NavigationScreen(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const NavigationScreen());
      // case Routes.homeScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const HomeScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const HomeScreen());
      // case Routes.theme:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const ThemeScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const ThemeScreen());
      // case Routes.setting:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const SettingsScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const SettingsScreen());
      // case Routes.generalSetting:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const GeneralSettingScreen(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const GeneralSettingScreen());
      // case Routes.contentCategories:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const ContentCategoriesScreen(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const ContentCategoriesScreen());
      // case Routes.reminderScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const RemindersScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const RemindersScreen());
      // case Routes.setPassword:
      //   final args = settings.arguments as Map;
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: SetPasswordScreen(
      //             name: args['name'],
      //             email: args['email'],
      //           ),
      //           settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => SetPasswordScreen(
      //                 name: args['name'],
      //                 email: args['email'],
      //               ));
      // case Routes.otpScreen:
      //   final args = settings.arguments as Map;
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: OtpScreen(
      //             isFromLogin: args['isFromLogin'],
      //           ),
      //           settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => OtpScreen(
      //                 isFromLogin: args['isFromLogin'],
      //               ));
      // case Routes.addQuoteScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const AddQuoteScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const AddQuoteScreen());
      // case Routes.quoteScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const QuoteScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const QuoteScreen());
      // case Routes.collectionScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const CollectionScreen(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const CollectionScreen());
      // case Routes.favouriteScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const FavouriteScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const FavouriteScreen());
      // case Routes.previewScreen:
      //   final args = settings.arguments as Map;
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: PreviewScreen(quote: args['quote'], name: args['name']),
      //           settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) =>
      //               PreviewScreen(quote: args['quote'], name: args['name']));
      // case Routes.setNewPasswordScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: SetNewPasswordScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => SetNewPasswordScreen());
      // // case Routes.previewScreen:
      // //   return Platform.isAndroid
      // //       ? _FadedTransitionRoute(widget: PreviewScreen(), settings: settings)
      // //       : CupertinoPageRoute(builder: (context) => PreviewScreen());
      // case Routes.insertEmailScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: InsertEmailScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => InsertEmailScreen());
      // case Routes.logInScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const LoginScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const LoginScreen());

      // case Routes.verifyOtpFPScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const VerifyOtpFPScreen(), settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => const VerifyOtpFPScreen());
      // case Routes.loadingScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(widget: const Loading(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const Loading());

      // case Routes.editRemainder:
      //   final args = settings.arguments as Map;
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: EditRemainderScreen(
      //             id: args['id'],
      //             itemCount: args['itemCount'],
      //             startTime: args['startTime'],
      //             endTime: args['endTime'],
      //             isRemaiderOn: args['isRemaiderOn'],
      //           ),
      //           settings: settings)
      //       : CupertinoPageRoute(
      //           builder: (context) => EditRemainderScreen(
      //                 id: args['id'],
      //                 itemCount: args['itemCount'],
      //                 startTime: args['startTime'],
      //                 endTime: args['endTime'],
      //                 isRemaiderOn: args['isRemaiderOn'],
      //               ));
      // case Routes.signUpScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const SignUpScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const SignUpScreen());
      // case Routes.forgotPWScreen:
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget: const ForgotPWScreen(), settings: settings)
      //       : CupertinoPageRoute(builder: (context) => const ForgotPWScreen());

      // case Routes.sliderWebViewPage:
      //   final args = settings.arguments as Map;
      //   return Platform.isAndroid
      //       ? _FadedTransitionRoute(
      //           widget:
      //               SliderWebViewPage(title: args["title"], url: args["url"]),
      //           settings:
      //               settings) //_FadedTransitionRoute(builder: (context)=> const SobrenosScreen())
      //       : CupertinoPageRoute(
      //           builder: (context) =>
      //               SliderWebViewPage(title: args["title"], url: args["url"]));

      default:
        return null;
    }
  }
}

//  weenAnimationBuilder(
//   child: Widget,
//   tween: Tween<double>(begin: 0, end: 1),
//   duration: Duration(milliseconds: 1000),
//   curve: Curves.bounceIn,
//   builder: (BuildContext context, double _val, Widget child) {
//     return Opacity(
//       opacity: _val,
//       child: Padding(
//         padding: EdgeInsets.only(top: _val * 50),
//         child: child
//       ),
//     );
//   },
// );

class _FadedTransitionRoute extends PageRouteBuilder {
  final Widget widget;
  @override
  final RouteSettings settings;

  _FadedTransitionRoute({required this.widget, required this.settings})
      : super(
          settings: settings,
          reverseTransitionDuration: const Duration(milliseconds: 1),
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionDuration: const Duration(milliseconds: 1),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.ease,
              ),
              child: child,
            );
          },
        );
}

class ScreenTitle extends StatelessWidget {
  final Widget widget;

  const ScreenTitle({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: .5, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: widget,
    );
  }
}
