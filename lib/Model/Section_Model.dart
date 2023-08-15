// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:numo/Helper/Constant.dart';
import 'package:numo/Helper/Session.dart';
import 'package:numo/Helper/String.dart';
import 'package:numo/Model/User.dart';
// import 'package:numo/Screen/Favorite.dart';

class SectionModel {
  String? product_id,
      prodAttValue_id,
      cart_id,
      merchant_id,
      currency_id,
      cart_total,
      cart_status,
      cart_ref,
      active,
      company_id,
      cart_location,
      // id,
      // id,
      // id,
      favorite_id,
      cartItem_id,
      cartItem_qty,
      cartItem_price,
      cartItem_notes,
      cartItem_total,

      // id,
      // id,
      // id,
      id,
      title,
      //prodAttValue_id,
      qty,
      productId,
      // perItemPrice,
      style,
      shortDesc,
      taxPercentage
      // taxAmt,
      // netAmt
      ;

  List<Product>? productList;
  ProductAttributeValue? productAttributeValue;
  List<CartItem>? CartItems;
  List<Filter>? filterList;
  List<String>? selectedId = [];
  int? offset, totalItem;

  SectionModel({
    this.product_id,
    this.prodAttValue_id,
    this.active,
    this.CartItems,
    this.cart_id,
    this.merchant_id,
    this.currency_id,
    this.cart_total,
    this.cart_status,
    this.cart_ref,
    this.company_id,
    this.cart_location,
    // this.prodAttValue_id,
    // this.prodAttValue_id,
    this.favorite_id,
    this.cartItem_id,
    this.cartItem_qty,
    this.cartItem_price,
    this.cartItem_notes,
    this.productAttributeValue,
    // this.prodAttValue_id,
    // this.prodAttValue_id,
    // this.prodAttValue_id,

    this.id,
    this.title,
    this.productList,
    //this.prodAttValue_id,
    this.qty,
    this.productId,
    this.cartItem_total,
    // this.perItemPrice,
    this.style,
    this.totalItem,
    this.offset,
    this.selectedId,
    this.filterList,
    this.shortDesc,
    // this.netAmt,
    // this.taxAmt,
    // this.taxPercentage,
  });

  factory SectionModel.fromJson(Map<String, dynamic> parsedJson) {
    // debugPrint(' ================== parsedJson ================== ');
    // try {
    //   // debugPrint(parsedJson.toString());
    // } catch (_) {
    //   debugPrint(_.toString());
    // }
    // debugPrint(' -=-=-=-=-=-=-= parsedJson -=-=-=-=-=-=-=-=- ');
    // try {
    //   for (var key in parsedJson.keys) {
    //     debugPrint(parsedJson[key]);
    //   }
    // } catch (_) {
    //   debugPrint(_.toString());
    // }
    // debugPrint(' ----------------- parsedJson ----------------- ');

    var prods = (parsedJson[PRODUCT_DETAIL] as List);
    List<Product> productList = [];
    if (prods.isEmpty) {
      productList = [];
    } else {
      productList = prods.map((data) => Product.fromJson(data)).toList();
    }

    var cartItems = (parsedJson[CARTITEMS] as List);
    List<CartItem> cartItemsList = [];
    if (cartItems.isEmpty) {
      cartItemsList = [];
    } else {
      cartItemsList = cartItems.map((data) => CartItem.fromJson(data)).toList();
    }

    var flist = (parsedJson[FILTERS] as List);
    List<Filter> filterList = [];
    if (flist.isEmpty) {
      filterList = [];
    } else {
      filterList = flist.map((data) => Filter.fromJson(data)).toList();
    }

    List<String> selected = [];
    return SectionModel(
      prodAttValue_id: parsedJson[PRODATTVALUE_ID].toString(),
      product_id: parsedJson[PRODUCT_ID].toString(),

      cart_id: parsedJson[CART_ID].toString(),
      merchant_id: parsedJson[MERCHANT_ID].toString(),
      currency_id: parsedJson[CURRENCY_ID].toString(),
      cart_total: parsedJson[CART_TOTAL].toString(),
      cart_status: parsedJson[CART_STATUE].toString(),
      cart_ref: parsedJson[CART_REF].toString(),
      active: parsedJson[ACTIVE].toString(),
      company_id: parsedJson[COMPANY_ID].toString(),
      cart_location: parsedJson[CART_LOCATION].toString(),
      CartItems: cartItemsList,
      // id: parsedJson[ID],
      id: parsedJson[ID],
      title: parsedJson[TITLE],
      style: parsedJson[STYLE],
      productList: productList,
      offset: 0,
      totalItem: 0,
      filterList: filterList,
      shortDesc: parsedJson[SHORT_DESC],
      selectedId: selected,
    );
  }

