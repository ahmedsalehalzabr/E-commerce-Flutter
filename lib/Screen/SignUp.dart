// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as d;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:numo/Helper/Constant.dart';
import 'package:numo/Helper/String.dart';
import 'package:numo/Helper/cropped_container.dart';
import 'package:numo/Model/Model.dart';
import 'package:numo/Provider/SettingProvider.dart';
import 'package:numo/Provider/UserProvider.dart';
import 'package:numo/Screen/Map.dart';
import 'package:numo/Screen/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Session.dart';
import '../Model/User.dart';
import 'HomePage.dart';

class SignUp extends StatefulWidget {
  final bool? update;
  final int? index;

  const SignUp({Key? key, this.update, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SignUpPageState();
  }
}

String? latitude, longitude, state, country, city_name, region_name;

class _SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool? _showPassword = false;
  bool visible = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final referController = TextEditingController();

//=========NUMO TextController=====================
  final MERCHANT_FULLNAME_CTRL = TextEditingController();
  final MERCHANT_COMNAME_CTRL = TextEditingController();
  final MERCHANT_ADDRESS_CTRL = TextEditingController();
  final CITY_ID_CTRL = TextEditingController(); // DropdownButton(items: cities, onChanged: onChanged);
  final REGION_ID_CTRL = TextEditingController();
  final COUNTRY_ID_CTRL = TextEditingController();
  final MERCHANT_PHONE1_CTRL = TextEditingController();
  final MERCHANT_EMAIL_CTRL = TextEditingController();
  final MERCHANT_LOCATION_CTRL = TextEditingController();
  final MERCHANT_TYPE_ID_CTRL = TextEditingController();
//-----------------------------------------------
  int count = 1;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? name,
      comname,
      email,
      password,
      mobile,
      id,
      countrycode,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      referCode,
      friendCode,
      // friendCode,
      // friendCode,
      // friendCode,
      merchant_id,
      merchantUser_id, //
      merchantUser_name, //
      merchantUser_password, //
      merchantUser_phone1, //
      merchant_fullName,
      merchant_comName,
      merchant_address,
      city_id,
      region_id,
      country_id,
      merchant_email,
      merchant_location,
      merchantType_id,
      accessToken,
      // type = 'Home',
      // type = 'Home',
      // type = 'Home',
      type = 'Home',
      isDefault,
      selectedArea = '',
      selectedCity = '';

  bool checkedDefault = false, isArea = false;
  bool _isProgress = false;
  StateSetter? areaState, cityState;

  List<User> cityList = [];
  List<User> areaList = [];
  List<User> areaSearchList = [];
  List<User> citySearchLIst = [];
  List<User> merchantTypeList = [];

  List<User> addressList = [];

  bool cityLoading = true, areaLoading = true;

  TextEditingController? nameC, mobileC, pincodeC, addressC, landmarkC, stateC, countryC, altMobC;
  int? selectedType = 1;

  FocusNode? nameFocus, emailFocus, addFocus, passFocus, locationFocus, cityFocus, areaFocus, referFocus = FocusNode();

  User? selArea;
  int? selAreaPos = -1, selCityPos = -1;
  int cityOffset = 0, areaOffset = 0;
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final ScrollController _cityScrollController = ScrollController();
  final ScrollController _areaScrollController = ScrollController();

