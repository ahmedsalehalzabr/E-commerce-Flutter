import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
// import 'dart:html';

import 'package:flutter/services.dart';
import 'package:numo/Helper/Color.dart';
import 'package:numo/Helper/PushNotificationService.dart';
import 'package:numo/Helper/Session.dart';
import 'package:numo/Helper/SqliteData.dart';
import 'package:numo/Helper/String.dart';
import 'package:numo/Model/Section_Model.dart';
import 'package:numo/Provider/HomeProvider.dart';
import 'package:numo/Provider/UserProvider.dart';
import 'package:numo/Screen/Cart.dart';
import 'package:numo/Screen/Favorite.dart';
import 'package:numo/Screen/Login.dart';
import 'package:numo/Screen/MyProfile.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:bottom_bar/bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:device_info_plus/device_info_plus.dart';

import '../Provider/SettingProvider.dart';
import 'All_Category.dart';

import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Product_Detail.dart';
import 'Sale.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard> with SingleTickerProviderStateMixin {
  int _selBottom = 0;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  final PageController _pageController = PageController();
  bool _isNetworkAvail = true;
  var db = DatabaseHelper();
  late AnimationController navigationContainerAnimationController = AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin
    duration: const Duration(milliseconds: 500),
  );
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    log('Dashboard initState');
    initDynamicLinks();
    // initPlatformState();

    db.getTotalCartCount(context);
    final pushNotificationService = PushNotificationService(context: context, pageController: _pageController);
    pushNotificationService.initialise();

    Future.delayed(Duration.zero, () async {
      SettingProvider settingsProvider = Provider.of<SettingProvider>(context, listen: false);
      CUR_MERCHANTID = await settingsProvider.getPrefrence(MERCHANT_ID);
      CUR_MERCHANTUSERID = await settingsProvider.getPrefrence(MERCHANTUSER_ID);
      CUR_TOKEN = await settingsProvider.getPrefrence(ACCESS_TOKEN);

      IS_LOGGINED = CUR_MERCHANTID != null || CUR_MERCHANTUSERID != null ? true : false;
      if (IS_LOGGINED) {
        try {
          var parameter = {
            MERCHANTUSER_ID: CUR_MERCHANTUSERID,
          };

          final deviceInfoPlugin = DeviceInfoPlugin();
          final deviceInfo = await deviceInfoPlugin.deviceInfo;
          final map = deviceInfo.toMap();

          log('Dashboard initState deviceinfo map=$map');

          // apiBaseHelper.postNumoAPICall(postNumoMerchantSessionApi, parameter).then((getdata) {
          //   var data = getdata;

          //   Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const Login()));
          // }, onError: (error) {
          //   setSnackbar(error.toString(), context);
          // });

        } catch (e) {
          log('Dashboard initState error=$e');
        }
      }
      log('DashBoard CUR_MERCHANTID = $CUR_MERCHANTID');
      log('DashBoard CUR_MERCHANTUSERID = $CUR_MERCHANTUSERID');
      log('DashBoard CUR_TOKEN = $CUR_TOKEN');

      context.read<HomeProvider>().setAnimationController(navigationContainerAnimationController);
    });
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        // // deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        // // deviceData = (await deviceInfoPlugin.androidInfo) as Map<String, dynamic>;
        // final deviceInfo = await deviceInfoPlugin.deviceInfo;
        // final map = deviceInfo.toString();

        // log('Dashboard initState deviceinfo json.decode(map)=${json.encode(map)}');
      }
    } on PlatformException {
      deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      DEVICE_OS: build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      DEVICE_BRAND: build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      DEVICE_SN: build.id,
      'manufacturer': build.manufacturer,
      DEVICE_MODEL: build.model,
      'product': build.product,
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selBottom != 0) {
          _pageController.animateToPage(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        appBar: _getAppBar(),
        body: PageView(
          controller: _pageController,
          children: const [
            HomePage(),
            AllCategory(),
            Sale(),
            Cart(
              fromBottom: true,
            ),
            MyProfile()
          ],
          onPageChanged: (index) {
            setState(() {
              if (!context.read<HomeProvider>().animationController.isAnimating) {
                context.read<HomeProvider>().animationController.reverse();
                context.read<HomeProvider>().showBars(true);
              }
              _selBottom = index;
              if (index == 3) {
                cartTotalClear();
              }
            });
          },
        ),
        bottomNavigationBar: _getBottomBar(),
      ),
    );
  }

  void initDynamicLinks() async {
    log('Dashboard initDynamicLinks');
    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri deepLink = dynamicLinkData.link;
      log('deeplink = $deepLink');
      log('deepLink.queryParameters.toString() = ${deepLink.queryParameters.toString()}');

      if (deepLink.queryParameters.isNotEmpty) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        String? list = deepLink.queryParameters['list'];
        log('deepLink.queryParameters.toString() = ${deepLink.queryParameters.toString()}');
        getProduct(id!, index, secPos, list == "true" ? true : false);
      }
    }).onError((e) {
      log(e.message);
    });

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.isNotEmpty) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        getProduct(id!, index, secPos, true);
      }
    }
  }

  Future<void> getProduct(String product_id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: product_id,
        };

        apiBaseHelper.getNumoAPICall(getNumoProductsApi, parameter, null).then((getdata) {
          // bool error = getdata["error"];
          // String msg = getdata["message"];
          // if (!error) {
          var data = getdata;

          List<Product> items = [];

          items = (data as List).map((data) => Product.fromJson(data)).toList();

          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => ProductDetail(
                    index: list ? int.parse(product_id) : index,
                    model: list ? items[0] : sectionList[secPos].productList![index],
                    secPos: secPos,
                    list: list,
                  )));
          // } else {
          //   if (msg != "Products Not Found !") setSnackbar(msg, context);
          // }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });

        // apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
        //   bool error = getdata["error"];
        //   String msg = getdata["message"];
        //   if (!error) {
        //     var data = getdata["data"];
        //     List<Product> items = [];
        //     items = (data as List).map((data) => Product.fromJson(data)).toList();
        //     Navigator.of(context).push(CupertinoPageRoute(
        //         builder: (context) => ProductDetail(
        //               index: list ? int.parse(id) : index,
        //               model: list ? items[0] : sectionList[secPos].productList![index],
        //               secPos: secPos,
        //               list: list,
        //             )));
        //   } else {
        //     if (msg != "Products Not Found !") setSnackbar(msg, context);
        //   }
        // }, onError: (error) {
        //   setSnackbar(error.toString(), context);
        // });

      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted) {
          setState(() {
            setSnackbar(getTranslated(context, 'NO_INTERNET_DISC')!, context);
          });
        }
      }
    }
  }

  AppBar _getAppBar() {
    String? title;
    if (_selBottom == 1) {
      title = getTranslated(context, 'CATEGORY');
    } else if (_selBottom == 2) {
      title = getTranslated(context, 'OFFER');
    } else if (_selBottom == 3) {
      // title = getTranslated(context, 'MYBAG');
      title = getTranslated(context, 'CART');
    } else if (_selBottom == 4) {
      title = getTranslated(context, 'PROFILE');
    }
    String languageCode = 'ar';
    SharedPreferences.getInstance().then((value) => {languageCode = value.getString(LAGUAGE_CODE) ?? "ar"});

    log('languageCode = $languageCode');

    return AppBar(
      elevation: 0,
      centerTitle: false,
      title: _selBottom == 0
          ? languageCode == 'ar'
              ? SvgPicture.asset(
                  'assets/images/titleicon-ar.svg',
                  height: 45,
                  // color: colors.primary,
                )
              : SvgPicture.asset(
                  'assets/images/titleicon.svg',
                  height: 45,
                  // color: colors.primary,
                )
          : Text(
              title!,
              style: const TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
            ),
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/desel_notification.svg",
            color: colors.primary,
          ),
          onPressed: () {
            CUR_MERCHANTID != null
                ? Navigator.push<bool>(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const NotificationList(),
                    )).then((value) {
                    if (value != null && value) {
                      _pageController.jumpToPage(1);
                    }
                  })
                : Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const Login(),
                    ));
          },
        ),
        IconButton(
          padding: const EdgeInsets.all(0),
          icon: SvgPicture.asset(
            "assets/images/desel_fav.svg",
            color: colors.primary,
          ),
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const Favorite(),
                ));
          },
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
    );
  }

  Widget _getBottomBar() {
    return FadeTransition(
        opacity:
            Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: navigationContainerAnimationController, curve: Curves.easeInOut)),
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0))
              .animate(CurvedAnimation(parent: navigationContainerAnimationController, curve: Curves.easeInOut)),
          child: Container(
            height: kBottomNavigationBarHeight,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: BottomBar(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              selectedIndex: _selBottom,
              onTap: (int index) {
                _pageController.jumpToPage(index);
                setState(() => _selBottom = index);
              },
              items: <BottomBarItem>[
                BottomBarItem(
                  icon: _selBottom == 0
                      ? SvgPicture.asset(
                          "assets/images/sel_home.svg",
                          color: colors.primary,
                        )
                      : SvgPicture.asset(
                          "assets/images/desel_home.svg",
                          color: colors.primary,
                        ),
                  title: Text(getTranslated(context, 'HOME_LBL')!),
                  activeColor: colors.primary,
                ),
                BottomBarItem(
                    icon: _selBottom == 1
                        ? SvgPicture.asset(
                            "assets/images/category01.svg",
                            color: colors.primary,
                          )
                        : SvgPicture.asset(
                            "assets/images/category.svg",
                            color: colors.primary,
                          ),
                    title: Text(getTranslated(context, 'category')!),
                    activeColor: colors.primary),
                BottomBarItem(
                  icon: _selBottom == 2
                      ? SvgPicture.asset(
                          "assets/images/sale02.svg",
                          color: colors.primary,
                        )
                      : SvgPicture.asset(
                          "assets/images/sale.svg",
                          color: colors.primary,
                        ),
                  title: Text(getTranslated(context, 'SALE')!),
                  activeColor: colors.primary,
                ),
                BottomBarItem(
                  icon: Selector<UserProvider, String>(
                    builder: (context, data, child) {
                      return Stack(
                        children: [
                          _selBottom == 3
                              ? SvgPicture.asset(
                                  "assets/images/cart01.svg",
                                  color: colors.primary,
                                )
                              : SvgPicture.asset(
                                  "assets/images/cart.svg",
                                  color: colors.primary,
                                ),
                          (data.isNotEmpty && data != "0")
                              ? Positioned.directional(
                                  end: 0,
                                  textDirection: Directionality.of(context),
                                  top: 0,
                                  child: Container(
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: colors.primary),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: Text(
                                            data,
                                            style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.white),
                                          ),
                                        ),
                                      )),
                                )
                              : Container()
                        ],
                      );
                    },
                    selector: (_, homeProvider) => homeProvider.curCartCount,
                  ),
                  title: Text(getTranslated(context, 'CART')!),
                  activeColor: colors.primary,
                ),
                BottomBarItem(
                  icon: _selBottom == 4
                      ? SvgPicture.asset(
                          "assets/images/profile01.svg",
                          color: colors.primary,
                        )
                      : SvgPicture.asset(
                          "assets/images/profile.svg",
                          color: colors.primary,
                        ),
                  title: const Text('Profile'),
                  activeColor: colors.primary,
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
