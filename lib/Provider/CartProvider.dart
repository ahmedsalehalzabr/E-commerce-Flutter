// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:collection/src/iterable_extensions.dart';
import 'package:numo/Model/Section_Model.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<SectionModel> _cartList = [];

  get cartList => _cartList;
  bool _isProgress = false;

  get cartIdList => _cartList.map((crt) => crt.prodAttValue_id).toList();
  // get cartIdList => _cartList.map((fav) => fav.product_id).toList();

  String? qtyList(String id, String vId) {
    try {
      log('CartProvider qtyList id=$id and vId=$vId');
      log('CartProvider qtyList _cartList=${_cartList.length}');

      var prodValueAtt_ids = _cartList.map((e) => e.prodAttValue_id);
      log('CartProvider qtyList prodValueAtt_ids=$prodValueAtt_ids');

      SectionModel? tempId =
          _cartList.firstWhereOrNull((cp) => cp.productAttributeValue!.product_id == id && cp.productAttributeValue!.prodAttValue_id == vId);
      log('CartProvider qtyList tempId=');
      log('$tempId');

      // try {
      //   notifyListeners();
      // } catch (e) {
      //   log('cartProvider qtyList  notifyListeners() error=$e');
      // }

      // log("cartProvider qtyList prodValueAtt_ids=$prodValueAtt_ids  --- tempId.prodAttValue_id=${tempId!.prodAttValue_id} qty=${tempId!.cartItem_qty} ");

      if (tempId?.cartItem_qty != null) {
        log('cartProvider qtyList tempId.prodAttValue_id=${tempId?.prodAttValue_id}   tempId.cartItem_qty=${tempId?.cartItem_qty}');
        return tempId?.cartItem_qty;
      } else {
        return "0";
      }
    } catch (e) {
      log('cartProvider qtyList  error=$e');
      return '0';
    }
  }

  get isProgress => _isProgress;

  setProgress(bool progress) {
    _isProgress = progress;
    notifyListeners();
  }

  removeCartItem(String id) {
    _cartList.removeWhere((item) => item.prodAttValue_id == id);

    notifyListeners();
  }

  addCartItem(SectionModel? item) {
    if (item != null) {
      _cartList.add(item);
      notifyListeners();
    }
  }

  updateCartItem(String? id, String qty, int index, String vId) {
    final i = _cartList.indexWhere((cp) => cp.product_id == id || cp.prodAttValue_id == vId);

    _cartList[i].cartItem_qty = qty;
    _cartList[i].productList![0].ProductAttributeValues![index].cartCount = qty;

    notifyListeners();
  }

  setCartlist(List<SectionModel> cartList) {
    _cartList.clear();
    _cartList.addAll(cartList);
    log('CartProvider setCartlist cartList.length=${cartList.length}');
    notifyListeners();
  }
}
