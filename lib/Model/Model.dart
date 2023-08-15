// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:intl/intl.dart';

import '../Helper/String.dart';
import 'Section_Model.dart';

class Model {
  String? slider_id,
      product_id,
      prodAttValue_id,
      sliderType_id,
      sliderType_value,
      type_id,
      slider_image,
      slider_tilte,
      start_date,
      end_date,
      store_id,
      id,
      type,
      typeId,
      // merchantType_id,
      // merchantType_name,
      image,
      fromTime,
      lastTime,
      title,
      desc,
      status,
      email,
      date,
      msg,
      uid;
  // prodId,
  // varId;
  bool? is_deliverable;
  var list;
  String? name, banner;
  List<attachment>? attach;
  var SliderType, Childern;

  Model(
      {this.slider_id,
      this.sliderType_id,
      this.sliderType_value,
      this.type_id,
      this.slider_image,
      this.slider_tilte,
      this.start_date,
      this.end_date,
      this.store_id,
      this.SliderType,
      this.Childern,
      this.id,
      this.type,
      this.typeId,
      // this.merchantType_id,
      // this.merchantType_name,
      this.image,
      this.name,
      this.banner,
      this.list,
      this.title,
      this.fromTime,
      this.desc,
      this.email,
      this.status,
      this.lastTime,
      this.msg,
      this.attach,
      this.uid,
      this.date,
      this.product_id,
      this.is_deliverable,
      this.prodAttValue_id});

  factory Model.fromSlider(Map<String, dynamic> parsedJson) {
    // log('parsedJson = $parsedJson');
    // log(' parsedJson[SliderType]= ');
    // var temp = parsedJson['SliderType']['];
    // log(temp.toString());
    var type = parsedJson[SLIDERTYPE][SLIDERTYPE_VALUE];

    // log('fromSlider type=$type');
    var listContent = parsedJson[CHILDERN];

    if (listContent == null || listContent.isEmpty) {
      listContent = [];
    } else {
      // log('listContent = $listContent');
      // listContent = listContent[0];
      if (type == "categories") {
        listContent = Product.fromCat(listContent);
      } else if (type == "products") {
        listContent = Product.fromJson(listContent);
      }
    }

    return Model(
        slider_id: parsedJson[SLIDER_ID].toString(),
        sliderType_id: parsedJson[SLIDERTYPE_ID].toString(),
        type_id: parsedJson[TYPE_ID].toString(),
        slider_image: parsedJson[SLIDER_IMAGE],
        slider_tilte: parsedJson[SLIDER_TITLE],
        start_date: parsedJson[START_DATE],
        end_date: parsedJson[END_DATE],
        store_id: parsedJson[STORE_ID].toString(),
        SliderType: parsedJson[SLIDERTYPE],
        Childern: parsedJson[CHILDERN]!,
        id: parsedJson[ID],
        image: parsedJson[IMAGE],
        type: parsedJson[TYPE],
        // typeId: parsedJson[TYPE_ID].toString(),
        list: listContent);
  }

  factory Model.fromTimeSlot(Map<String, dynamic> parsedJson) {
    return Model(id: parsedJson[ID], name: parsedJson[TITLE], fromTime: parsedJson[FROMTIME], lastTime: parsedJson[TOTIME]);
  }

  factory Model.fromTicket(Map<String, dynamic> parsedJson) {
    String date = parsedJson[DATE_CREATED];
    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return Model(
        id: parsedJson[ID],
        title: parsedJson[SUB],
        desc: parsedJson[DESC],
        typeId: parsedJson[TICKET_TYPE],
        email: parsedJson[EMAIL],
        status: parsedJson[STATUS],
        date: date,
        type: parsedJson[TIC_TYPE]);
  }

  factory Model.fromSupport(Map<String, dynamic> parsedJson) {
    return Model(
      id: parsedJson[ID],
      title: parsedJson[TITLE],
    );
  }

  factory Model.fromChat(Map<String, dynamic> parsedJson) {
    //var listContent = parsedJson["attachments"];

    List<attachment> attachList;
    var listContent = (parsedJson["attachments"] as List?);
    if (listContent == null || listContent.isEmpty) {
      attachList = [];
    } else {
      attachList = listContent.map((data) => attachment.setJson(data)).toList();
    }

    String date = parsedJson[DATE_CREATED];

    date = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(date));
    return Model(
        id: parsedJson[ID],
        title: parsedJson[TITLE],
        msg: parsedJson[MESSAGE],
        uid: parsedJson[USER_ID],
        name: parsedJson[NAME],
        date: date,
        attach: attachList);
  }

  factory Model.setAllCat(String id, String name) {
    return Model(
      id: id,
      name: name,
    );
  }

  factory Model.checkDeliverable(Map<String, dynamic> parsedJson) {
    return Model(product_id: parsedJson[PRODUCT_ID], prodAttValue_id: parsedJson[PRODATTVALUE_ID], is_deliverable: parsedJson[IS_DELIVERABLE]);
  }
}

class attachment {
  String? media, type;

  attachment({this.media, this.type});

  factory attachment.setJson(Map<String, dynamic> parsedJson) {
    return attachment(
      media: parsedJson[MEDIA],
      type: parsedJson[ICON],
    );
  }
}