  factory SectionModel.fromCart(Map<String, dynamic> parsedJson) {
    // List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List).map((data) => Product.fromJson(data)).toList();
    // log('SectionModel.fromCart parsedJson=$parsedJson');
    ProductAttributeValue? prodattval =
        parsedJson[PRODUCTATTRIBUTEVALUE] != null ? ProductAttributeValue.fromJson(parsedJson[PRODUCTATTRIBUTEVALUE]) : null;

    int qty = int.parse(parsedJson[CARTITEM_QTY].toString());
    double price = verfiedDouble(parsedJson[CARTITEM_PRICE].toString());

    double total = price > 0 && qty > 0 ? qty * price : 0;

    // return SectionModel(
    //     id: parsedJson[ID],
    //     prodAttValue_id: parsedJson[PRODATTVALUE_ID],
    //     qty: parsedJson[QTY],
    //     perItemTotal: "0",
    //     perItemPrice: "0",
    //     productList: productList,
    //     netAmt: parsedJson[NET_AMOUNT].toString(),
    //     taxAmt: parsedJson[TAX_AMT].toString(),
    //     taxPercentage: parsedJson[TAX_PER].toString());

    return SectionModel(
      cartItem_id: parsedJson[CARTITEM_ID].toString(),
      cart_id: parsedJson[CART_ID].toString(),
      prodAttValue_id: parsedJson[PRODATTVALUE_ID].toString(),
      cartItem_qty: qty.toString(),
      cartItem_price: price.toString(),
      cartItem_total: total.toString(),
      productAttributeValue: prodattval,
      // the following should be added on cart
      // cart_location: parsedJson[CART_LOCATION].toString(),
      // cart_status: parsedJson[CART_STATUE].toString(),

      // netAmt: total.toString(),
      // taxAmt: '0',
      // taxPercentage: '0'
    );
  }

  factory SectionModel.fromFav(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT] as List).map((data) => Product.fromJson(data)).toList();

    return SectionModel(favorite_id: parsedJson[FAVORIATE_ID], product_id: parsedJson[PRODUCT_ID], productList: productList);
  }
}

class Product {
  String? product_id,
      product_name,
      brand_name,
      product_desc,
      product_fullDesc,
      product_canShip,
      productType_id,
      productType_name,
      product_tags,
      product_image,
      product_isFeatured,
      product_taxable,
      SKU,
      barcode,
      maxOrderQty,
      minOrderQty,
      price1,
      price2,
      price3,
      price4,
      old_price,
      retail_price,
      contains,
      unit_id,
      weightUnit_id,
      weight,
      active,
      // weight,
      rating,
      noOfRating,
      // weight,
      // weight,
      // weight,
      // weight,
      catName,
      type,
      attrIds,
      tax,
      categoryId,
      shortDescription,
      qtyStepSize,
      calDisPer;
  List<String>? itemsCounter;
  List<String>? otherImage;
  // List<Product_Varient>? ProductAttributeValues;
  // List<Attribute>? attributeList;

  //?----- Numo ------------
  List<Product>? Categories;
  Brandd? Brand;
  ProductTypee? ProductType;
  List<ProductImage>? ProductImages;
  // List<ProductTypee>? ProductType;
  // List<Attribute>? Attributes;
  List<ProductAttributeValue>? ProductAttributeValues;
  List<ProductValueID>? ProductValueIDs;
  // List<Attribute>? Attributes;

  List<Product>? Childern;

//?-------------------------

  List<String>? selectedId = [];
  List<String>? tagList = [];
  // int? minOrderQuntity;

  String? isFav,
      isReturnable,
      isCancelable,
      isPurchased,
      availability,
      madein,
      indicator,
      stockType,
      cancleTill,
      total,
      banner,
      category_name,
      category_id,
      category_Desc,
      category_image,
      totalAllow,
      video,
      videType,
      warranty,
      gurantee,
      codAllowed,
      is_attch_req;

  String? totalImg;
  List<ReviewImg>? reviewList;

  bool? isFavLoading = false, isFromProd = false;
  int? offset, totalItem, selVarient;

  List<Product>? subList;
  List<Filter>? filterList;
  bool? history = false;

