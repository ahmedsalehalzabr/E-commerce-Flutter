// ignore_for_file: prefer_typing_uninitialized_variables, unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'Constant.dart';
import 'Session.dart';

class ApiBaseHelper {
  Future<dynamic> postAPICall(Uri url, Map param) async {
    var responseJson;
    try {
      final response = await post(url, body: param.isNotEmpty ? param : null, headers: headers).timeout(const Duration(seconds: timeOut));

      print("param******** = $param");
      print("url******** = $url");
      print("Headers = $headers");
      // print();
      print("response.statusCode = ${response.statusCode}");

      responseJson = _response(response);

      debugPrint('************ START responseJson *************');
      // log(responseJson.toString());
      debugPrint('************ END responseJson ***************');
      // log("responjson****\n$responseJson");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }

    return responseJson;
  }

  Future<dynamic> getNumoAPICall(Uri url, Map<String, dynamic> param, String? id) async {
    var responseJson;
    var token;
    try {
      // log('getNumoAPICall started');
      token = await getNumoToken();

      Map<String, String> numoHeaders = {
        "Authorization": 'Bearer $token',
        "company_id": "$companyID",
        "store_id": "$storeID",
      };

      Uri url2 = url;
      if (id != null && id != '' && id.isNotEmpty) {
        url2 = Uri.parse('${url.toString()}$id');
      }
      url = url2;

      // log('getNumoAPICall no param url=$url');
      url = param.isNotEmpty ? url.replace(queryParameters: param) : url;
      log('getNumoAPICall param = $param  param+url=$url token= $token');
      debugPrint('getNumoAPICall param = $param  param+url=$url token= $token');

      // for (var para in param) {
      //   log(para);
      // }
      // var httpsUri = param!.isNotEmpty
      //     ? Uri(
      //         scheme: url.scheme,
      //         host: url.host,
      //         path: url.path,
      //         queryParameters: param,
      //       )
      //     : url;
      // log('new url httpsUri=$httpsUri');

      final response = await get(url, headers: numoHeaders).timeout(const Duration(seconds: timeOut));

      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    } catch (e) {
      log('ApiBaseHelper getNumoAPICall error =$e');
    }

    return responseJson;
  }

  Future<dynamic> postNumoAPICall(Uri url, Map param) async {
    log('postNumoAPICall 1');
    var responseJson;
    var token;
    try {
      log('postNumoAPICall 2');

      token = await getNumoToken();

      log('postNumoAPICall 3');

      Map<String, String> numoHeaders = {
        "Authorization": 'Bearer $token',
        "company_id": "$companyID",
        "store_id": "$storeID",
        'Content-Type': 'application/json; charset=UTF-8'

        // 'Content-Type': 'application/json; charset=UTF-8',
      };
      debugPrint("param******** = $param");
      debugPrint("numoHeaders******** = $numoHeaders");
      debugPrint("url******** = $url");

      // var body = param.isNotEmpty ? param : null;
      final response =
          await post(url, body: param.isNotEmpty ? jsonEncode(param) : null, headers: numoHeaders).timeout(const Duration(seconds: timeOut));
      // print("numoHeaders*******$numoHeaders");
      // print("POST-NUMO-respon****${response.statusCode}");

      responseJson = _response(response);
      // log('========================== post response======================');

      // log('responseJson = $responseJson');
      // log(' -------------------------------- post response-------------------- ');
      // log("GET-responjson****\n$responseJson");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }

    return responseJson;
  }

  Future<dynamic> putNumoAPICall(Uri url, Map param, String? id) async {
    var responseJson;
    Uri url2 = url;
    var token;
    try {
      token = await getNumoToken();
      Map<String, String> numoHeaders = {
        "Authorization": 'Bearer $token',
        "company_id": "$companyID",
        "store_id": "$storeID",
        'Content-Type': 'application/json; charset=UTF-8'

        // 'Content-Type': 'application/json; charset=UTF-8',
      };
      if (id != null && id != '' && id.isNotEmpty) {
        url2 = Uri.parse('${url.toString()}$id');
      }
      final response =
          await put(url2, headers: numoHeaders, body: param.isNotEmpty ? jsonEncode(param) : null).timeout(const Duration(seconds: timeOut));

      print("param******** = $param");
      print("url******** = $url2");

      // print("numoHeaders*******$numoHeaders");
      // print();
      // print("POST-NUMO-respon****${response.statusCode}");

      responseJson = _response(response);

      // log("GET-responjson****\n$responseJson");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }

    return responseJson;
  }

  Future<dynamic> delNumoAPICall(Uri url, Map param, String? id) async {
    var responseJson;
    var token;
    try {
      token = await getNumoToken();
      Map<String, String> numoHeaders = {
        "Authorization": 'Bearer $token',
        "company_id": "$companyID",
        "store_id": "$storeID",
        // 'Content-Type': 'application/json; charset=UTF-8'

        // 'Content-Type': 'application/json; charset=UTF-8',
      };

      Uri url2 = url;
      if (id != null && id != '' && id.isNotEmpty) {
        url2 = Uri.parse('${url.toString()}$id');
      }
      url = url2;

      final response = await delete(url, headers: numoHeaders).timeout(const Duration(seconds: timeOut));

      // print("numoHeaders*******$numoHeaders");
      // print();
      // print("POST-NUMO-respon****${response.statusCode}");

      responseJson = _response(response);

      // log("GET-responjson****\n$responseJson");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }

    return responseJson;
  }

  dynamic _httpClientResponse(HttpClientResponse response) async {
    switch (response.statusCode) {
      case 200:
      case 201:
        // log(' -----------  response.body.toString() -----------');
        // log(response.body.toString());
        //  response.body.toString().

        // var responseJson = json.decode(response.body.toString());
        var responseJson = response.transform(utf8.decoder).join();

        return responseJson;
      case 400:
        throw BadRequestException(response.transform(utf8.decoder).join());
      case 401:
      case 403:
        throw UnauthorisedException(response.transform(utf8.decoder).join());
      case 500:
      default:
        throw FetchDataException('Error occurred while Communication with Server with StatusCode: ${response.statusCode}');
    }
  }

  dynamic _response(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        // log(' -----------  response.body.toString() -----------');
        // log('response.body.toString()=${response.body.toString()}');
        //  response.body.toString().

        var responseJson = json.decode(response.body.toString());

        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());

      case 401:
        if (response.body.toString().contains('jwt expired')) {
          log('expired token');
        }
        return null;
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException('Error occurred while Communication with Server with StatusCode: ${response.statusCode}');
    }
  }
}

class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    log('ApiBaseHelper CustomExeption error = $_prefix$_message');
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([message]) : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}
