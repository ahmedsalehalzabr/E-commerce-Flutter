import 'dart:developer';

import 'package:numo/Provider/SettingProvider.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _merchantUserName = '', _merchantComName = '', _cartCount = '', _curBal = '', _merchantUserImage = '', _merchantEmail = '';

  String? _merchantUserPhone1 = '';
  String? _merchantUser_id = '';
  String? _merchantId = '';

  String? _curPincode = '';

  late SettingProvider settingsProvider;

  String get curMerchantUserName => _merchantUserName;
  String get curMerchantComName => _merchantComName;

  String get curPincode => _curPincode ?? '';

  String get curCartCount => _cartCount;

  String get curBalance => _curBal;

  String? get curMerchantUserPhone1 => _merchantUserPhone1;

  String get curMerchantUserImage => _merchantUserImage;

  String? get curMerchantUserid => _merchantUser_id;

  String? get curMerchantId => _merchantId;

  String get curMerchantEmail => _merchantEmail;

  void setPincode(String pin) {
    _curPincode = pin;
    // notifyListeners();
  }

  void setCartCount(String count) {
    _cartCount = count;
    // notifyListeners();
  }

  void setBalance(String bal) {
    _curBal = bal;
    // notifyListeners();
  }

  void setMerchantUserName(String count) {
    // log('userProvider setMerchantUserName _merchantUserName=$count');

    // settingsProvider.merchantUser_name != count;
    _merchantUserName = count;
    // notifyListeners();
  }

  void setMerchantComName(String count) {
    // settingsProvider.merchant_comName != count;
    _merchantComName = count;
    // notifyListeners();
  }

  void setMerchantUserPhone1(String? count) {
    // log('userProvider setMerchantUserPhone1 _merchantUserPhone1=$count');
    _merchantUserPhone1 = count;
    // notifyListeners();
  }

  void setMerchantUserImage(String count) {
    _merchantUserImage = count;
    // notifyListeners();
  }

  void setMerchantEmail(String email) {
    _merchantEmail = email;
    // notifyListeners();
  }

  void setMerchantUserId(String? count) {
    // settingsProvider.merchantUser_id != count;
    _merchantUser_id = count;
  }

  void setMerchantId(String? count) {
    // settingsProvider.merchant_id != count;
    _merchantId = count;
  }
}