  Product({
    this.product_id,
    this.product_name,
    this.brand_name,
    this.product_desc,
    this.product_fullDesc,
    this.product_image,
    this.product_canShip,
    this.productType_id,
    this.productType_name,
    this.product_tags,
    this.product_isFeatured,
    this.product_taxable,
    this.SKU,
    this.barcode,
    this.minOrderQty,
    this.maxOrderQty,
    this.price1,
    this.price2,
    this.price3,
    this.price4,
    this.old_price,
    this.retail_price,
    this.contains,
    this.unit_id,
    this.weightUnit_id,
    this.weight,
    this.active,
    // this.Attributes,
    this.Brand,
    this.Categories,
    this.ProductImages,
    this.ProductAttributeValues,
    this.ProductValueIDs,
    this.ProductType,
    // this.weight,
    // this.weight,
    this.Childern,
    this.category_name,
    this.category_id,
    this.category_Desc,
    this.category_image,
    // this.weight,
    this.rating,
    this.noOfRating,
    // this.weight,

    this.catName,
    this.type,
    this.otherImage,
    // this.ProductAttributeValues,
    // this.attributeList,
    this.isFav,
    this.isCancelable,
    this.isReturnable,
    this.isPurchased,
    this.availability,
    this.attrIds,
    this.selectedId,
    this.isFavLoading,
    this.indicator,
    this.madein,
    this.tax,
    this.shortDescription,
    this.total,
    this.categoryId,
    this.subList,
    this.filterList,
    this.stockType,
    this.isFromProd,
    this.cancleTill,
    this.totalItem,
    this.offset,
    this.totalAllow,
    this.banner,
    this.selVarient,
    this.video,
    this.videType,
    this.tagList,
    this.warranty,
    this.qtyStepSize,
    this.itemsCounter,
    this.reviewList,
    this.history,
    this.gurantee,
    this.calDisPer,
    this.codAllowed,
    this.is_attch_req,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
//* to avoid null List Brand and ProductType
    var brand = json[BRAND] != null ? Brandd.fromJson(json[BRAND]) : null;
    var prodType = json[PRODUCTTYPE] != null ? ProductTypee.fromJson(json[PRODUCTTYPE]) : null;
    // List<Attribute> attList = [];
    List<ProductImage> productImages = [];
    List<Product> catList = [];
    List<Favoritee> favList = [];
    List<ProductAttributeValue> prodAttributeValues = [];
    List<ProductValueID> productValueIDs = [];
    bool isFav = false;

    var pvids = (json[PRODUCTVALUEIDS] as List?);

    if (pvids == null || pvids.isEmpty) {
      // log('prodAttributeValues == null');
      productValueIDs = [];
    } else {
      productValueIDs = (json[PRODUCTVALUEIDS] as List).map((data) => ProductValueID.fromJson(data)).toList();
    }

    var pav = (json[PRODUCTATTRIBUTEVALUES] as List?);
    if (pav == null || pav.isEmpty) {
      // log('prodAttributeValues == null');
      prodAttributeValues = [];
    } else {
      prodAttributeValues = (json[PRODUCTATTRIBUTEVALUES] as List).map((data) => ProductAttributeValue.fromJson(data)).toList();
    }

    var imgs = (json[PRODUCTIMAGES] as List?);
    // log('json[PRODUCTIMAGES] ${json[PRODUCTIMAGES]}');

    if (imgs == null || imgs.isEmpty) {
      // log('productImages == null');
      productImages = [];
      ProductImage pimg = ProductImage.fromJson({IMAGE_ID: '0', IMAGE_URL: 'empty.png', POSITION: '0'});

      productImages.add(pimg);
    } else {
      productImages = (json[PRODUCTIMAGES] as List).map((data) => ProductImage.fromJson(data)).toList();

      // log('productImages.length =${productImages.length}');
    }

    var favs = (json[FAVORIATES] as List?);

    if (favs == null || favs.isEmpty) {
      // log('catList == null');
      favList = [];
    } else {
      List<Favoritee> favs = (json[FAVORIATES] as List).map((data) => Favoritee.fromJson(data)).toList();
      if (favs.isNotEmpty && CUR_MERCHANTID != null) {
        favList = favs.where((element) => element.merchant_id == CUR_MERCHANTID).toList();
        log('Section_Model favList.length=${favList.length}');
        isFav = favList.isNotEmpty ? true : false;
      }
    }

    var cats = (json[CATEGORIES] as List?);

    if (cats == null || cats.isEmpty) {
      // log('catList == null');
      catList = [];
    } else {
      catList = (json[CATEGORIES] as List).map((data) => Product.fromCat(data)).toList();
    }

    // List<Attribute> attList = [];

    // var flist = (json[FILTERS] as List?);

    List<Filter> filterList = [];

    // if (flist == null || flist.isEmpty) {
    //   filterList = [];
    // } else {
    //   filterList = flist.map((data) => Filter.fromJson(data)).toList();
    // }

    List<String> otherImage = []; //List<String>.from(json[OTHER_IMAGE]);
    List<String> selected = [];

    List<String> tags = []; //List<String>.from(json[TAG]);

//!Max allowed items and steps on cart
    // List<String> items = List<String>.generate(
    //     json[TOTALALOOW] != ""
    //         ? double.parse(json[TOTALALOOW]) ~/ double.parse(json[QTYSTEP])
    //         : 10, (i) {
    //   return ((i + 1) * int.parse(json[QTYSTEP])).toString();
    // });

    List<String> items = List<String>.generate(10, (i) {
      return ((i + 1) * 10).toString();
    });

    var reviewImg = []; // (json[REV_IMG] as List);
    List<ReviewImg> reviewList = [];
    // if (reviewImg.isEmpty) {
    reviewList = [];
    // } else {
    //   reviewList = reviewImg.map((data) => ReviewImg.fromJson(data)).toList();
    // }

    return Product(
      product_id: json[PRODUCT_ID].toString(),
      Brand: brand,
      product_name: json[PRODUCT_NAME],
      brand_name: brand?.brand_name,
      product_desc: json[PRODUCT_DESC],
      product_image: json[PRODUCT_IMAGE],
      product_fullDesc: json[PRODUCT_FULLDESC],
      product_canShip: json[PRODUCT_CANSHIP].toString(),
      productType_id: json[PRODUCTTYPE_ID].toString(),
      productType_name: json['{$PRODUCTTYPE.$PRODUCTTYPE_NAME}'] ?? '',
      product_isFeatured: json[PRODUCT_ISFEATURED].toString(),
      product_taxable: json[PRODUCT_TAXABLE].toString(),
      product_tags: json[PRODUCT_TAGS],
      SKU: json[PRODUCT_SKU].toString(),
      barcode: json[BARCODE],
      maxOrderQty: json[MAXORDERQTY] ?? '10000',
      minOrderQty: json[MINORDERQTY] ?? '1',
      price1: json[PRICE1].toString(),
      price2: json[PRICE2].toString(),
      price3: json[PRICE3].toString(),
      price4: json[PRICE4].toString(),
      old_price: json[OLD_PRICE].toString(),
      retail_price: json[RETAIL_PRICE].toString(),
      contains: json[CONTAINS].toString(),
      unit_id: json[UNIT_ID].toString(),
      weightUnit_id: json[WEIGHTUNIT_ID].toString(),
      weight: json[WEIGHT].toString(),
      active: json[ACTIVE].toString(),
      // Attributes: attList,
      ProductAttributeValues: prodAttributeValues,
      ProductValueIDs: productValueIDs,
      ProductImages: productImages,
      Categories: catList,
      ProductType: prodType,
      isFavLoading: false,

      // ProductImages: json[IMAGE],
      // ProductImages: json[IMAGE],
      rating: '4', //json[RATING],
      noOfRating: '5', //json[NO_OF_RATE],
      selVarient: 0,
      qtyStepSize: "1",
      madein: 'يمني', // json[MADEIN],
      warranty: json[WARRANTY],
      gurantee: json[GAURANTEE],

      // ProductImages: json[IMAGE],
      // ProductImages: json[IMAGE],
      catName: json[CAT_NAME],
      type: json[TYPE],
      isFav: json[FAV].toString(),
      isCancelable: json[ISCANCLEABLE],
      availability: json[ACTIVE].toString(),
      isPurchased: json[ISPURCHASED].toString(),
      isReturnable: json[ISRETURNABLE],
      otherImage: otherImage,
      // ProductAttributeValues: varientList,
      // attributeList: attList,
      filterList: filterList,
      attrIds: json[ATTR_VALUE],
      shortDescription: json[SHORT],
      indicator: json[INDICATOR].toString(),
      stockType: '',
      tax: json[TAX_PER],
      total: json[TOTAL],
      categoryId: json[CATID],
      selectedId: selected,
      totalAllow: json[TOTALALOOW],
      cancleTill: json[CANCLE_TILL],
      video: json[VIDEO],
      videType: json[VIDEO_TYPE],
      tagList: tags,
      itemsCounter: items,
      // minOrderQuntity: int.parse(json[MINORDERQTY]),
      reviewList: reviewList,
      history: false,
      calDisPer: json[CAL_DIS_PER],
      codAllowed: json[COD_ALLOWED], // Cash on Delivery='1'
      is_attch_req: json[IS_ATTACH_REQ],
    );
  }

  factory Product.popular(String? product_name, String product_image) {
    return Product(product_name: product_name, product_image: product_image);
  }

  factory Product.history(String history) {
    return Product(product_name: history, history: true);
  }

  factory Product.fromCat(Map<String, dynamic> parsedJson) {
    String img_url = '${numoImageUrl}empty.png';
    // String? img_url;
    if (parsedJson[CATEGORY_IMAGE] != '' && parsedJson[CATEGORY_IMAGE] != null) {
      img_url = '$numoImageUrl${parsedJson[CATEGORY_IMAGE]}';
    }

    // log(' Section_Model fromCat parsedJson = $parsedJson');
    return Product(
        // id: parsedJson[ID],
        // name: parsedJson[NAME],
        category_image: img_url,
        // banner: parsedJson[BANNER],
        category_id: parsedJson[CATEGORY_ID].toString(),
        category_name: parsedJson[CATEGORY_NAME] ?? '',
        category_Desc: parsedJson[CATEGORY_DESC] ?? '',
        Childern: createSubList(parsedJson[CHILDERN]),
        isFromProd: false,
        offset: 0,
        totalItem: 0,
        // tax: parsedJson[TAX],
        subList: [] // createSubList(parsedJson[CHILDERN]!),
        );
  }

  static List<Product>? createSubList(List? parsedJson) {
    // log('Section_Model createSubList = $parsedJson');
    try {
      if (parsedJson == null) return [];
      if (parsedJson.isEmpty) return [];

      return parsedJson.map((data) => Product.fromCat(data)).toList();
    } catch (e) {
      log('createSubList error =$e');
      return [];
    }
  }
}

class Product_Varient {
  String? id, productId, attribute_value_ids, price, disPrice, type, attr_name, varient_value, availability, cartCount;
  List<String>? images;

