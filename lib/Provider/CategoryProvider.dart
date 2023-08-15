// ignore_for_file: non_constant_identifier_names

import 'package:numo/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';

class CategoryProvider extends ChangeNotifier {
  List<Product>? _subList = [];
  List<Product>? _Childern = [];
  int _curCat = 0;

  get subList => _subList;
  get Childern => _Childern;

  get curCat => _curCat;

  setCurSelected(int index) {
    _curCat = index;
    notifyListeners();
  }

  setSubList(List<Product>? subList) {
    _subList = subList;
    notifyListeners();
  }

  setChildern(List<Product>? Childern) {
    _Childern = Childern;
    notifyListeners();
  }
}
