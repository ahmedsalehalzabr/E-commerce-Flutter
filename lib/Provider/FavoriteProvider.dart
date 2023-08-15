import 'package:numo/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favList = [];

  bool _isLoading = true;

  get isLoading => _isLoading;

  get favList => _favList;

  get favIdList => _favList.map((fav) => fav.product_id).toList();

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  removeFavItem(String product_id) {
    _favList.removeWhere((item) => item.product_id == product_id);

    notifyListeners();
  }

  addFavItem(Product? item) {
    if (item != null) {
      _favList.add(item);
      notifyListeners();
    }
  }

  setFavlist(List<Product> favList) {
    _favList.clear();
    _favList.addAll(favList);
    notifyListeners();
  }
}