  bool? isLoadingMoreCity, isLoadingMoreArea;

  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  getUserDetails() async {
    SettingProvider settingsProvider = Provider.of<SettingProvider>(context, listen: false);

    // SharedPreferences prefs = await SharedPreferences.getInstance();

    // debugPrint('=========================prefs.toString()=============');
    // for (var element in prefs.getKeys()) {
    //   try {
    //     // ignore: prefer_interpolation_to_compose_strings
    //     // d.log('main prefs.getKeys()  $element  = ' + prefs.getString(element.toString())!);
    //     d.log('main prefs.getKeys()  $element ');
    //     // debugPrint(prefs.getString(element.toString()));
    //   } catch (_) {
    //     debugPrint('error on for loop =');
    //     debugPrint(_.toString());
    //   }
    // }
    // debugPrint('-----------------------prefs.toString------------------- ');

    merchantUser_phone1 = await settingsProvider.getPrefrence(MERCHANTUSER_PHONE1);
    countrycode = await settingsProvider.getPrefrence(COUNTRY_CODE);
    country_id = countrycode == '967' ? '1' : countrycode;

    if (mounted) setState(() {});
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      // if (referCode != null)
      getRegisterUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
        await buttonController!.reverse();
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(top: kToolbarHeight),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        noIntImage(),
        noIntText(context),
        noIntDec(context),
        AppBtn(
          title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            _playAnimation();

            Future.delayed(const Duration(seconds: 2)).then((_) async {
              _isNetworkAvail = await isNetworkAvailable();
              if (_isNetworkAvail) {
                Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) => super.widget));
              } else {
                await buttonController!.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  Future<void> getRegisterUser() async {
    try {
      var param = {
        MERCHANTUSER_PHONE1: merchantUser_phone1,
        // NAME: name,
        // EMAIL: email,
        // PASSWORD: password,
        // COUNTRY_CODE: countrycode,
        REFERCODE: referCode,
        // FRNDCODE: friendCode,

        //=========NUMO FIELDS
        // MERCHANT_ID: merchant_id,
        MERCHANT_FULLNAME: merchant_fullName,
        MERCHANT_COMNAME: merchant_comName,
        MERCHANT_ADDRESS: merchant_address,
        CITY_ID: city_id, // ?? '6940571',
        REGION_ID: region_id, // ?? '6940660',
        COUNTRY_ID: country_id, // ?? '967',
        MERCHANT_PHONE1: merchantUser_phone1,
        MERCHANTUSER_PASSWORD: merchantUser_password,
        MERCHANT_EMAIL: merchant_email,
        MERCHANT_LOCATION: merchant_location,
        MERCHANTTYPE_ID: merchantType_id
        //-------------------------
      };

      d.log('getRegisterUser param=$param');
      // apiBaseHelper.postAPICall(getUserSignUpApi, data).then((getdata) async {
      //   bool error = getdata["error"];
      //   String? msg = getdata["message"];
      //   await buttonController!.reverse();
      //   if (!error) {
      //     d.log(" =============== getRegisterUser ================= ");
      //     d.log("getdata****$getdata");
      // print("getdata****$getdata");
      //     setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG')!, context);
      //     var i = getdata["data"][0];
      //     id = i[ID];
      //     name = i[USERNAME];
      //     email = i[EMAIL];
      //     mobile = i[MOBILE];
      //     CUR_MERCHANTID = id;
      //     UserProvider userProvider = context.read<UserProvider>();
      //     userProvider.setName(name!);
      //     SettingProvider settingProvider = context.read<SettingProvider>();
      //     settingProvider.saveUserDetail(id!, name, email, mobile, city, area, address, pincode, latitude, longitude, "", context);
      //     Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
      //   } else {
      //     setSnackbar(msg!, context);
      //   }
      //   if (mounted) setState(() {});
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      // });

      apiBaseHelper.postNumoAPICall(postNumoMerchantAddApi, param).then((getdata) async {
        await buttonController!.reverse();
        d.log('getdata=$getdata');
        var data = getdata[MERCHANT];
        var userdata = getdata[MERCHANTUSER];
        accessToken = getdata[ACCESS_TOKEN];
        d.log('result data=$data');
        // if (data) {
        d.log(" =============== postNumoUserSignUpApi ================= ");
        d.log("data****$data");
        setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG')!, context);

        merchant_id = data[MERCHANT_ID].toString();
        merchantUser_id = userdata[MERCHANTUSER_ID].toString();
        merchantUser_phone1 = userdata[MERCHANTUSER_PHONE1].toString();
        merchant_fullName = data[MERCHANT_FULLNAME];
        merchant_comName = data[MERCHANT_COMNAME];
        merchant_address = data[MERCHANT_ADDRESS];
        city_id = data[CITY_ID].toString();
        region_id = data[REGION_ID].toString();
        country_id = data[COUNTRY_ID].toString();
        merchant_email = data[MERCHANT_EMAIL];
        merchant_location = data[MERCHANT_LOCATION];
        merchantType_id = data[MERCHANTTYPE_ID].toString();

        d.log('getRegisterUser value added');
        UserProvider userProvider = context.read<UserProvider>();
        userProvider.setMerchantUserName(merchant_fullName!);
        userProvider.setMerchantComName(merchant_comName!);
        userProvider.setMerchantUserPhone1(merchantUser_phone1!);
        d.log('getRegisterUser UserProvider done');

        SettingProvider settingProvider = context.read<SettingProvider>();
        settingProvider.setPrefrenceBool(ISFIRSTTIME, true);
        setPrefrenceBool(ISFIRSTTIME, true);
        settingProvider.saveUserDetail(merchant_id!, merchantUser_id!, merchant_fullName, merchant_email, merchantUser_phone1!, city_id, region_id,
            merchant_address, pincode, latitude, longitude, "", accessToken, context);
        d.log('getRegisterUser SettingProvider done');

        Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
        // } else {
        //   setSnackbar(getTranslated(context, 'DATA_ERROR_LBL')!, context);
        // }
        if (mounted) setState(() {});
      }, onError: (error) {
        d.log('getRegisterUser error=$error');
        setSnackbar(error.toString(), context);
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      await buttonController!.reverse();
    }
  }

  Widget registerTxt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(getTranslated(context, 'USER_REGISTER_DETAILS')!,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 25)),
      ),
    );
  }

