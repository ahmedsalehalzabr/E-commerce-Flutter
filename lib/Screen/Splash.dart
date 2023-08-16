import 'dart:async';
import 'dart:developer';
import 'package:numo/Provider/SettingProvider.dart';
import 'package:numo/Screen/Intro_Slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/String.dart';
import 'package:flutter_svg/flutter_svg.dart';

//splash screen of app
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            color: colors.white30,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/splashlogo.svg',
                  // color: colors.primary,
                  height:deviceHeight!  * 0.2 ,
                  clipBehavior :Clip.antiAlias,
              ),
            ),
          ),
          Image.asset(
            'assets/images/doodle.png',

            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }

  startTime() async {
    log('Splash startTime ');
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  Future<void> navigationPage() async {
    log('Spalsh navigationPage');
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);

    log('Spalsh $isFirstTime');

    if (isFirstTime) {
      log('Spalsh isFirstTime= True');

      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      log('Spalsh isFirstTime= False');

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const IntroSlider(),
          ));
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }
}