  Product_Varient(
      {this.id,
      this.productId,
      this.attr_name,
      this.varient_value,
      this.price,
      this.disPrice,
      this.attribute_value_ids,
      this.availability,
      this.cartCount,
      this.images});

  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    List<String> images = List<String>.from(json[IMAGES]);

    return Product_Varient(
        id: json[ID],
        attribute_value_ids: json[ATTRIBUTE_VALUE_ID],
        productId: json[PRODUCT_ID].toString(),
        attr_name: json[ATTR_NAME],
        varient_value: json[VARIENT_VALUE],
        disPrice: json[DIS_PRICE].toString(),
        price: json[PRICE].toString(),
        availability: json[AVAILABILITY].toString(),
        cartCount: json[CART_COUNT],
        images: images);
  }
}

class ProductAttributeValue {
  String? prodAttValue_id,
      product_id,
      // attributeValue_id,
      // attributeValue_ids,
      title,
      SKU,
      barcode,
      price1,
      price2,
      price3,
      price4,
      old_price,
      retail_price,
      contains,
      unit_id,
      unit_name,
      weightUnit_id,
      weightUnit_name,
      weightUnit_value,
      weight,
      currency_id,
      active,
      cartCount;
  List<AttributeValue>? AttributeValues;
  List<Attribute>? Attributes;
  List<ProductImage>? ProductImages;
  Product? Product2;
  List<SectionModel>? CartItems;