  setUserName() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        controller: nameController,
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
        validator: (val) => validateUserName(val!, getTranslated(context, 'USER_REQUIRED'), getTranslated(context, 'USER_LENGTH')),
        onSaved: (String? value) {
          name = value;
          merchantUser_name = value;
          merchant_fullName = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, nameFocus!, emailFocus);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.account_circle_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'NAMEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setMerchantCommName() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        controller: MERCHANT_COMNAME_CTRL,
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
        validator: (val) => validateField(val!, getTranslated(context, 'FIELD_REQUIRED')),
        onSaved: (String? value) {
          merchant_comName = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, nameFocus!, emailFocus);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.data_array_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'COMNAME_LBL')!,
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setCities() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 15.0,
        end: 15.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: GestureDetector(
              child: InputDecorator(
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.white,
                    isDense: true,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: colors.primary),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getTranslated(context, 'CITYSELECT_LBL')!,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(selCityPos != null && selCityPos != -1 ? selectedCity! : '',
                                style: TextStyle(color: selCityPos != null ? Theme.of(context).colorScheme.fontColor : Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right)
                    ],
                  )),
              onTap: () {
                cityDialog();
              },
            )),
      ),
    );
  }

  setArea() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 15.0,
        end: 15.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: GestureDetector(
              child: InputDecorator(
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.white,
                    isDense: true,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: colors.primary),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getTranslated(context, 'AREASELECT_LBL')!,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(selAreaPos != null && selAreaPos != -1 ? selectedArea! : '',
                                style: TextStyle(color: selAreaPos != null ? Theme.of(context).colorScheme.fontColor : Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right),
                    ],
                  )),
              onTap: () {
                if (selCityPos != null && selCityPos != -1) {
                  areaDialog();
                }
              },
            )),
      ),
    );
  }

  setAddress() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 15.0,
                  end: 15.0,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  controller: addressC,
                  focusNode: addFocus,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
                  validator: (val) => validateField(val!, getTranslated(context, 'FIELD_REQUIRED')),
                  onSaved: (String? value) {
                    address = value;
                    merchant_address = value;
                    merchant_location = value;
                  },
                  onFieldSubmitted: (v) {
                    _fieldFocusChange(context, addFocus!, cityFocus);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.pin_drop_outlined,
                      color: Theme.of(context).colorScheme.fontColor,
                      size: 17,
                    ),
                    label: Text(getTranslated(context, 'ADDRESS_LBL')!),
                    fillColor: Theme.of(context).colorScheme.white,
                    isDense: true,
                    hintText: getTranslated(context, 'ADDRESS_LBL'),
                    hintStyle: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 25),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: colors.primary),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        color: colors.primary,
                      ),
                      focusNode: locationFocus,
                      onPressed: () async {
                        LocationPermission permission;

                        permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                        }
                        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                        await Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => Map(
                                      latitude: latitude == null || latitude == '' ? position.latitude : double.parse(latitude!),
                                      longitude: longitude == null || longitude == '' ? position.longitude : double.parse(longitude!),
                                      from: getTranslated(context, 'ADDADDRESS'),
                                    )));
                        if (mounted) setState(() {});
                        List<Placemark> placemark = await placemarkFromCoordinates(double.parse(latitude!), double.parse(longitude!));

                        var address;
                        address = placemark[0].name;
                        address = address + ',' + placemark[0].subLocality;
                        address = address + ',' + placemark[0].locality;
                        d.log('placemark = $placemark[0]');
                        d.log('address = $address');
                        state = placemark[0].administrativeArea;
                        country = placemark[0].country;

                        if (mounted) {
                          setState(() {
                            // countryC!.text = country!;
                            // stateC!.text = state!;
                            addressC!.text = address;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  areaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            areaState = setStater;
            return WillPopScope(
              onWillPop: () async {
                setState() {
                  areaOffset = 0;
                  _areaController.clear();
                }

                return true;
              },
              child: AlertDialog(
                contentPadding: const EdgeInsets.all(0.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
                      child: Text(
                        getTranslated(context, 'AREASELECT_LBL')!,
                        style: Theme.of(this.context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: _areaController,
                              autofocus: false,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                                hintText: getTranslated(context, 'SEARCH_LBL'),
                                hintStyle: TextStyle(color: colors.primary.withOpacity(0.5)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton(
                              onPressed: () async {
                                setState(() {
                                  isLoadingMoreArea = true;
                                });

                                await getArea(city, true, true);
                              },
                              icon: const Icon(
                                Icons.search,
                                size: 20,
                              )),
                        )
                      ],
                    ),
                    Divider(color: Theme.of(context).colorScheme.lightBlack),
                    areaLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : (areaSearchList.isNotEmpty)
                            ? Flexible(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.4,
                                  child: SingleChildScrollView(
                                    controller: _areaScrollController,
                                    child: Column(
                                      children: [
                                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: getAreaList()),
                                        showCircularProgress(isLoadingMoreArea!, colors.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: getNoItem(context),
                              )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  cityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            cityState = setStater;

            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
                    child: Text(
                      getTranslated(context, 'CITYSELECT_LBL')!,
                      style: Theme.of(this.context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: _cityController,
                            autofocus: false,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.fontColor,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                              hintText: getTranslated(context, 'SEARCH_LBL'),
                              hintStyle: TextStyle(color: colors.primary.withOpacity(0.5)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                            onPressed: () async {
                              setState(() {
                                isLoadingMoreCity = true;
                              });

                              await getCities(true);
                            },
                            icon: const Icon(
                              Icons.search,
                              size: 20,
                            )),
                      )
                    ],
                  ),
                  cityLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : (citySearchLIst.isNotEmpty)
                          ? Flexible(
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                child: SingleChildScrollView(
                                  controller: _cityScrollController,
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: getCityList(),
                                          ),
                                          Center(
                                            child: showCircularProgress(isLoadingMoreCity!, colors.primary),
                                          ),
                                        ],
                                      ),
                                      showCircularProgress(_isProgress, colors.primary),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: getNoItem(context),
                            )
                ],
              ),
            );
          },
        );
      },
    );
  }

  getAreaList() {
    return areaSearchList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  areaOffset = 0;
                  _areaController.clear();

                  setState(
                    () {
                      d.log('area index = $index');
                      selAreaPos = index;
                      Navigator.of(context).pop();
                      selArea = areaSearchList[selAreaPos!];
                      area = selArea!.region_id;
                      region_id = selArea!.region_id;

                      // pincodeC!.text = selArea!.pincode!;
                      selectedArea = areaSearchList[selAreaPos!].region_name!;
                      d.log('area name = $selectedArea');
                      d.log('area id = $area');
                      d.log('region id = $region_id');
                    },
                  );

                  getArea(city, false, true);
                }
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    areaSearchList[index].region_name!,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  getCityList() {
    return citySearchLIst
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  setState(
                    () {
                      d.log('city index = $index');
                      isArea = false;
                      selCityPos = index;
                      selAreaPos = null;
                      selArea = null;
                      // pincodeC!.text = '';
                      d.log('city index2 = $index');
                      Navigator.of(context).pop();
                    },
                  );
                }
                city = citySearchLIst[selCityPos!].city_id;
                city_id = city;
                d.log('city id = $city');

                selectedCity = citySearchLIst[selCityPos!].city_name;
                d.log('city name = $selectedCity');

                getArea(city, true, true);
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    citySearchLIst[index].city_name!,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      await getCities(false);
      await getType();
      // if (widget.update!) {
      // getArea(addressList[widget.index!].cityId, false, false);
      // }
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      });
    }
  }

  Future<void> getCities(bool isSearchCity) async {
    try {
      var parameter = {
        LIMIT: perPage.toString(),
        OFFSET: cityOffset.toString(),
      };

      if (isSearchCity) {
        parameter[SEARCH] = _cityController.text;
        parameter[OFFSET] = '0';
        citySearchLIst.clear();
      }
      apiBaseHelper.getNumoAPICall(getNumoCitiesApi, parameter, null).then((data) async {
        // if (!data) {
        // d.log('getNumoCitiesApi data =$data');
        cityList = (data as List).map((data) => User.fromJson(data)).toList();
        // d.log('getNumoCitiesApi cityList =$cityList');
        citySearchLIst.addAll(cityList);
        // d.log('getNumoCitiesApi citySearchLIst =$citySearchLIst');

        // } else {
        // if (msg != null) {
        //   setSnackbar(msg, context);
        // }
        // }
        cityLoading = false;
        isLoadingMoreCity = false;
        _isProgress = false;
        cityOffset += perPage;
        if (mounted && cityState != null) cityState!(() {});
        if (mounted) setState(() {});

        // if (widget.update!) {
        selCityPos = citySearchLIst.indexWhere((f) => f.city_name == city_name);

        d.log('selCityPos = $selCityPos');

        if (selCityPos == -1) {
          selCityPos = null;
        }
        selectedCity = citySearchLIst[selCityPos!].city_name!;
        // }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      });

//replaced by numo
      // apiBaseHelper.postAPICall(getCitiesApi, parameter).then((getdata) async {
      //   bool error = getdata['error'];
      //   String? msg = getdata['message'];
      //   if (!error) {
      //     var data = getdata['data'];
      //     d.log('getCitiesApi data=$data');
      //     // cityList = (data as List).map((data) => User.fromJson(data)).toList();
      //     // citySearchLIst.addAll(cityList);
      //   } else {
      //     if (msg != null) {
      //       setSnackbar(msg, context);
      //     }
      //   }
      //   cityLoading = false;
      //   isLoadingMoreCity = false;
      //   _isProgress = false;
      //   cityOffset += perPage;
      //   if (mounted && cityState != null) cityState!(() {});
      //   if (mounted) setState(() {});

      //   // if (widget.update!) {
      //   selCityPos = 1;
      //          citySearchLIst.indexWhere((f) => f.id == addressList[widget.index!].cityId);

      //   if (selCityPos == -1) {
      //     selCityPos = null;
      //   }
      //   selectedCity = citySearchLIst[selCityPos!].name!;
      //   // }
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      // });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<void> getArea(String? city, bool clear, bool isSearchArea) async {
    try {
      // ignore: prefer_typing_uninitialized_variables
      var data = {city_id: city, OFFSET: areaOffset.toString(), LIMIT: perPage.toString()};

      if (isSearchArea) {
        data[SEARCH] = _areaController.text;
        data[OFFSET] = '0';
        areaSearchList.clear();
      }

      // var tempUri = Uri.parse('${getNumoRegionByCityApi.toString()}$city');
      // d.log('tempUri = ${tempUri.toString()}');

      apiBaseHelper.getNumoAPICall(getNumoRegionByCityApi, {}, city).then((data) {
        // if (!error) {
        // var data = getdata['data'];
        d.log('region data=$data');
        areaList.clear();
        if (clear) {
          area = null;
          region_id = null;
          selArea = null;
        }
        areaList = (data as List).map((data) => User.fromJson(data)).toList();

        areaSearchList.addAll(areaList);

        // if (widget.update!) {
        // for (User item in addressList) {
        //   for (int i = 0; i < areaSearchList.length; i++) {
        //     if (areaSearchList[i].id == item.areaId) {
        //       selArea = areaSearchList[i];
        //       selAreaPos = i;
        //       selectedArea = areaSearchList[selAreaPos!].name!;
        //     }
        //   }
        // }
        // }
        // } else {
        //   if (msg != null) {
        //     setSnackbar(msg, context);
        //   }
        // }
        areaLoading = false;
        isLoadingMoreArea = false;
        areaOffset += perPage;
        if (mounted) {
          setState(() {
            isArea = true;
          });
          if (areaState != null && mounted) areaState!(() {});
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      });

      // apiBaseHelper.postAPICall(getAreaByCityApi, data).then((getdata) {
      //   bool error = getdata['error'];
      //   String? msg = getdata['message'];

      //   if (!error) {
      //     var data = getdata['data'];
      //     areaList.clear();
      //     if (clear) {
      //       area = null;
      //       selArea = null;
      //     }
      //     areaList = (data as List).map((data) => User.fromJson(data)).toList();

      //     areaSearchList.addAll(areaList);

      //     // if (widget.update!) {
      //     // for (User item in addressList) {
      //     //   for (int i = 0; i < areaSearchList.length; i++) {
      //     //     if (areaSearchList[i].id == item.areaId) {
      //     //       selArea = areaSearchList[i];
      //     //       selAreaPos = i;
      //     //       selectedArea = areaSearchList[selAreaPos!].name!;
      //     //     }
      //     //   }
      //     // }
      //     // }
      //   } else {
      //     if (msg != null) {
      //       setSnackbar(msg, context);
      //     }
      //   }
      //   areaLoading = false;
      //   isLoadingMoreArea = false;
      //   areaOffset += perPage;
      //   if (mounted) {
      //     setState(() {
      //       isArea = true;
      //     });
      //     if (areaState != null && mounted) areaState!(() {});
      //   }
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      // });

    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<void> getCurrentLoc() async {
    d.log('getCurrentLoc');

    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    d.log('getCurrentLoc latitude=$latitude , longitude=$longitude');

    List<Placemark> placemark = await placemarkFromCoordinates(double.parse(latitude!), double.parse(longitude!), localeIdentifier: 'ar');

    d.log('getCurrentLoc placemark[0]=$placemark[0] ');

    state = placemark[0].administrativeArea;
    city_name = placemark[0].administrativeArea;
    region_name = placemark[0].subLocality;
    country = placemark[0].country;
    address = placemark[0].country;
    address = '${address!},${placemark[0].administrativeArea!}';
    address = '${address!},${placemark[0].subLocality!}';
    d.log('getCurrentLoc state=$state ,country=$country ');

    if (mounted) {
      setState(() {
        addressC!.text = address!;
        countryC!.text = country!;
        stateC!.text = state!;
      });
    }
  }

  Widget setType() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: DropdownButtonFormField(
        iconEnabledColor: Theme.of(context).colorScheme.fontColor,
        isDense: true,
        hint: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 10.0),
          child: Text(
            getTranslated(context, 'SELECT_TYPE')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
          ),
        ),
        decoration: InputDecoration(
          filled: true,
          isDense: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        value: merchantType_id,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
        onChanged: (String? newValue) {
          if (mounted) {
            setState(() {
              merchantType_id = newValue;
            });
          }
        },
        items: merchantTypeList.map((User u) {
          return DropdownMenuItem<String>(
            value: u.merchantType_id,
            child: Text(
              u.merchantType_name!,
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> getType() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {};

        // apiBaseHelper.postAPICall(getTicketTypeApi, parameter).then((getdata) {
        apiBaseHelper.getNumoAPICall(postNumoMerchantTypeApi, {}, null).then((data) {
          // bool error = getdata["error"];
          // String? msg = getdata["message"];
          // if (!data.isNotEmpty()) {
          // var data = getdata["data"];
          d.log('merchantType List data=$data');

          merchantTypeList = (data as List).map((data) => User.fromMerchantType(data)).toList();
          // } else {
          //   setSnackbar(msg!, context);
          // }
          // if (mounted) {
          //   setState(() {
          //     _isLoading = false;
          //   });
          // }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  setEmail() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailController,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
        validator: (val) => validateEmail(val!, getTranslated(context, 'EMAIL_REQUIRED'), getTranslated(context, 'VALID_EMAIL')),
        onSaved: (String? value) {
          email = value;
          merchant_email = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus!, passFocus);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.alternate_email_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setRefer() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: referFocus,
        controller: referController,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
        onSaved: (String? value) {
          friendCode = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.card_giftcard_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'REFER'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 10.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: !_showPassword!,
          focusNode: passFocus,
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passFocus!, referFocus);
          },
          textInputAction: TextInputAction.next,
          style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
          controller: passwordController,
          validator: (val) => validatePass(val!, getTranslated(context, 'PWD_REQUIRED'), getTranslated(context, 'PWD_LENGTH')),
          onSaved: (String? value) {
            password = value;
            merchantUser_password = value;
          },
          decoration: InputDecoration(
            prefixIcon: SvgPicture.asset(
              "assets/images/password.svg",
              height: 17,
              width: 17,
              color: Theme.of(context).colorScheme.fontColor,
            ),
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 25),
            focusedBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: colors.primary),
              borderRadius: BorderRadius.circular(7.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  showPass() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 30.0,
          end: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Checkbox(
              value: _showPassword,
              checkColor: Theme.of(context).colorScheme.fontColor,
              activeColor: Theme.of(context).colorScheme.lightWhite,
              onChanged: (bool? value) {
                if (mounted) {
                  setState(() {
                    _showPassword = value;
                  });
                }
              },
            ),
            Text(getTranslated(context, 'SHOW_PASSWORD')!,
                style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal))
          ],
        ));
  }

  verifyBtn() {
    return AppBtn(
      title: getTranslated(context, 'SAVE_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        validateAndSubmit();
      },
    );
  }

  loginTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 25.0,
        end: 25.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'ALREADY_A_CUSTOMER')!,
              style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) => const Login(),
                ));
              },
              child: Text(
                getTranslated(context, 'LOG_IN_LBL')!,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Theme.of(context).colorScheme.fontColor, decoration: TextDecoration.underline, fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  backBtn() {
    return Platform.isIOS
        ? Positioned(
            top: 34.0,
            left: 5.0,
            child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: shadow(),
                  child: Card(
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Center(
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                )),
          )
        : Container();
  }

  expandedBottomView() {
    return Expanded(
        flex: 8,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
                child: Form(
              key: _formkey,
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    registerTxt(),
                    setUserName(),
                    setEmail(),
                    setPass(),
                    setRefer(),
                    showPass(),
                    verifyBtn(),
                    loginTxt(),
                  ],
                ),
              ),
            )),
          ),
        ));
  }

  @override
  void initState() {
    d.log('SignUp initState');
    super.initState();
    getUserDetails();
    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    d.log('SignUp initState 2');

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));

    _cityScrollController.addListener(_scrollListener);
    _areaScrollController.addListener(_areaScrollListener);
    d.log('SignUp initState 3');
    callApi();
    d.log('SignUp initState 4');

    // mobileC = TextEditingController();
    // nameC = TextEditingController();
    // altMobC = TextEditingController();
    // pincodeC = TextEditingController();
    addressC = TextEditingController();
    // stateC = TextEditingController();
    // countryC = TextEditingController();
    // landmarkC = TextEditingController();

