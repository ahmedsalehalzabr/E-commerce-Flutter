// ignore_for_file: non_constant_identifier_names

import 'dart:developer';
import 'dart:ffi';

import 'package:numo/Helper/String.dart';
import 'package:numo/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider {
  late SharedPreferences _sharedPreferences;

  SettingProvider(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  String? _supportedLocales = '';
  String? get merchantUser_id => _sharedPreferences.getString(MERCHANTUSER_ID);
  String? get merchant_id => _sharedPreferences.getString(MERCHANT_ID);
  String? get merchant_comName => _sharedPreferences.getString(MERCHANT_COMNAME);
  String? get company_id => _sharedPreferences.getString(COMPANY_ID);
  String? get merchantUser_name => _sharedPreferences.getString(MERCHANTUSER_NAME);
  String? get merchant_email => _sharedPreferences.getString(MERCHANT_EMAIL);
  String? get merchantUser_phone1 => _sharedPreferences.getString(MERCHANTUSER_PHONE1);
  bool? get merchantUser_isAdmin => _sharedPreferences.getBool(MERCHANTUSER_ISADMIN);
  String? get merchantUser_location => _sharedPreferences.getString(MERCHANTUSER_LOCATION);
  String? get merchantUser_pincode => _sharedPreferences.getString(MERCHANTUSER_PINCODE);
  String? get parent_id => _sharedPreferences.getString(PARENT_ID);
  String? get accessToken => _sharedPreferences.getString(ACCESS_TOKEN);

  String get merchantUser_image => _sharedPreferences.getString(MERCHANTUSER_IMAGE)!;
  String? get supportedLocales => _supportedLocales;

  void setSupportedLocales(String locale) {
    _supportedLocales = locale;
  }

  setPrefrence(String key, String value) {
    _sharedPreferences.setString(key, value);
  }

  Future<String?> getPrefrence(String key) async {
    return _sharedPreferences.getString(key);
  }

  void setPrefrenceBool(String key, bool value) async {
    _sharedPreferences.setBool(key, value);
  }

  setPrefrenceList(String key, String query) async {
    List<String> valueList = await getPrefrenceList(key);
    if (!valueList.contains(query)) {
      if (valueList.length > 4) valueList.removeAt(0);
      valueList.add(query);

      _sharedPreferences.setStringList(key, valueList);
    }
  }

  Future<List<String>> getPrefrenceList(String key) async {
    return _sharedPreferences.getStringList(key) ?? [];
  }

  Future<bool> getPrefrenceBool(String key) async {
    return _sharedPreferences.getBool(key) ?? false;
  }

  Future<void> clearUserSession(BuildContext context) async {
    CUR_MERCHANTID = null;

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    context.read<UserProvider>().setPincode('');
    userProvider.setMerchantUserName("");
    userProvider.setMerchantUserId("");
    userProvider.setMerchantUserImage("");
    userProvider.setBalance("");
    userProvider.setCartCount("");
    userProvider.setMerchantUserImage("");
    userProvider.setMerchantUserPhone1("");
    userProvider.setMerchantEmail("");
    userProvider.setMerchantComName('');

    await _sharedPreferences.clear();
  }

  Future<void> saveUserDetail(
      String merchant_id,
      String merchantUser_id,
      String? merchantUser_name,
      String? merchant_email,
      String merchantUser_phone1,
      String? city_id,
      String? region_id,
      String? merchantUser_location,
      String? merchantUser_pincode,
      String? latitude,
      String? longitude,
      String? merchantUser_image,
      String? accessToken,
      BuildContext context) async {
    final waitList = <Future<void>>[];
    try {
      waitList.add(_sharedPreferences.setString(MERCHANT_ID, merchant_id));
      waitList.add(_sharedPreferences.setString(MERCHANTUSER_ID, merchantUser_id));
      waitList.add(_sharedPreferences.setString(MERCHANTUSER_NAME, merchantUser_name!));
      waitList.add(_sharedPreferences.setString(MERCHANTUSER_PHONE1, merchantUser_phone1));
      waitList.add(_sharedPreferences.setString(MERCHANT_EMAIL, merchant_email ?? ''));
      waitList.add(_sharedPreferences.setString(CITY_ID, city_id!));
      waitList.add(_sharedPreferences.setString(REGION_ID, region_id!));
      waitList.add(_sharedPreferences.setString(MERCHANTUSER_LOCATION, merchantUser_location ?? ''));
      waitList.add(_sharedPreferences.setString(MERCHANTUSER_PINCODE, merchantUser_pincode ?? ''));
      waitList.add(_sharedPreferences.setString(LATITUDE, latitude ?? ''));
      waitList.add(_sharedPreferences.setString(LONGITUDE, longitude ?? ''));
      waitList.add(_sharedPreferences.setString(MERCHANTUSER_IMAGE, merchantUser_image ?? ''));
      waitList.add(_sharedPreferences.setString(ACCESS_TOKEN, accessToken!));
    } catch (e) {
      log('SettingProvider saveUserDetail 111 error=$e');
    }
    //SharedPreferences prefs = await SharedPreferences.getInstance();

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      userProvider.setMerchantUserName(merchantUser_name ?? '');
      userProvider.setBalance("");
      userProvider.setCartCount("");
      userProvider.setMerchantUserImage(merchantUser_image ?? '');
      userProvider.setMerchantUserPhone1(merchantUser_phone1);
      userProvider.setMerchantEmail(merchant_email ?? '');
      userProvider.setPincode(merchantUser_pincode ?? '');
    } catch (e) {
      log('SettingProvider saveUserDetail 222 error=$e');
    }

    await Future.wait(waitList);
  }
}
