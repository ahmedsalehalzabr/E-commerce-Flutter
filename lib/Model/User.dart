// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:numo/Helper/String.dart';
import 'package:intl/intl.dart';

class User {
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
      pincode,
      // createdBy,
      // modifiedBy,
      // createdAt,
      // updatedAt,
      username,
      userProfile,
      email,
      address,
      dob,
      merchantType_id,
      merchantType_name,
      city,
      // city_id,
      city_name,
      // region_id,
      region_name,
      area,
      street,
      password,
      merchantUser_pincode,
      fcmId,
      // latitude,
      // longitude,
      userId,
      name,
      deliveryCharge,
      freeAmt;

  List<String>? imgList;
  Countryy? Country;
  Cityy? City;
  Regionn? Region;
  String? id, date, comment, rating;

  String? type, altMob, landmark, areaId, cityId, state, country;

  User(
      {this.merchantAddress_id,
      this.merchant_id,
      this.merchantAddress_name,
      this.mobile,
      this.alternate_mobile,
      this.merchantAddress_address,
      this.city_id,
      this.region_id,
      this.country_id,
      this.latitude,
      this.longitude,
      this.is_default,
      this.company_id,
      this.pincode,
      this.merchantType_id,
      this.merchantType_name,
      this.Country,
      this.City,
      this.Region,
      // this.id,
      // this.id,
      // this.id,
      this.id,
      this.username,
      this.userProfile,
      this.date,
      this.rating,
      this.comment,
      this.email,
      this.address,
      this.dob,
      this.city,
      this.city_name,
      this.region_name,
      this.area,
      this.street,
      this.password,
      this.merchantUser_pincode,
      this.fcmId,
      this.userId,
      this.name,
      this.type,
      this.altMob,
      this.landmark,
      this.areaId,
      this.cityId,
      this.imgList,
      this.state,
      this.deliveryCharge,
      this.freeAmt,
      this.country});

  factory User.forReview(Map<String, dynamic> parsedJson) {
    String date = parsedJson['data_added'];
    var allSttus = parsedJson['images'];
    List<String> item = [];

    for (String i in allSttus) {
      item.add(i);
    }

    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));

    return User(
        id: parsedJson[ID],
        date: date,
        rating: parsedJson[RATING],
        comment: parsedJson[COMMENT],
        imgList: item,
        username: parsedJson[USER_NAME],
        userProfile: parsedJson["user_profile"],
        userId: parsedJson["user_id"]);
  }

  factory User.fromMerchantType(Map<String, dynamic> parsedJson) {
    return User(
      merchantType_id: parsedJson[MERCHANTTYPE_ID].toString(),
      merchantType_name: parsedJson[MERCHANTTYPE_NAME],
    );
  }
  factory User.fromJson(Map<String, dynamic> parsedJson) {
    // log('parsedJson = $parsedJson');
    return User(
      id: parsedJson[ID],
      username: parsedJson[USERNAME],
      email: parsedJson[EMAIL],
      mobile: parsedJson[MOBILE],
      address: parsedJson[ADDRESS],
      city: parsedJson[CITY],
      area: parsedJson[AREA],
      city_id: parsedJson[CITY_ID].toString(),
      city_name: parsedJson[CITY_NAME],
      region_id: parsedJson[REGION_ID].toString(),
      region_name: parsedJson[REGION_NAME],
      merchantUser_pincode: parsedJson[MERCHANTUSER_PINCODE],
      fcmId: parsedJson[FCM_ID],
      latitude: parsedJson[LATITUDE],
      longitude: parsedJson[LONGITUDE],
      userId: parsedJson[USER_ID],
      name: parsedJson[NAME],
    );
  }

  factory User.fromAddress(Map<String, dynamic> parsedJson) {
    var ctry = parsedJson[COUNTRY] != null ? Countryy.fromJson(parsedJson[COUNTRY]) : null;
    var city = parsedJson[CITY] != null ? Cityy.fromJson(parsedJson[CITY]) : null;
    var region = parsedJson[REGION] != null ? Regionn.fromJson(parsedJson[REGION]) : null;

    return User(
      merchantAddress_id: parsedJson[MERCHANTADDRESS_ID].toString(),
      merchant_id: parsedJson[MERCHANT_ID].toString(),
      merchantAddress_name: parsedJson[MERCHANTADDRESS_NAME],
      mobile: parsedJson[MOBILE].toString(),
      alternate_mobile: parsedJson[ALTERNATE_MOBILE].toString(),
      merchantAddress_address: parsedJson[MERCHANTADDRESS_ADDRESS],
      country_id: parsedJson[COUNTRY_ID].toString(),
      city_id: parsedJson[CITY_ID].toString(),
      region_id: parsedJson[REGION_ID].toString(),
      latitude: parsedJson[LATITUDE],
      longitude: parsedJson[LONGITUDE],
      pincode: parsedJson[PINCODE],
      is_default: parsedJson[IS_DEFAULT].toString(),
      company_id: parsedJson[COMPANY_ID].toString(),
      Country: ctry,
      City: city,
      Region: region,
      // id: parsedJson[ID],
      // address: parsedJson[ADDRESS],
      // altMob: parsedJson[ALT_MOBNO],
      // cityId: parsedJson[CITY_ID],
      // areaId: parsedJson[AREA_ID],
      // area: parsedJson[AREA],
      // city: parsedJson[CITY],
      // city_name: parsedJson[CITY_NAME],
      // region_name: parsedJson[REGION_NAME],
      landmark: 'landmark', //parsedJson[LANDMARK],
      state: 'state', //parsedJson[STATE],
      merchantUser_pincode: 'pincode', //parsedJson[MERCHANTUSER_PINCODE],
      // country: parsedJson[COUNTRY],
      userId: parsedJson[USER_ID],
      // name: parsedJson[NAME],
      type: parsedJson[TYPE],
      deliveryCharge: parsedJson[DEL_CHARGES],
      freeAmt: parsedJson[FREE_AMT],
      // isDefault: parsedJson[ISDEFAULT].toString()
    );
  }
}