//for test ansi =============================
    // if (widget.update!) {
    // User item = addressList[widget.index!];

    //   mobileC!.text = item.mobile!;
    //   nameC!.text = item.name!;
    //   altMobC!.text = item.altMob!;
    //   landmarkC!.text = item.landmark!;
    //   pincodeC!.text = item.pincode!;
    //   addressC!.text = item.address!;
    // stateC!.text = item.state!;
    // countryC!.text = item.country!;
    //   stateC!.text = item.state!;
    // latitude = item.latitude;
    // longitude = item.longitude;
    // selectedCity = item.city!;
    // selectedArea = item.area!;
    // selAreaPos = int.parse(item.region_id!);
    // selCityPos = int.parse(item.city_id!);
    //   type = item.type;
    //   city = item.cityId;
    //   area = item.areaId;

    //   if (type!.toLowerCase() == HOME.toLowerCase()) {
    //     selectedType = 1;
    //   } else if (type!.toLowerCase() == OFFICE.toLowerCase()) {
    //     selectedType = 2;
    //   } else {
    //     selectedType = 3;
    //   }

    //   checkedDefault = item.isDefault == '1' ? true : false;
    // } else {

    getCurrentLoc();
    getType();
    // }

    generateReferral();
  }

  _scrollListener() async {
    if (_cityScrollController.offset >= _cityScrollController.position.maxScrollExtent && !_cityScrollController.position.outOfRange) {
      if (mounted) {
        setState(() {});

        cityState!(() {
          isLoadingMoreCity = true;
          _isProgress = true;
        });
        await getCities(false);
      }
    }
  }

  _areaScrollListener() async {
    if (_areaScrollController.offset >= _areaScrollController.position.maxScrollExtent && !_areaScrollController.position.outOfRange) {
      if (mounted) {
        areaState!(() {
          isLoadingMoreArea = true;
        });
        await getArea(city, false, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: _isNetworkAvail
            ? Stack(
                children: [
                  backBtn(),
                  Image.asset(
                    'assets/images/doodle.png',
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                    color: colors.primary,
                  ),
                  getLoginContainer(),
                  getLogo(),
                ],
              )
            : noInternet(context));
  }

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    try {
      var data = {
        REFERCODE: refer,
      };
      apiBaseHelper.postAPICall(validateReferalApi, data).then((getdata) {
        bool error = getdata["error"];

        if (!error) {
          referCode = refer;
          REFER_CODE = refer;
          if (mounted) setState(() {});
        } else {
          if (count < 5) generateReferral();
          count++;
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      });
    } on TimeoutException catch (_) {}
  }

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      top: MediaQuery.of(context).size.height * 0.1,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width * 0.95,
          color: Theme.of(context).colorScheme.white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      registerTxt(),
                      setUserName(),
                      setMerchantCommName(),
                      setType(),
                      setPass(),
                      setEmail(),
                      setAddress(),
                      setCities(),
                      setArea(),
                      verifyBtn(),
                      loginTxt(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - 50,
      top: (MediaQuery.of(context).size.height * 0.1) - 50,
      child: SizedBox(
        width: 100,
        height: 100,
        child: SvgPicture.asset(
          'assets/images/loginlogo_numo.svg',
        ),
      ),
    );
  }
}
