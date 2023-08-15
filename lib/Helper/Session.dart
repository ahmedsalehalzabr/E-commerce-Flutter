import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:connectivity/connectivity.dart';
import 'package:numo/Provider/HomeProvider.dart';
import 'package:numo/Provider/SettingProvider.dart';
import 'package:numo/Provider/UserProvider.dart';
import 'package:numo/Screen/Cart.dart';
import 'package:numo/Screen/Favorite.dart';
import 'package:numo/Screen/Search.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../main.dart';
import 'Color.dart';
import 'Constant.dart';
import 'Demo_Localization.dart';
import 'String.dart';

const String isLogin = '${appName}isLogin';
String? _token;

setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);

  log('setPrefrenceBool');
}

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

Widget getDiscountLabel(String discount) => Container(
      decoration: BoxDecoration(color: colors.red, borderRadius: BorderRadius.circular(1)),
      margin: const EdgeInsets.only(left: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
        child: Text(
          "$discount%",
          style: const TextStyle(color: colors.whiteTemp, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    );

void hideAppbarAndBottomBarOnScroll(
  ScrollController scrollBottomBarController,
  BuildContext context,
) {
  scrollBottomBarController.addListener(() {
    if (scrollBottomBarController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!context.read<HomeProvider>().animationController.isAnimating) {
        context.read<HomeProvider>().animationController.forward();
        context.read<HomeProvider>().showBars(false);
      }
    } else {
      if (!context.read<HomeProvider>().animationController.isAnimating) {
        context.read<HomeProvider>().animationController.reverse();
        context.read<HomeProvider>().showBars(true);
      }
    }
  });
}

shadow() {
  return const BoxDecoration(
    boxShadow: [BoxShadow(color: Color(0x1a0400ff), offset: Offset(0, 0), blurRadius: 30)],
  );
}

placeHolder(double height) {
  return const AssetImage(
    'assets/images/Placeholder_Rectangle.png',
  );
}

erroWidget(double size) {
  return Image.asset(
    "assets/images/Placeholder_Rectangle.png",
    color: colors.primary,
    width: size,
    height: size,
  );
}

errorWidget(double size) {
  return Icon(
    Icons.account_circle,
    color: Colors.grey,
    size: size,
  );
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

getAppBar(String title, BuildContext context, {int? from}) {
  return AppBar(
    elevation: 0,
    titleSpacing: 0,
    backgroundColor: Theme.of(context).colorScheme.white,
    leading: Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => Navigator.of(context).pop(),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: colors.primary,
            ),
          ),
        ),
      );
    }),
    title: Text(
      title,
      style: const TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
    ),
    actions: <Widget>[
      from == 1
          ? SizedBox()
          : IconButton(
              icon: SvgPicture.asset(
                "${imagePath}search.svg",
                height: 20,
                color: colors.primary,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Search(),
                    ));
              }),
      from == 1
          ? SizedBox()
          : title == getTranslated(context, 'FAVORITE')!
              ? Container()
              : IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: SvgPicture.asset(
                    "${imagePath}desel_fav.svg",
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
      from == 1
          ? SizedBox()
          : Selector<UserProvider, String>(
              builder: (context, data, child) {
                return IconButton(
                  icon: Stack(
                    children: [
                      Center(
                          child: SvgPicture.asset(
                        "${imagePath}appbarCart.svg",
                        color: colors.primary,
                      )),
                      (data.isNotEmpty && data != "0")
                          ? Positioned(
                              bottom: 20,
                              right: 0,
                              child: Container(
                                  //  height: 20,
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
                  ),
                  onPressed: () {
                    cartTotalClear();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const Cart(
                          fromBottom: false,
                        ),
                      ),
                    );
                  },
                );
              },
              selector: (_, homeProvider) => homeProvider.curCartCount,
            )
    ],
  );
}

cartTotalClear() {
  totalPrice = 0;
  // oriPrice = 0;

  taxPer = 0;
  delCharge = 0;
  addressList.clear();

  promoAmt = 0;
  remWalBal = 0;
  usedBal = 0;
  payMethod = '';
  isPromoValid = false;
  isPromoLen = false;
  isUseWallet = false;
  isPayLayShow = true;
  selectedMethod = null;
  selectedTime = null;
  selectedDate = null;
  selAddress = '';
  payMethod = "";
  selTime = "";
  selDate = "";
  promocode = "";
}

getSimpleAppBar(
  String title,
  BuildContext context,
) {
  return AppBar(
    elevation: 0,
    titleSpacing: 0,
    backgroundColor: Theme.of(context).colorScheme.white,
    leading: Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => Navigator.of(context).pop(),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: colors.primary,
            ),
          ),
        ),
      );
    }),
    title: Text(
      title,
      style: const TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
    ),
  );
}