  ProductAttributeValue(
      {this.prodAttValue_id,
      this.product_id,
      this.title,
      this.SKU,
      this.barcode,
      this.price1,
      this.price2,
      this.price3,
      this.price4,
      this.old_price,
      this.contains,
      this.unit_id,
      this.unit_name,
      this.weightUnit_id,
      this.weightUnit_name,
      this.weightUnit_value,
      this.retail_price,
      this.weight,
      this.currency_id,
      this.active,
      this.cartCount,
      this.Attributes,
      this.ProductImages,
      this.AttributeValues,
      this.Product2,
      this.CartItems});

  factory ProductAttributeValue.fromJson(Map<String, dynamic> json) {
    List<AttributeValue>? attvalueList = [];
    List<Attribute>? attList = [];
    List<ProductImage>? imgList = [];
    List<SectionModel>? cartList = [];

    var carts = (json[CARTITEMS] as List?);

    String carCounts = '0';
    if (carts != null && carts.isNotEmpty) {
      cartList = (json[CARTITEMS] as List).map((data) => SectionModel.fromCart(data)).toList();
      carCounts = carts[0]['cartItem_qty'].toString();
    }
    // log('ProductAttributeValue.fromJson json[Attributes].length=${json['Attributes'].length}');

    var attrs = (json[ATTRIBUTES] as List?);

    if (attrs == null || attrs.isEmpty) {
      // log('ProductAttributeValue.fromJson attrs == null');
      attList = [];
    } else {
      // log('ProductAttributeValue.fromJson attrs.length == ${attrs.length}');
      attList = (json[ATTRIBUTES] as List).map((data) => Attribute.fromJson(data)).toList();
    }

    var attval = (json[ATTRIBUTEVALUES] as List?);

    if (attval == null || attval.isEmpty) {
      // log('ProductAttributeValue.fromJson attval == null');
      attvalueList = [];
    } else {
      // log('ProductAttributeValue.fromJson attval.length == ${attval.length}');
      attvalueList = (json[ATTRIBUTEVALUES] as List).map((data) => AttributeValue.fromJson(data)).toList();
    }

    Product? product = json[PRODUCT] != null ? Product.fromJson(json[PRODUCT]) : null;
    String unit = json[UNIT] != null ? json[UNIT][UNIT_NAME] : '';
    String weightName = '';
    String weightValue = '1';
    var weightUnit = json[WEIGHTUNIT];
    if (weightUnit != null) {
      weightName = weightUnit[WEIGHTUNIT_NAME];
      weightValue = weightUnit[WEIGHTUNIT_VALUE].toString();
    }
    var imgs = (json[PRODUCTIMAGES] as List?);

    if (imgs == null || imgs.isEmpty) {
      // log('ProductImage.fromJson imgs == null');
      imgList = [];
    } else {
      // log('ProductImage.fromJson imgs.length == ${imgList.length}');
      imgList = (json[PRODUCTIMAGES] as List).map((data) => ProductImage.fromJson(data)).toList();
    }

    return ProductAttributeValue(
        prodAttValue_id: json[PRODATTVALUE_ID].toString(),
        product_id: json[PRODUCT_ID].toString(),
        // attribute_id: json[ATTRIBUTE_ID].toString(),
        // attributeValue_id: json[ATTRIBUTEVALUE_ID].toString(),
        // attributeValue_ids: json[ATTRIBUTEVALUE_IDS],
        title: json[TITLE],
        SKU: json[PRODUCT_SKU].toString(),
        barcode: json[BARCODE].toString(),
        price1: json[PRICE1].toString(),
        price2: json[PRICE2].toString(),
        price3: json[PRICE3].toString(),
        price4: json[PRICE4].toString(),
        old_price: json[OLD_PRICE].toString(),
        retail_price: json[RETAIL_PRICE].toString(),
        contains: json[CONTAINS].toString(),
        unit_id: json[UNIT_ID].toString(),
        unit_name: unit,
        weightUnit_id: json[WEIGHTUNIT_ID].toString(),
        weightUnit_name: weightName,
        weightUnit_value: weightValue,
        weight: json[WEIGHT].toString(),
        active: json[ACTIVE].toString(),
        cartCount: carCounts.toString(),
        // currency_id: json[CURREN].toString(),
        Attributes: attList,
        AttributeValues: attvalueList,
        ProductImages: imgList,
        Product2: product,
        CartItems: cartList);
  }
}

