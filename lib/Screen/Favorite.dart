import 'dart:async';
import 'dart:developer';

import 'package:numo/Helper/SqliteData.dart';
import 'package:numo/Provider/CartProvider.dart';
import 'package:numo/Provider/FavoriteProvider.dart';
import 'package:numo/Provider/UserProvider.dart';
import 'package:numo/Screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'Product_Detail.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateFav();
}

class StateFav extends State<Favorite> with TickerProviderStateMixin {
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isProgress = false, _isFavLoading = true;
  List<String>? proIds;
  var db = DatabaseHelper();
  final List<TextEditingController> _controller = [];

  @override
  void initState() {
    super.initState();

    callApi();

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
  }

  callApi() async {
    if (CUR_MERCHANTID != null) {
      _getFav();
    } else {
      proIds = (await db.getFav())!;
      _getOffFav();
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    for (int i = 0; i < _controller.length; i++) {
      _controller[i].dispose();
    }
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
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
                _getFav();
              } else {
                await buttonController!.reverse();
              }
            });
          },
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(getTranslated(context, 'FAVORITE')!, context),
        body: _isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showContent(context),
                  showCircularProgress(_isProgress, colors.primary),
                ],
              )
            : noInternet(context));
  }

  Widget listItem(int index, List<Product> favList) {
    Product model = favList[index];
    if (index < favList.length && favList.isNotEmpty) {
      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }
      return Selector<CartProvider, Tuple2<List<String?>, String?>>(
          builder: (context, data, child) {
            log('Favorite listItem data=$data');

            double price = 0;
            double old_price = 0;
            double off = 0;

            if (model.ProductAttributeValues![model.selVarient!].price1 != null &&
                model.ProductAttributeValues![model.selVarient!].price1!.isNotEmpty) {
              price = verfiedDouble(model.ProductAttributeValues![model.selVarient!].price1);
            }

            if (model.ProductAttributeValues![model.selVarient!].old_price != null &&
                model.ProductAttributeValues![model.selVarient!].old_price!.isNotEmpty) {
              old_price = verfiedDouble(model.ProductAttributeValues![model.selVarient!].old_price);
            }

            if (price == 0) {
              if (model.price1!.isEmpty || model.price1 == 'null') {
                price = verfiedDouble('1');
              } else {
                price = verfiedDouble(model.price1!);
              }
            }

            if (old_price == 0) {
              off = 0;
              model.old_price = "0";
            }

            if (old_price > price && price != 0) {
              off = (old_price - price).toDouble();
              off = off * 100 / price;
            }

            /*if (CUR_MERCHANTID == null) {
                model
                    .ProductAttributeValues![model.selVarient!]
                    .cartCount = snapshot.data!;
                _controller[index].text = snapshot.data!.toString();
              } else {
                _controller[index].text = model
                    .ProductAttributeValues![model.selVarient!]
                    .cartCount!;
              }*/

            if (data.item1.contains(model.ProductAttributeValues![model.selVarient!].prodAttValue_id)) {
              _controller[index].text = data.item2.toString();
            } else {
              if (CUR_MERCHANTID != null) {
                _controller[index].text = model.ProductAttributeValues![model.selVarient!].cartCount!;
              } else {
                _controller[index].text = "0";
              }
            }

            if (_controller.length < index + 1) {
              _controller.add(TextEditingController());
            }

            return Padding(
                padding: EdgeInsetsDirectional.only(bottom: index == (favList.length - 1) ? 18.0 : 10, top: 10, start: 8, end: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Card(
                      elevation: 0.1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        splashColor: colors.primary.withOpacity(0.2),
                        onTap: () {
                          // Product model = model;
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => ProductDetail(
                                      model: model,
                                      secPos: 0,
                                      index: index,
                                      list: true,
                                    )),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Hero(
                                tag: "$index${model.product_id}",
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                    child: Stack(
                                      children: [
                                        FadeInImage(
                                          image: NetworkImage(model.ProductImages![0].image_url!),
                                          height: 100.0,
                                          width: 100.0,
                                          fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                          imageErrorBuilder: (context, error, stackTrace) => erroWidget(125),
                                          placeholder: placeHolder(125),
                                        ),
                                        Positioned.fill(
                                            child: model.active == "0"
                                                ? Container(
                                                    height: 55,
                                                    color: Theme.of(context).colorScheme.white70,
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(
                                                      child: Text(
                                                        getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                                                        style: Theme.of(context).textTheme.caption!.copyWith(
                                                              color: Colors.red,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  )
                                                : Container()),
                                        off != 0
                                            ? Container(
                                                decoration: BoxDecoration(color: colors.red, borderRadius: BorderRadius.circular(10)),
                                                margin: const EdgeInsets.all(5),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    "${off.toStringAsFixed(0)}%",
                                                    style: const TextStyle(color: colors.whiteTemp, fontWeight: FontWeight.bold, fontSize: 9),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ))),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.only(right: 5, top: 5.0),
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      child: Icon(
                                        Icons.close,
                                        color: Theme.of(context).colorScheme.lightBlack,
                                      ),
                                      onTap: () {
                                        if (CUR_MERCHANTID != null) {
                                          _removeFav(index, favList, context);
                                        } else {
                                          setState(() {
                                            db.addAndRemoveFav(model.product_id!, false);
                                            context.read<FavoriteProvider>().removeFavItem(model.ProductAttributeValues![0].prodAttValue_id!);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              model.product_name!,
                                              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )),
                                  Padding(
                                      padding: const EdgeInsetsDirectional.only(start: 8.0, top: 5.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            '${getPriceFormat(context, price)!} ',
                                            style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            old_price != 0 ? getPriceFormat(context, old_price)! : "",
                                            style: Theme.of(context).textTheme.overline!.copyWith(
                                                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.6),
                                                decoration: TextDecoration.lineThrough,
                                                letterSpacing: 0.7),
                                          ),
                                        ],
                                      )),
                                  _controller[index].text != "0"
                                      ? Row(
                                          children: [
                                            model.active == "0"
                                                ? Container()
                                                : cartBtnList
                                                    ? Row(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              InkWell(
                                                                child: Card(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(50),
                                                                  ),
                                                                  child: const Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Icon(
                                                                      Icons.remove,
                                                                      size: 15,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  if (_isProgress == false && (int.parse(_controller[index].text) > 0)) {
                                                                    removeFromCart(index, favList, context);
                                                                  }
                                                                },
                                                              ),
                                                              SizedBox(
                                                                width: 26,
                                                                height: 20,
                                                                child: Stack(
                                                                  children: [
                                                                    Selector<CartProvider, Tuple2<List<String?>, String?>>(
                                                                      builder: (context, data, child) {
                                                                        return TextField(
                                                                          textAlign: TextAlign.center,
                                                                          readOnly: true,
                                                                          style:
                                                                              TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.fontColor),
                                                                          controller: _controller[index],
                                                                          decoration: const InputDecoration(
                                                                            border: InputBorder.none,
                                                                          ),
                                                                        );
                                                                      },
                                                                      selector: (_, provider) => Tuple2(
                                                                          provider.cartIdList,
                                                                          provider.qtyList(model.product_id!,
                                                                              model.ProductAttributeValues![model.selVarient!].prodAttValue_id!)),
                                                                    ),
                                                                    PopupMenuButton<String>(
                                                                      tooltip: '',
                                                                      icon: const Icon(
                                                                        Icons.arrow_drop_down,
                                                                        size: 1,
                                                                      ),
                                                                      onSelected: (String value) {
                                                                        if (_isProgress == false) {
                                                                          addToCart(index, favList, context, value, 2);
                                                                        }
                                                                      },
                                                                      itemBuilder: (BuildContext context) {
                                                                        return model.itemsCounter!.map<PopupMenuItem<String>>((String value) {
                                                                          return PopupMenuItem(
                                                                              value: value,
                                                                              child: Text(value,
                                                                                  style: TextStyle(color: Theme.of(context).colorScheme.fontColor)));
                                                                        }).toList();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              InkWell(
                                                                child: Card(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(50),
                                                                  ),
                                                                  child: const Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      size: 15,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  if (_isProgress == false) {
                                                                    addToCart(
                                                                        index,
                                                                        favList,
                                                                        context,
                                                                        (int.parse(model.ProductAttributeValues![model.selVarient!].cartCount!) +
                                                                                int.parse(model.qtyStepSize!))
                                                                            .toString(),
                                                                        2);
                                                                  }
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.directional(
                        textDirection: Directionality.of(context),
                        bottom: -13,
                        end: 15,
                        child: InkWell(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.0),
                                color: Theme.of(context).colorScheme.white,
                                boxShadow: const [
                                  BoxShadow(offset: Offset(2, 2), blurRadius: 12, color: Color.fromRGBO(0, 0, 0, 0.13), spreadRadius: 0.4)
                                ]),
                            child: const Icon(
                              Icons.shopping_cart,
                              size: 20,
                              color: colors.primary,
                            ),
                          ),
                          onTap: () async {
                            if (_isProgress == false) {
                              addToCart(index, favList, context, (int.parse(_controller[index].text) + int.parse(model.qtyStepSize!)).toString(), 1);
                            }
                          },
                        ))
                  ],
                ));
          },
          selector: (_, provider) =>
              Tuple2(provider.cartIdList, provider.qtyList(model.product_id!, model.ProductAttributeValues![0].prodAttValue_id!)));
    } else {
      return Container();
    }
  }

  Future<void> _getOffFav() async {
    if (proIds!.isNotEmpty) {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        try {
          var parameter = {"product_ids": proIds!.join(',')};

          apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              List<Product> tempList = (data as List).map((data) => Product.fromJson(data)).toList();

              context.read<FavoriteProvider>().setFavlist(tempList);
            }
            if (mounted) {
              setState(() {
                context.read<FavoriteProvider>().setLoading(false);
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          context.read<FavoriteProvider>().setLoading(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
            context.read<FavoriteProvider>().setLoading(false);
          });
        }
      }
    } else {
      context.read<FavoriteProvider>().setFavlist([]);
      setState(() {
        context.read<FavoriteProvider>().setLoading(false);
      });
    }
  }

  Future _getFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_MERCHANTID != null) {
        Map<String, dynamic> parameter = {
          MERCHANT_ID: CUR_MERCHANTID,
        };

        apiBaseHelper.getNumoAPICall(getNumoFavsApi, parameter, null).then((getdata) {
          List<Product> prods = [];
          // log('HomePage - _getFav getdata=$getdata');
          if (getdata != null) {
            List<Favoritee> favTemp = (getdata as List).map((data) => Favoritee.fromJson(data)).toList();

            for (var pr in favTemp) {
              if (pr.merchant_id == CUR_MERCHANTID) {
                prods.add(pr.product!);
              }
            }

            log('HomePage - _getFav prods.length=${prods.length}');

            context.read<FavoriteProvider>().setFavlist(prods);
          }

          context.read<FavoriteProvider>().setLoading(false);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          context.read<FavoriteProvider>().setLoading(false);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> addToCart(int index, List<Product> favList, BuildContext context, String qty, int from) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_MERCHANTID != null) {
        try {
          if (mounted) {
            setState(() {
              _isProgress = true;
            });
          }
          String qty = (int.parse(favList[index].ProductAttributeValues![0].cartCount!) + int.parse(favList[index].qtyStepSize!)).toString();

          if (int.parse(qty) < int.parse(favList[index].minOrderQty!)) {
            qty = favList[index].minOrderQty.toString();
            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
          }

          var parameter = {
            PRODATTVALUE_ID: favList[index].ProductAttributeValues![favList[index].selVarient!].prodAttValue_id,
            USER_ID: CUR_MERCHANTID,
            QTY: qty,
          };
          apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              String? qty = data['total_quantity'];

              context.read<UserProvider>().setCartCount(data['cart_count']);
              favList[index].ProductAttributeValues![0].cartCount = qty.toString();
              var cart = getdata["cart"];
              List<SectionModel> cartList = (cart as List).map((cart) => SectionModel.fromCart(cart)).toList();
              context.read<CartProvider>().setCartlist(cartList);
            } else {
              setSnackbar(msg!, context);
            }
            if (mounted) {
              setState(() {
                _isProgress = false;
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        }
      } else {
        setState(() {
          _isProgress = true;
        });

        if (from == 1) {
          db.insertCart(
              favList[index].product_id!, favList[index].ProductAttributeValues![favList[index].selVarient!].prodAttValue_id!, qty, context);
        } else {
          if (int.parse(qty) > favList[index].itemsCounter!.length) {
            setSnackbar("Max Quantity is-${int.parse(qty) - 1}", context);
          } else {
            db.updateCart(favList[index].product_id!, favList[index].ProductAttributeValues![favList[index].selVarient!].prodAttValue_id!, qty);
          }
        }
        setState(() {
          _isProgress = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  removeFromCart(int index, List<Product> favList, BuildContext context) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_MERCHANTID != null) {
        if (mounted) {
          setState(() {
            _isProgress = true;
          });
        }

        int qty;

        qty = (int.parse(_controller[index].text) - int.parse(favList[index].qtyStepSize!));

        if (qty < int.parse(favList[index].minOrderQty!)) {
          qty = 0;
        }

        var parameter = {
          PRODATTVALUE_ID: favList[index].ProductAttributeValues![favList[index].selVarient!].prodAttValue_id,
          USER_ID: CUR_MERCHANTID,
          QTY: qty.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            favList[index].ProductAttributeValues![favList[index].selVarient!].cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List).map((cart) => SectionModel.fromCart(cart)).toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          setState(() {
            _isProgress = false;
          });
        });
      } else {
        setState(() {
          _isProgress = true;
        });

        int qty;

        qty = (int.parse(_controller[index].text) - int.parse(favList[index].qtyStepSize!));

        if (qty < int.parse(favList[index].minOrderQty!)) {
          qty = 0;

          db.removeCart(favList[index].ProductAttributeValues![favList[index].selVarient!].prodAttValue_id!, favList[index].product_id!, context);
        } else {
          db.updateCart(
              favList[index].product_id!, favList[index].ProductAttributeValues![favList[index].selVarient!].prodAttValue_id!, qty.toString());
        }
        setState(() {
          _isProgress = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  _removeFav(
    int index,
    List<Product> favList,
    BuildContext context,
  ) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (mounted) {
        setState(() {
          _isProgress = true;
        });
      }
      try {
        var parameter = {
          MERCHANT_ID: CUR_MERCHANTID,
          PRODUCT_ID: favList[index].product_id,
        };

        apiBaseHelper.delNumoAPICall(postNumoFavoriteApi, parameter, null).then((getdata) {
          if (getdata != null) {
            context.read<FavoriteProvider>().removeFavItem(favList[index].ProductAttributeValues![favList[index].selVarient!].prodAttValue_id!);
          }

          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });

        // apiBaseHelper.postAPICall(removeFavApi, parameter).then((getdata) {
        //   bool error = getdata["error"];
        //   String? msg = getdata["message"];
        //   if (!error) {
        //     context.read<FavoriteProvider>().removeFavItem(favList[index].ProductAttributeValues![0].prodAttValue_id!);
        //   } else {
        //     setSnackbar(msg!, context);
        //   }
        //   if (mounted) {
        //     setState(() {
        //       _isProgress = false;
        //     });
        //   }
        // }, onError: (error) {
        //   setSnackbar(error.toString(), context);
        // });

      } on TimeoutException catch (_) {
        _isProgress = false;
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future _refresh() async {
    if (mounted) {
      setState(() {
        _isFavLoading = true;
      });
    }
    if (CUR_MERCHANTID != null) {
      return _getFav();
    } else {
      proIds = (await db.getFav())!;
      return _getOffFav();
    }
  }

  _showContent(BuildContext context) {
    return Selector<FavoriteProvider, Tuple2<bool, List<Product>>>(
        builder: (context, data, child) {
          return data.item1
              ? shimmer(context)
              : data.item2.isEmpty
                  ? Center(child: Text(getTranslated(context, 'noFav')!))
                  : RefreshIndicator(
                      color: colors.primary,
                      key: _refreshIndicatorKey,
                      onRefresh: _refresh,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          // controller: controller,
                          itemCount: data.item2.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return listItem(index, data.item2);
                          },
                        ),
                      ));
        },
        selector: (_, provider) => Tuple2(provider.isLoading, provider.favList));
  }
}