Widget bottomSheetHandle(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Theme.of(context).colorScheme.lightBlack),
      height: 5,
      width: MediaQuery.of(context).size.width * 0.3,
    ),
  );
}

Widget bottomsheetLabel(String labelName, BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 20),
      child: getHeading(labelName, context),
    );

Widget getHeading(String title, BuildContext context) {
  return Text(
    getTranslated(context, title)!,
    style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.fontColor),
  );
}

noIntImage() {
  return Image.asset('assets/images/no_internet.png', fit: BoxFit.contain);
}

setSnackbar(String msg, BuildContext context) {
  return showToast(msg,
      fullWidth: true,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.slideToBottom,
      position: StyledToastPosition.bottom,
      animDuration: const Duration(milliseconds: 300),
      duration: const Duration(seconds: 2),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      borderRadius: BorderRadius.circular(10.0),
      backgroundColor: Theme.of(context).colorScheme.white,
      textStyle: TextStyle(color: Theme.of(context).colorScheme.black));
}

/*setSnackbar(String msg, BuildContext context) {
  try {
    scaffoldMessageKey.currentState!.showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  } catch (e) {
    print(e);
  }
}*/

String imagePath = 'assets/images/';

noIntText(BuildContext context) {
  return Text(getTranslated(context, 'NO_INTERNET')!,
      style: Theme.of(context).textTheme.headline5!.copyWith(color: colors.primary, fontWeight: FontWeight.normal));
}

noIntDec(BuildContext context) {
  return Container(
    padding: const EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
    child: Text(getTranslated(context, 'NO_INTERNET_DISC')!,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).colorScheme.lightBlack2,
              fontWeight: FontWeight.normal,
            )),
  );
}

Widget showCircularProgress(bool isProgress, Color color) {
  if (isProgress) {
    return Center(
        child: CircularProgressIndicator(
      color: colors.primary,
      valueColor: AlwaysStoppedAnimation<Color>(color),
    ));
  }
  return const SizedBox(
    height: 0.0,
    width: 0.0,
  );
}

imagePlaceHolder(double size, BuildContext context) {
  return SizedBox(
    height: size,
    width: size,
    child: Icon(
      Icons.account_circle,
      color: Theme.of(context).colorScheme.white,
      size: size,
    ),
  );
}

String? validateUserName(String value, String? msg1, String? msg2) {
  if (value.isEmpty) {
    return msg1;
  }
  if (value.length <= 1) {
    return msg2;
  }
  return null;
}

String? validateMob(String value, String? msg1, String? msg2) {
  if (value.isEmpty) {
    return msg1;
  }
  if (value.length < 9 || value.length > 9) {
    return msg2;
  }
  return null;
}

String? validateCountryCode(String value, String msg1, String msg2) {
  if (value.isEmpty) {
    return msg1;
  }
  if (value.isEmpty) {
    return msg2;
  }
  return null;
}

String? validatePass(String value, String? msg1, String? msg2) {
  if (value.isEmpty) {
    return msg1;
  } else if (value.length <= 5) {
    return msg2;
  } else {
    return null;
  }
}

String? validateAltMob(String value, String? msg) {
  if (value.isNotEmpty && value.length < 9) {
    return msg;
  }
  return null;
}

String? validateField(String value, String? msg) {
  if (value.isEmpty) {
    return msg;
  } else {
    return null;
  }
}

String? validatePincode(String value, String? msg1) {
  if (value.isEmpty) {
    return msg1;
  } else {
    return null;
  }
}

String? validateEmail(String value, String? msg1, String? msg2) {
  if (value.isEmpty) {
    return msg1;
  } else if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
          r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
          r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
      .hasMatch(value)) {
    return msg2;
  } else {
    return null;
  }
}

Widget getProgress() {
  return const Center(
      child: CircularProgressIndicator(
    color: colors.primary,
  ));
}

Widget getNoItem(BuildContext context) {
  return Center(
      child: Text(
    getTranslated(context, 'noItem')!,
    style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
  ));
}