class Attribute {
  String?
      //  id,
      //name,
      // sValue,
      // sType,
      // value,
      attribute_id,
      attribute_name,
      attributeType_id,
      attributeType_name,
      attributeType_action;

  // List<AttributeType>? AttributeValues;

  Attribute(
      {
      // this.id,
      // this.name,
      // this.sType,
      // this.sValue,
      // this.value,
      this.attribute_id,
      this.attribute_name,
      this.attributeType_id,
      this.attributeType_action,
      this.attributeType_name});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    // log('Attribute.fromJson json=');
    // log('json.toString()=${json.toString()}');
    return Attribute(
      // id: json[ID],
      // value: json[VALUE],
      // name: json[NAME],
      // sValue: json[SVALUE],
      // sType: json[TYPE],
      attribute_id: json[ATTRIBUTE_ID].toString(),
      attribute_name: json[ATTRIBUTE_NAME],
      attributeType_id: json[ATTRIBUTETYPE_ID].toString(),
      attributeType_action: '', // json[ATTRIBUTETYPE_ACTION],
      attributeType_name: '', //json[ATTRIBUTETYPE_NAME],
    );
  }
}

class AttributeValue {
  String? attributeValue_id, attributeValue_name, attributeValue_value, attribute_id, position;

  AttributeValue({
    this.attributeValue_id,
    this.attributeValue_name,
    this.attributeValue_value,
    this.attribute_id,
    this.position,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      attributeValue_id: json[ATTRIBUTEVALUE_ID].toString(),
      attributeValue_name: json[ATTRIBUTEVALUE_NAME],
      attributeValue_value: json[ATTRIBUTEVALUE_VALUE],
      attribute_id: json[ATTRIBUTE_ID].toString(),
      position: json[POSITION].toString(),
    );
  }
}