class Countryy {
  String? country_id, country_name, country_code, country_call;

  Countryy({this.country_id, this.country_name, this.country_code, this.country_call});
  factory Countryy.fromJson(Map<String, dynamic> parsedJson) {
    return Countryy(
      country_id: parsedJson[COUNTRY_ID].toString(),
      country_name: parsedJson[COUNTRY_NAME],
      country_code: parsedJson[COUNTRY_CODE].toString(),
      country_call: parsedJson[COUNTRY_CALL].toString(),
    );
  }
}

class Cityy {
  String? city_id, city_name, city_code;

  Cityy({this.city_id, this.city_name, this.city_code});
  factory Cityy.fromJson(Map<String, dynamic> parsedJson) {
    return Cityy(
      city_id: parsedJson[CITY_ID].toString(),
      city_name: parsedJson[CITY_NAME],
      city_code: parsedJson[CITY_CODE].toString(),
    );
  }
}

class Regionn {
  String? region_id, region_name, region_code;

  Regionn({this.region_id, this.region_name, this.region_code});
  factory Regionn.fromJson(Map<String, dynamic> parsedJson) {
    return Regionn(
      region_id: parsedJson[REGION_ID].toString(),
      region_name: parsedJson[REGION_NAME],
      region_code: parsedJson[REGION_CODE].toString(),
    );
  }
}

class MerchantSession {
  int? sessionId;
  String? deviceSN;
  String? deviceIMEI;
  String? deviceModel;
  String? deviceBrand;
  String? deviceOS;
  String? deviceOSVersion;
  String? sessionClientType;
  String? sessionClientVersion;
  String? sessionLoginDate;
  String? sessionLastActiveDate;
  int? sessionStatus;
  int? sessionVerified;
  int? active;
  int? companyId;
  int? merchantUserId;

  MerchantSession({
    this.sessionId,
    this.deviceSN,
    this.deviceIMEI,
    this.deviceModel,
    this.deviceBrand,
    this.deviceOS,
    this.deviceOSVersion,
    this.sessionClientType,
    this.sessionClientVersion,
    this.sessionLoginDate,
    this.sessionLastActiveDate,
    this.sessionStatus,
    this.sessionVerified,
    this.active,
    this.companyId,
    this.merchantUserId,
  });

  MerchantSession.fromJson(Map<String, dynamic> json) {
    sessionId = json[SESSION_ID];
    deviceSN = json[DEVICE_SN];
    deviceIMEI = json[DEVICE_IMEI];
    deviceModel = json[DEVICE_MODEL];
    deviceBrand = json[DEVICE_BRAND];
    deviceOS = json[DEVICE_OS];
    deviceOSVersion = json[DEVICE_OSVERSION];
    sessionClientType = json[SESSION_CLIENTTYPE];
    sessionClientVersion = json[SESSION_CLIENTVERSION];
    sessionLoginDate = json[SESSION_LOGINDATE];
    sessionLastActiveDate = json[SESSION_LASTACTIVEDATE];
    sessionStatus = json[SESSION_STATUS];
    sessionVerified = json[SESSION_VERIFIED];
    active = json[ACTIVE];
    companyId = json[COMPANY_ID];
    merchantUserId = json[MERCHANTUSER_ID];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[SESSION_ID] = sessionId;
    data[DEVICE_SN] = deviceSN;
    data[DEVICE_IMEI] = deviceIMEI;
    data[DEVICE_MODEL] = deviceModel;
    data[DEVICE_BRAND] = deviceBrand;
    data[DEVICE_OS] = deviceOS;
    data[DEVICE_OSVERSION] = deviceOSVersion;
    data[SESSION_CLIENTTYPE] = sessionClientType;
    data[SESSION_CLIENTVERSION] = sessionClientVersion;
    data[SESSION_LOGINDATE] = sessionLoginDate;
    data[SESSION_LASTACTIVEDATE] = sessionLastActiveDate;
    data[SESSION_STATUS] = sessionStatus;
    data[SESSION_VERIFIED] = sessionVerified;
    data[ACTIVE] = active;
    data[COMPANY_ID] = companyId;
    data[MERCHANTUSER_ID] = merchantUserId;

    return data;
  }
}

class imgModel {
  int? index;
  String? img;

  imgModel({this.index, this.img});
  factory imgModel.fromJson(int i, String image) {
    return imgModel(index: i, img: image);
  }
}