Widget shimmer(BuildContext context) {
  // log('Session - shimmer');

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    child: Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.simmerBase,
      highlightColor: Theme.of(context).colorScheme.simmerHigh,
      child: SingleChildScrollView(
        child: Column(
          children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .map((_) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          color: Theme.of(context).colorScheme.white,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 18.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 100.0,
                                height: 8.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 20.0,
                                height: 8.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    ),
  );
}

Widget singleItemSimmer(BuildContext context) {
  return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.simmerBase,
          highlightColor: Theme.of(context).colorScheme.simmerHigh,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  color: Theme.of(context).colorScheme.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 18.0,
                        color: Theme.of(context).colorScheme.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      Container(
                        width: double.infinity,
                        height: 8.0,
                        color: Theme.of(context).colorScheme.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      Container(
                        width: 100.0,
                        height: 8.0,
                        color: Theme.of(context).colorScheme.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      Container(
                        width: 20.0,
                        height: 8.0,
                        color: Theme.of(context).colorScheme.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
          )));
}

simmerSingleProduct(BuildContext context) {
  return Container(
      //width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Theme.of(context).colorScheme.white,
        ),
      ));
}

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  log('Session getLocale() defualt is en ');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString(LAGUAGE_CODE) ?? "ar";
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case "en":
      return const Locale("en", 'US');
    case "zh":
      return const Locale("zh", "CN");
    case "es":
      return const Locale("es", "ES");
    case "hi":
      return const Locale("hi", "IN");
    case "ar":
      return const Locale("ar", "DZ");
    case "ru":
      return const Locale("ru", "RU");
    case "ja":
      return const Locale("ja", "JP");
    case "de":
      return const Locale("de", "DE");
    default:
      return const Locale("en", 'US');
  }
}

String? getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)!.translate(key);
}

String getToken() {
  final claimSet = JwtClaim(issuer: 'eshop', maxAge: const Duration(minutes: 120), issuedAt: DateTime.now().toUtc());

  String token = issueJwtHS256(claimSet, jwtKey);
  // debugPrint("depugPrint token is $token");
  // log("log token is $token");
  return token;
}

Future<String> numoToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(ACCESS_TOKEN);

  return token ?? '';
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ${getToken()}',
    };

// Map<String, String> get numoHeaders11 => {
//       "Authorization": 'Bearer ${getNumoToken()}',
//       "company_id": "$companyID",
//       "store_id": "$storeID",
//       // 'Content-Type': 'application/json; charset=UTF-8',
//     };

// Map<String, String> get numoHeadersWithJson11 => {
//       "Authorization": 'Bearer ${getNumoToken()}',
//       "company_id": "$companyID",
//       "store_id": "$storeID",
//       'Content-Type': 'application/json; charset=UTF-8'
//       // 'accept': 'application/json'
//       // 'Content-Type': 'application/json; charset=UTF-8',
//     };

Future<String> getNumoToken() async {
  var token = await numoToken();
  return token;
}

Future<bool> isTokenExpired() async {
  var token = await numoToken();
  bool hasExpired=true; //= JwtDecoder.isExpired(token);

  return hasExpired;
}

/*String? getPriceFormat(BuildContext context, double price) {
  //var SUPPORTED_LOCALS= context.read<SettingProvider>().supportedLocales;

  return NumberFormat.simpleCurrency(locale: SUPPORTED_LOCALES)
      .format(price)
      .toString();
}*/

String? getPriceFormat(BuildContext context, double price) {
  // log('Session getPriceFormat locale: Platform.localeName=${Platform.localeName} SUPPORTED_LOCALE=${SUPPORTED_LOCALES.toString()} CUR_CURRENCY=$CUR_CURRENCY ');
  // var c = NumberFormat.currency(locale: Platform.localeName, name: SUPPORTED_LOCALES, symbol: CUR_CURRENCY).format(price).toString();
  var c = NumberFormat.currency(locale: Platform.localeName, customPattern: '#,###.## $CUR_CURRENCY').format(price).toString();
  // log('getPriceFormat = $c');
  return c;
}

double verfiedDouble(var price) {
  double c = 0.0;
  try {
    if (price == 'null' || price == null || price == '' || price == 0) {
      return c;
    } else {
      c = double.parse(price.toString());
    }
  } catch (e) {
    log('Session verfiedDouble error =$e');
    return c;
  }
  return c;
}

void removeNullParams(Map<String, Object> mapToEdit) {
// Remove all null values; they cause validation errors
  final keys = mapToEdit.keys.toList(growable: false);
  for (String key in keys) {
    final value = mapToEdit[key];
    if (value == null) {
      mapToEdit[key] = '';
    } else if (value is String) {
      if (value.isEmpty) {
        mapToEdit[key] = '';
      }
    } else if (value is Map<String, Object>) {
      removeNullParams(value);
    }
  }
}

dialogAnimate(BuildContext context, Widget dialge) {
  return showGeneralDialog(
      barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(opacity: a1.value, child: dialge),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      // pageBuilder: null
      pageBuilder: (context, animation1, animation2) {
        return Container();
      } //as Widget Function(BuildContext, Animation<double>, Animation<double>)
      );
}