class ProductValueID {
  String? productValueID_id, prodAttValue_id, attributeValue_id, attribute_id, product_id;

  List<Attribute>? Attributes;
  List<AttributeValue>? AttributeValues;

  ProductValueID({
    this.productValueID_id,
    this.prodAttValue_id,
    this.attributeValue_id,
    this.Attributes,
    this.AttributeValues,
    this.attribute_id,
    this.product_id,
  });

  factory ProductValueID.fromJson(Map<String, dynamic> json) {
    List<Attribute> attList = [];
    List<AttributeValue> attvaluelist = [];

    var attrs = (json[ATTRIBUTES] as List?);

    if (attrs == null || attrs.isEmpty) {
      // log('attList == null');
      attList = [];
    } else {
      attList = (json[ATTRIBUTES] as List).map((data) => Attribute.fromJson(data)).toList();
    }

    var attrvalues = (json[ATTRIBUTEVALUES] as List?);

    if (attrvalues == null || attrvalues.isEmpty) {
      // log('attList == null');
      attvaluelist = [];
    } else {
      attvaluelist = (json[ATTRIBUTEVALUES] as List).map((data) => AttributeValue.fromJson(data)).toList();
    }

    return ProductValueID(
        productValueID_id: json[PRODUCTVALUEID_ID].toString(),
        prodAttValue_id: json[ATTRIBUTEVALUE_ID].toString(),
        attributeValue_id: json[ATTRIBUTEVALUE_ID].toString(),
        attribute_id: json[ATTRIBUTE_ID],
        product_id: json[PRODUCT_ID],
        Attributes: attList,
        AttributeValues: attvaluelist);
  }
}

class Filter {
  String? attributeValues, attributeValId, name, swatchType, swatchValue;

  Filter({this.attributeValues, this.attributeValId, this.name, this.swatchType, this.swatchValue});

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
        attributeValId: json[ATT_VAL_ID], name: json[NAME], attributeValues: json[ATT_VAL], swatchType: json[STYPE], swatchValue: json[SVALUE]);
  }
}

class Brandd {
  String? brand_id, brand_name, brand_desc, brand_image, brand_company;

  Brandd({this.brand_id, this.brand_name, this.brand_desc, this.brand_image, this.brand_company});

  factory Brandd.fromJson(Map<String, dynamic> json) {
    String img_url = '${numoImageUrl}empty.png';
    if (json[BRAND_IMAGE] != '' && json[BRAND_IMAGE] != null) {
      img_url = '$numoImageUrl${json[BRAND_IMAGE]}';
    }

    return Brandd(
        brand_id: json[BRAND_ID].toString(),
        brand_name: json[BRAND_NAME],
        brand_desc: json[BRAND_DESC],
        brand_image: img_url,
        brand_company: json[BRAND_COMPANY]);
  }
}

class ProductImage {
  String? image_id, image_url, position;

  ProductImage({
    this.image_id,
    this.image_url,
    this.position,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    String img_url = '${numoImageUrl}empty.png';
    if (json[IMAGE_URL] != '' && json[IMAGE_URL] != null && json[IMAGE_URL] != 'null') {
      img_url = '$numoImageUrl${json[IMAGE_URL]}';
    }
    return ProductImage(
      image_id: json[IMAGE_ID].toString(),
      image_url: img_url,
      position: json[POSITION].toString(),
    );
  }
}

class ProductTypee {
  String? productType_id, productType_name, productType_desc;
  bool? is_deliverable;

