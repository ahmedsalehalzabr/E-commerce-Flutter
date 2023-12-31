// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';
import 'dart:core';
import 'dart:developer';
import 'package:numo/Helper/Constant.dart';
import 'package:numo/Helper/Session.dart';
import 'package:numo/Provider/SettingProvider.dart';
import 'package:numo/Screen/Map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/String.dart';
import '../Model/User.dart';
import 'Cart.dart';
import 'HomePage.dart';

class AddAddress extends StatefulWidget {
  final bool? update;
  final int? index;

  const AddAddress({Key? key, this.update, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateAddress();
  }
}

String? latitude, longitude, state, pincode, country, city, region;

class StateAddress extends State<AddAddress> with TickerProviderStateMixin {
  String? merchantAddress_id,
      merchant_id,
      merchantAddress_name,
      mobile,
      alternate_mobile,
      merchantAddress_address,
      city_id,
      region_id,
      country_id,
      latitude,
      longitude,
      is_default,
      company_id,
      landmark,
      altMob,
      type = 'Home',
      isDefault,
      selectedArea = '',
      selectedCity = '';

  bool checkedDefault = false, isArea = false;
  bool _isProgress = false;
  StateSetter? areaState, cityState;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Cityy> cityList = [];
  List<Regionn> areaList = [];
  List<Regionn> areaSearchList = [];
  List<Cityy> citySearchLIst = [];
  bool cityLoading = true, areaLoading = true;
  TextEditingController? nameC, mobileC, pincodeC, addressC, landmarkC, stateC, countryC, altMobC;
  int? selectedType = 1;

  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  FocusNode? nameFocus, monoFocus, almonoFocus, addFocus, landFocus, locationFocus = FocusNode();
  Regionn? selArea;
  int? selAreaPos = -1, selCityPos = -1;
  int cityOffset = 0, areaOffset = 0;
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final ScrollController _cityScrollController = ScrollController();
  final ScrollController _areaScrollController = ScrollController();

  bool? isLoadingMoreCity, isLoadingMoreArea;

