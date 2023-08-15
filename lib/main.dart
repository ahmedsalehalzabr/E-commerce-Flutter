// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:country_code_picker/country_localizations.dart';
import 'package:numo/Helper/Color.dart';

import 'package:numo/Helper/Constant.dart';
import 'package:numo/Provider/CartProvider.dart';
import 'package:numo/Provider/CategoryProvider.dart';
import 'package:numo/Provider/FavoriteProvider.dart';
import 'package:numo/Provider/HomeProvider.dart';
import 'package:numo/Provider/ProductDetailProvider.dart';

import 'package:numo/Provider/UserProvider.dart';

import 'package:numo/Screen/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Helper/Demo_Localization.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

import 'Provider/Theme.dart';
import 'Provider/SettingProvider.dart';
import 'Provider/order_provider.dart';
import 'Screen/Dashboard.dart';
import 'Screen/Login.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessageKey =
    GlobalKey<ScaffoldMessengerState>();

  Locale? _locale;


void main() async {
  log('Main 1111 ');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializedDownload();
  HttpOverrides.global = MyHttpOverrides();
  FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
  log('Main 222 ');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // debugPrint('=========================prefs.toString()=============');
  // for (var element in prefs.getKeys()) {
  //   try {
  //     // ignore: prefer_interpolation_to_compose_strings
  //     log('main prefs.getKeys()  $element  = ' + prefs.getString(element.toString())!);
  //     // debugPrint(prefs.getString(element.toString()));
  //   } catch (_) {
  //     debugPrint('error on for loop =');
  //     debugPrint(_.toString());
  //   }
  // }
  // debugPrint('-----------------------prefs.toString------------------- ');

  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (BuildContext context) {
        String? theme = prefs.getString(APP_THEME);
        log('Main 3333 runApp');

        if (theme == DARK) {
          ISDARK = "true";
        } else if (theme == LIGHT) {
          ISDARK = "false";
        }

        if (theme == null || theme == "" || theme == DEFAULT_SYSTEM) {
          log('Main 4444 ');

          prefs.setString(APP_THEME, DEFAULT_SYSTEM);
          var brightness = SchedulerBinding.instance.window.platformBrightness;
          ISDARK = (brightness == Brightness.dark).toString();

          return ThemeNotifier(ThemeMode.system);
        }

        return ThemeNotifier(theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
      },
      child: MyApp(sharedPreferences: prefs),
    ),
  );
}

Future<void> initializedDownload() async {
  log('Main initializedDownload ');

  await FlutterDownloader.initialize(debug: true); //it wase false
}

class MyApp extends StatefulWidget {
  late SharedPreferences sharedPreferences;

  MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    log('Main 5555 setLocale');

    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  setLocale(Locale locale) {
    log('Main  setLocale');

    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      log('Main didChangeDependencies ');

      if (mounted) {
        setState(() {
          _locale = locale;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    log('Main Widget build 1 ');

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (_locale == null) {
      log('Main Widget build 2 _locale == null');

      return const Center(
        child: CircularProgressIndicator(
            color: colors.primary,
            valueColor: AlwaysStoppedAnimation<Color?>(colors.primary)),
      );
    } else {
      log('Main Widget build 3 else MultiProvider ');

      return MultiProvider(
          providers: [
            Provider<SettingProvider>(
              create: (context) => SettingProvider(widget.sharedPreferences),
            ),
            ChangeNotifierProvider<UserProvider>(
                create: (context) => UserProvider()),
            ChangeNotifierProvider<HomeProvider>(
                create: (context) => HomeProvider()),
            ChangeNotifierProvider<CategoryProvider>(
                create: (context) => CategoryProvider()),
            ChangeNotifierProvider<ProductDetailProvider>(
                create: (context) => ProductDetailProvider()),
            ChangeNotifierProvider<FavoriteProvider>(
                create: (context) => FavoriteProvider()),
            ChangeNotifierProvider<OrderProvider>(
                create: (context) => OrderProvider()),
            ChangeNotifierProvider<CartProvider>(
                create: (context) => CartProvider()),
          ],
          child: MaterialApp(
            locale: _locale,
            scaffoldMessengerKey: scaffoldMessageKey,
            supportedLocales: const [
              Locale("en", "US"),
              Locale("zh", "CN"),
              Locale("es", "ES"),
              Locale("hi", "IN"),
              Locale("ar", "DZ"),
              Locale("ru", "RU"),
              Locale("ja", "JP"),
              Locale("de", "DE")
            ],
            localizationsDelegates: const [
              CountryLocalizations.delegate,
              DemoLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale!.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            title: appName,
            theme: ThemeData(
              canvasColor: Theme.of(context).colorScheme.lightWhite,
              cardColor: colors.cardColor,
              dialogBackgroundColor: Theme.of(context).colorScheme.white,
              iconTheme:
                  Theme.of(context).iconTheme.copyWith(color: colors.primary),
              primarySwatch: colors.primary_app,
              primaryColor: Theme.of(context).colorScheme.lightWhite,
              fontFamily: 'OpenSans',
              colorScheme:
                  ColorScheme.fromSwatch(primarySwatch: colors.primary_app)
                      .copyWith(
                          secondary: colors.secondary,
                          brightness: Brightness.light),
              textTheme: TextTheme(
                      headline6: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle1: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold))
                  .apply(bodyColor: Theme.of(context).colorScheme.fontColor),
            ),
            debugShowCheckedModeBanner: true, //should be false i changed ansi
            initialRoute: '/',
            routes: {
              '/': (context) => const Splash(),
              '/home': (context) => const Dashboard(),
              '/login': (context) => const Login(),
            },
            darkTheme: ThemeData(
              canvasColor: colors.darkColor,
              cardColor: colors.darkColor2,
              dialogBackgroundColor: colors.darkColor2,
              primaryColor: colors.darkColor,
              textSelectionTheme: TextSelectionThemeData(
                  cursorColor: colors.darkIcon,
                  selectionColor: colors.darkIcon,
                  selectionHandleColor: colors.darkIcon),
              toggleableActiveColor: colors.primary,
              fontFamily: 'OpenSans',
              //brightness: Brightness.dark,
              iconTheme:
                  Theme.of(context).iconTheme.copyWith(color: colors.primary),
              textTheme: TextTheme(
                      headline6: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle1: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold))
                  .apply(bodyColor: Theme.of(context).colorScheme.fontColor),
              colorScheme:
                  ColorScheme.fromSwatch(primarySwatch: colors.primary_app)
                      .copyWith(
                          secondary: colors.darkIcon,
                          brightness: Brightness.dark),
            ),
            themeMode: themeNotifier.getThemeMode(),
          ));
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    log('Main MyHttpOverrides ');
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