  ProductTypee({
    this.productType_id,
    this.productType_name,
    this.productType_desc,
    this.is_deliverable,
  });

  factory ProductTypee.fromJson(Map<String, dynamic> json) {
    // log('ProductTypee json=$json');
    return ProductTypee(
      productType_id: json[PRODUCTTYPE_ID].toString(),
      productType_name: json[PRODUCTTYPE_NAME],
      productType_desc: json[PRODUCTTYPE_DESC],
      is_deliverable: json[IS_DELIVERABLE] == '1' ? true : false,
    );
  }
}

class Favoritee {
  String? favorite_id, merchant_id, product_id;
  Product? product;
  Favoritee({
    this.favorite_id,
    this.product_id,
    this.merchant_id,
    this.product,
  });

  factory Favoritee.fromJson(Map<String, dynamic> json) {
    Product? pr;

    var prr = json[PRODUCT];

    if (prr != null) {
      pr = Product.fromJson(prr);
    }
    return Favoritee(
      favorite_id: json[FAVORIATE_ID].toString(),
      product_id: json[PRODUCT_ID].toString(),
      merchant_id: json[MERCHANT_ID].toString(),
      product: pr,
    );
  }
}

class ReviewImg {
  String? totalImg;
  List<User>? productRating;

  ReviewImg({this.totalImg, this.productRating});

  factory ReviewImg.fromJson(Map<String, dynamic> json) {
    var reviewImg = (json[PRODUCTRATING] as List);
    List<User> reviewList = [];
    if (reviewImg.isEmpty) {
      reviewList = [];
    } else {
      reviewList = reviewImg.map((data) => User.forReview(data)).toList();
    }

    return ReviewImg(totalImg: json[TOTALIMG], productRating: reviewList);
  }
}

class Promo {
  String? id,
      promoCode,
      message,
      image,
      remainingDays,
      status,
      noOfRepeatUsage,
      maxDiscountAmt,
      discountType,
      noOfUsers,
      minOrderAmt,
      repeatUsage,
      discount,
      endDate,
      startDate;
  bool isExpanded;

  Promo({
    this.id,
    this.promoCode,
    this.message,
    this.startDate,
    this.endDate,
    this.discount,
    this.repeatUsage,
    this.minOrderAmt,
    this.noOfUsers,
    this.discountType,
    this.maxDiscountAmt,
    this.image,
    this.noOfRepeatUsage,
    this.status,
    this.remainingDays,
    this.isExpanded = false,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json[ID],
      promoCode: json[PROMO_CODE],
      message: json[MESSAGE],
      image: json[IMAGE],
      remainingDays: json[REMAIN_DAY],
      discount: json[DISCOUNT],
      discountType: json[DISCOUNT_TYPE],
      endDate: json[END_DATE],
      maxDiscountAmt: json[MAX_DISCOUNT_AMOUNT],
      minOrderAmt: json[MIN_ORDER_AMOUNT],
      noOfRepeatUsage: json[NO_OF_REPEAT_USAGE],
      noOfUsers: json[NO_OF_USERS],
      repeatUsage: json[REPEAT_USAGE],
      startDate: json[START_DATE],
      status: json[STATUS],
    );
  }
}

class CartItem {
  String? cartItem_id, cart_id, prodAttValue_id, cartItem_qty, cartItem_price, cartItem_notes, active;

  ProductAttributeValue? ProductAttributeValuee;

  CartItem({
    this.cart_id,
    this.cartItem_id,
    this.prodAttValue_id,
    this.active,
    this.cartItem_notes,
    this.cartItem_price,
    this.cartItem_qty,
    this.ProductAttributeValuee,
    // this.prodAttValueList
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // log('Attribute.fromJson json=');
    // log('json.toString()=${json.toString()}');
    ProductAttributeValue productAttributeValue = ProductAttributeValue.fromJson(json[PRODUCTATTRIBUTEVALUE]);

    return CartItem(
      cartItem_id: json[CARTITEM_ID].toString(),
      cartItem_notes: json[CARTITEM_NOTES],
      cartItem_price: json[CARTITEM_PRICE].toString(),
      cartItem_qty: json[CARTITEM_QTY].toString(), // json[ATTRIBUTETYPE_ACTION],
      active: json[ACTIVE],
      prodAttValue_id: json[PRODATTVALUE_ID],
      ProductAttributeValuee: productAttributeValue,
    );
  }
}