  @override
  void initState() {
    super.initState();
    log('add adresses');

    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

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
    callApi();
    mobileC = TextEditingController();
    nameC = TextEditingController();
    altMobC = TextEditingController();
    pincodeC = TextEditingController();
    addressC = TextEditingController();
    stateC = TextEditingController();
    countryC = TextEditingController();
    landmarkC = TextEditingController();

    if (widget.update!) {
      User item = addressList[widget.index!];

      mobileC!.text = item.mobile!;
      nameC!.text = item.merchantAddress_name!;
      altMobC!.text = item.alternate_mobile!;
      landmarkC!.text = item.landmark ?? '==';
      pincodeC!.text = item.pincode!;
      addressC!.text = item.merchantAddress_address!;
      stateC!.text = item.state!;
      countryC!.text = item.Country!.country_name!;
      stateC!.text = item.state!;
      latitude = item.latitude;
      longitude = item.longitude;
      selectedCity = item.City!.city_name!;
      selectedArea = item.Region!.region_name!;
      selAreaPos = int.parse(item.city_id!);
      selCityPos = int.parse(item.region_id!);
      type = item.type;
      city_id = item.city_id;
      region_id = item.region_id;

      // if (type!.toLowerCase() == HOME.toLowerCase()) {
      //   selectedType = 1;
      // } else if (type!.toLowerCase() == OFFICE.toLowerCase()) {
      //   selectedType = 2;
      // } else {
      //   selectedType = 3;
      // }

      checkedDefault = item.is_default == '1' ? true : false;
    } else {
      getCurrentLoc();
    }
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
        await getArea(city_id, false, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'ADDRESS_LBL')!, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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
      ),
    );
  }

  addBtn() {
    return AppBtn(
      title: widget.update! ? getTranslated(context, 'UPDATEADD') : getTranslated(context, 'ADDADDRESS'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () {
        validateAndSubmit();
      },
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      checkNetwork();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      if (city_id == null || city_id!.isEmpty) {
        setSnackbar(getTranslated(context, 'cityWarning')!, context);
      } else if (region_id == null || region_id!.isEmpty) {
        setSnackbar(getTranslated(context, 'areaWarning')!, context);
      } else if (latitude == null || longitude == null) {
        setSnackbar(getTranslated(context, 'locationWarning')!, context);
      } else {
        return true;
      }
    }
    return false;
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      addNewAddress();
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

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  setUserName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            focusNode: nameFocus,
            controller: nameC,
            textCapitalization: TextCapitalization.words,
            validator: (val) => validateUserName(val!, getTranslated(context, 'USER_REQUIRED'), getTranslated(context, 'USER_LENGTH')),
            onSaved: (String? value) {
              merchantAddress_name = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, nameFocus!, monoFocus);
            },
            style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'NAME_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'NAME_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setMobileNo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: mobileC,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            focusNode: monoFocus,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => validateMob(val!, getTranslated(context, 'MOB_REQUIRED'), getTranslated(context, 'VALID_MOB')),
            onSaved: (String? value) {
              mobile = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, monoFocus!, almonoFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'MOBILEHINT_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'MOBILEHINT_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
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
                    Radius.circular(
                      5.0,
                    ),
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

                                await getArea(city_id, true, true);
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
                      selAreaPos = index;
                      Navigator.of(context).pop();

                      selArea = areaSearchList[selAreaPos!];
                      log('selArea =$selArea');
                      region_id = selArea!.region_id;
                      // pincodeC!.text = "----"; //selArea!.pincode!;
                      selectedArea = areaSearchList[selAreaPos!].region_name!;
                    },
                  );

                  getArea(city_id, false, true);
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
                      isArea = false;
                      selCityPos = index;
                      selAreaPos = null;
                      selArea = null;
                      // pincodeC!.text = '';
                      Navigator.of(context).pop();
                    },
                  );
                }
                city_id = citySearchLIst[selCityPos!].city_id;

                selectedCity = citySearchLIst[selCityPos!].city_name;
                getArea(city_id, true, true);
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

  setCities() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                    border: InputBorder.none,
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
                            Text(selCityPos != null && selCityPos != -1 ? selectedCity! : city ?? '',
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
      padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                  decoration: InputDecoration(fillColor: Theme.of(context).colorScheme.white, isDense: true, border: InputBorder.none),
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
                            Text(selAreaPos != null && selAreaPos != -1 ? selectedArea! : region ?? '',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                  focusNode: addFocus,
                  controller: addressC,
                  validator: (val) => validateField(val!, getTranslated(context, 'FIELD_REQUIRED')),
                  onSaved: (String? value) {
                    merchantAddress_address = value;
                  },
                  onFieldSubmitted: (v) {
                    _fieldFocusChange(context, addFocus!, locationFocus);
                  },
                  decoration: InputDecoration(
                    label: Text(getTranslated(context, 'ADDRESS_LBL')!),
                    fillColor: Theme.of(context).colorScheme.white,
                    isDense: true,
                    hintText: getTranslated(context, 'ADDRESS_LBL'),
                    border: InputBorder.none,
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
                        List<Placemark> placemark =
                            await placemarkFromCoordinates(double.parse(latitude!), double.parse(longitude!), localeIdentifier: 'ar');

                        var address;
                        address = placemark[0].name;
                        address = address + ',' + placemark[0].subLocality;
                        address = address + ',' + placemark[0].locality;

                        state = placemark[0].administrativeArea;
                        country = placemark[0].country;

                        if (mounted) {
                          setState(() {
                            countryC!.text = country!;
                            stateC!.text = state!;
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

  setPincode() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: pincodeC,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSaved: (String? value) {},
              decoration: InputDecoration(
                  label: Text(getTranslated(context, 'PINCODEHINT_LBL')!),
                  fillColor: Theme.of(context).colorScheme.white,
                  isDense: true,
                  hintText: getTranslated(context, 'PINCODEHINT_LBL'),
                  border: InputBorder.none),
            )),
      ),
    );
  }

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      await getCities(false);
      if (widget.update!) {
        getArea(addressList[widget.index!].cityId, false, false);
      }
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
      apiBaseHelper.getNumoAPICall(getNumoCitiesApi, {}, null).then((data) async {
        // bool error = getdata['error'];
        // String? msg = getdata['message'];
        // if (!error) {
        // var data = getdata['data'];
        // log('getCities data=$data');
        cityList = (data as List).map((data) => Cityy.fromJson(data)).toList();
        citySearchLIst.addAll(cityList);
        // } else {
        //   if (msg != null) {
        //     setSnackbar(msg, context);
        //   }
        // }
        cityLoading = false;
        isLoadingMoreCity = false;
        _isProgress = false;
        cityOffset += perPage;
        if (mounted && cityState != null) cityState!(() {});
        if (mounted) setState(() {});

        if (widget.update!) {
          selCityPos = citySearchLIst.indexWhere((f) => f.city_id == addressList[widget.index!].city_id);

          if (selCityPos == -1) {
            selCityPos = null;
          }
          // selectedCity = citySearchLIst[selCityPos!].city_name!;
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<void> getArea(String? city_id, bool clear, bool isSearchArea) async {
    try {
      var data = {ID: city_id, OFFSET: areaOffset.toString(), LIMIT: perPage.toString()};

      if (isSearchArea) {
        data[SEARCH] = _areaController.text;
        data[OFFSET] = '0';
        areaSearchList.clear();
      }

      apiBaseHelper.getNumoAPICall(getNumoRegionByCityApi, {}, city_id).then((data) {
        // bool error = getdata['error'];
        // String? msg = getdata['message'];

        // if (!error) {
        // var data = getdata['data'];
        areaList.clear();
        if (clear) {
          region_id = null;
          selArea = null;
        }
        areaList = (data as List).map((data) => Regionn.fromJson(data)).toList();

        areaSearchList.addAll(areaList);

        if (widget.update!) {
          for (User item in addressList) {
            for (int i = 0; i < areaSearchList.length; i++) {
              if (areaSearchList[i].region_id == item.region_id) {
                selArea = areaSearchList[i];
                selAreaPos = i;
                selectedArea = areaSearchList[selAreaPos!].region_name!;
              }
            }
          }
        }
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
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  setLandmark() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: landFocus,
      controller: landmarkC,
      style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
      validator: (val) => validateField(val!, getTranslated(context, 'FIELD_REQUIRED')),
      onSaved: (String? value) {
        landmark = value;
      },
      decoration: const InputDecoration(
        hintText: LANDMARK,
      ),
    );
  }

  setStateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: stateC,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
            readOnly: false,
            onChanged: (v) => setState(() {
              state = v;
            }),
            onSaved: (String? value) {
              state = value;
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'STATE_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'STATE_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setCountry() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: countryC,
            readOnly: false,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
            onSaved: (String? value) {
              country = value;
            },
            validator: (val) => validateField(val!, getTranslated(context, 'FIELD_REQUIRED')),
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'COUNTRY_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'COUNTRY_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  Future<void> addNewAddress() async {
    if (mounted) {
      setState(() {
        _isProgress = true;
      });
    }

    try {
      var data = {
        MERCHANT_ID: context.read<SettingProvider>().merchant_id,
        MERCHANTADDRESS_NAME: merchantAddress_name,
        MOBILE: mobile,
        PINCODE: pincodeC!.text,
        CITY_ID: city_id,
        REGION_ID: region_id,
        MERCHANTADDRESS_ADDRESS: merchantAddress_address,
        STATE: state,
        COUNTRY_ID: country,
        // TYPE: type,
        IS_DEFAULT: checkedDefault.toString() == 'true' ? '1' : '0',
        LATITUDE: latitude,
        LONGITUDE: longitude
      };
      if (widget.update!) data[MERCHANTADDRESS_ID] = addressList[widget.index!].merchantAddress_id;
      // apiBaseHelper.postNumoAPICall(widget.update! ? updateAddressApi : getAddAddressApi, data).then((getdata) async {
      if (widget.update!) {
        apiBaseHelper.putNumoAPICall(postNumoMerchantAddressApi, data, data[MERCHANTADDRESS_ID]).then((data) async {
          // bool error = getdata['error'];
          // String? msg = getdata['message'];

          await buttonController!.reverse();

          // if (!error) {
          // var data = getdata['data'];

          if (checkedDefault.toString() == 'true' || addressList.length == 1) {
            for (User i in addressList) {
              i.is_default = '0';
            }

            addressList[widget.index!].is_default = '1';

            if (!ISFLAT_DEL) {
              if (oriPrice < double.parse(addressList[selectedAddress!].freeAmt!)) {
                delCharge = double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                delCharge = 0;
              }

              totalPrice = totalPrice - delCharge;
            }

            User value = User.fromAddress(data[0]);

            addressList[widget.index!] = value;

            selectedAddress = widget.index;
            selAddress = addressList[widget.index!].id;

            if (!ISFLAT_DEL) {
              if (oriPrice < double.parse(addressList[selectedAddress!].freeAmt!)) {
                delCharge = double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                delCharge = 0;
              }
              totalPrice = totalPrice + delCharge;
            }
          }

          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
          Navigator.of(context).pop();
          // } else {
          //   setSnackbar(msg!, context);
          // }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } else {
        apiBaseHelper.postNumoAPICall(postNumoMerchantAddressApi, data).then((data) async {
          // bool error = getdata['error'];
          // String? msg = getdata['message'];

          await buttonController!.reverse();

          // if (!error) {
          // var data = getdata['data'];

          User value = User.fromAddress(data[0]);
          addressList.add(value);

          if (checkedDefault.toString() == 'true' || addressList.length == 1) {
            for (User i in addressList) {
              i.is_default = '0';
            }

            addressList[widget.index!].is_default = '1';

            if (!ISFLAT_DEL && addressList.length != 1) {
              if (oriPrice < double.parse(addressList[selectedAddress!].freeAmt!)) {
                delCharge = double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                delCharge = 0;
              }

              totalPrice = totalPrice - delCharge;
            }

            selectedAddress = widget.index;
            selAddress = addressList[widget.index!].id;

            if (!ISFLAT_DEL) {
              if (totalPrice < double.parse(addressList[selectedAddress!].freeAmt!)) {
                delCharge = double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                delCharge = 0;
              }
              totalPrice = totalPrice + delCharge;
            }
          }

          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
          Navigator.of(context).pop();
          // } else {
          //   setSnackbar(msg!, context);
          // }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    mobileC?.dispose();
    nameC?.dispose();
    stateC?.dispose();
    countryC?.dispose();
    altMobC?.dispose();
    landmarkC?.dispose();
    addressC!.dispose();
    pincodeC?.dispose();

    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  typeOfAddress() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                child: Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      groupValue: selectedType,
                      activeColor: Theme.of(context).colorScheme.fontColor,
                      value: 1,
                      onChanged: (dynamic val) {
                        if (mounted) {
                          setState(() {
                            selectedType = val;
                            type = HOME;
                          });
                        }
                      },
                    ),
                    Expanded(child: Text(getTranslated(context, 'HOME_LBL')!))
                  ],
                ),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      selectedType = 1;
                      type = HOME;
                    });
                  }
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                child: Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      groupValue: selectedType,
                      activeColor: Theme.of(context).colorScheme.fontColor,
                      value: 2,
                      onChanged: (dynamic val) {
                        if (mounted) {
                          setState(() {
                            selectedType = val;
                            type = OFFICE;
                          });
                        }
                      },
                    ),
                    Expanded(child: Text(getTranslated(context, 'OFFICE_LBL')!))
                  ],
                ),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      selectedType = 2;
                      type = OFFICE;
                    });
                  }
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                child: Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      groupValue: selectedType,
                      activeColor: Theme.of(context).colorScheme.fontColor,
                      value: 3,
                      onChanged: (dynamic val) {
                        if (mounted) {
                          setState(() {
                            selectedType = val;
                            type = OTHER;
                          });
                        }
                      },
                    ),
                    Expanded(child: Text(getTranslated(context, 'OTHER_LBL')!))
                  ],
                ),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      selectedType = 3;
                      type = OTHER;
                    });
                  }
                },
              ),
            )
          ],
        ));
  }

  defaultAdd() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: SwitchListTile(
          value: checkedDefault,
          activeColor: Theme.of(context).colorScheme.primary,
          dense: true,
          onChanged: (newValue) {
            if (mounted) {
              setState(() {
                checkedDefault = newValue;
              });
            }
          },
          title: Text(
            getTranslated(context, 'DEFAULT_ADD')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.lightBlack, fontWeight: FontWeight.bold),
          ),
        ));
  }

  _showContent() {
    return Form(
        key: _formkey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      setUserName(),
                      setMobileNo(),
                      setAddress(),
                      setCities(),
                      setArea(),
                      setPincode(),
                      setStateField(),
                      setCountry(),
                      typeOfAddress(),
                      defaultAdd(),
                    ],
                  ),
                ),
              ),
            ),
            saveButton(getTranslated(context, 'SAVE_LBL')!, () {
              validateAndSubmit();
            }),
          ],
        ));
  }

  Future<void> areaSearch(String searchText) async {
    areaSearchList.clear();
    for (int i = 0; i < areaList.length; i++) {
      Regionn map = areaList[i];

      if (map.region_name!.toLowerCase().contains(searchText)) {
        areaSearchList.add(map);
      }
    }

    if (mounted) areaState!(() {});
  }

  Future<void> getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();

    List<Placemark> placemark = await placemarkFromCoordinates(double.parse(latitude!), double.parse(longitude!), localeIdentifier: 'ar');

    log('placemark[0] = ${placemark[0]}');

    state = placemark[0].administrativeArea;
    country = placemark[0].country;
    city = placemark[0].administrativeArea;
    region = placemark[0].subLocality;
    pincode = placemark[0].postalCode;

    if (mounted) {
      setState(() {
        countryC!.text = country!;
        stateC!.text = state!;
        pincodeC!.text = pincode!;
      });
    }
  }

  Widget saveButton(String title, VoidCallback? onBtnSelected) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: MaterialButton(
              height: 45.0,
              textColor: Theme.of(context).colorScheme.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              onPressed: onBtnSelected,
              color: colors.primary,
              child: Text(
                title,
                style: const TextStyle(color: colors.whiteTemp, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
