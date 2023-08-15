// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as d;

import 'dart:math';
import 'dart:ui';

import 'package:numo/Helper/AppBtn.dart';
import 'package:numo/Helper/SimBtn.dart';
import 'package:numo/Helper/Slideanimation.dart';
import 'package:numo/Helper/SqliteData.dart';
import 'package:numo/Provider/CartProvider.dart';
import 'package:numo/Provider/FavoriteProvider.dart';
import 'package:numo/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tuple/tuple.dart';

import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'HomePage.dart';
import 'Product_Detail.dart';
import 'Search.dart';

class ProductList extends StatefulWidget {
  final String? category_name, category_id;
  final bool? tag, fromSeller;
  final int? dis;

  const ProductList({Key? key, this.category_id, this.category_name, this.tag, this.fromSeller, this.dis}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  List<Product> productList = [];
  List<Product> tempList = [];

  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  var filterList;
  String minPrice = "0", maxPrice = "0";
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;

  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  final List<TextEditingController> _controller = [];
  List<String>? tagList = [];
  ChoiceChip? tagChip, choiceChip;
  RangeValues? _currentRangeValues;
  var db = DatabaseHelper();
  AnimationController? _animationController;
  AnimationController? _animationController1;
  late StateSetter setStater;

  String query = '';

  final TextEditingController _controller1 = TextEditingController();
  bool notificationisnodata = false;

  FocusNode searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  final SpeechToText speech = SpeechToText();

  String lastStatus = '';
  String _currentLocaleId = '';
  String lastWords = '';
  List<LocaleName> _localeNames = [];

  // int _selectedTabIndex = 0;
  // late TabController _tabController;

  @override
  void initState() {
    // d.log('ProductList - initState ');
    d.log('ProductList - initState  CUR_MERCHANTID=$CUR_MERCHANTID');

    super.initState();
    offset = 0;
    controller = ScrollController(keepScrollOffset: true);
    controller.addListener(_scrollListener);
    // d.log('ProductList - initState 222 CUR_MERCHANTID=$CUR_MERCHANTID');

    _controller1.addListener(() {
      if (_controller1.text.isEmpty) {
        setState(() {
          query = '';
          offset = 0;
          isLoadingmore = true;
          getProduct('0');
        });
      } else {
        query = _controller1.text;
        offset = 0;
        notificationisnodata = false;

        if (query.trim().isNotEmpty) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (query.trim().isNotEmpty) {
              isLoadingmore = true;
              offset = 0;
              getProduct('0');
            }
          });
        }
      }
      ScaffoldMessenger.of(context).clearSnackBars();
    });

    getProduct("0");

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _animationController1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

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

    // _tabController = TabController(
    //   length: 5,
    //   vsync: this,
    // );
    // _tabController.addListener(() {
    //   setState(() {
    //     _selectedTabIndex = _tabController.index;
    //   });
    // });
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent && !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(() {
            isLoadingmore = true;
            if (offset < total) getProduct("0");
          });
        }
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    _animationController!.dispose();
    _animationController1!.dispose();
    controller.removeListener(() {});
    _controller1.dispose();
    for (int i = 0; i < _controller.length; i++) {
      _controller[i].dispose();
    }
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      d.log('ProductList - _playAnimation ');
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    d.log('ProductList - build ');

    return Scaffold(
        appBar: widget.fromSeller! ? null : getAppBar(widget.category_name!, context),
        // key: _scaffoldKey,
        body: _isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showForm(),
                  showCircularProgress(_isProgress, colors.primary),
                ],
              )
            : noInternet(context));
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
                offset = 0;
                total = 0;
                getProduct("0");
              } else {
                await buttonController!.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  noIntBtn(BuildContext context) {
    double width = deviceWidth!;
    return Container(
        padding: const EdgeInsetsDirectional.only(bottom: 10.0, top: 50.0),
        child: Center(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: colors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          ),
          onPressed: () {
            Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) => super.widget));
          },
          child: Ink(
            child: Container(
              constraints: BoxConstraints(maxWidth: width / 1.2, minHeight: 45),
              alignment: Alignment.center,
              child: Text(getTranslated(context, 'TRY_AGAIN_INT_LBL')!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.white, fontWeight: FontWeight.normal)),
            ),
          ),
        )));
  }

  Widget listItem(int index) {
    d.log('Product List listItem index=$index');
    List<String> att = [], val = [];

    if (index < productList.length) {
      Product model = productList[index];

      totalProduct = productList.length.toString(); // model.total;

      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }

      List<String> attt = [], vall = [];

      attt.clear();
      vall.clear();

      att.clear();
      val.clear();

      if (model.ProductAttributeValues!.isNotEmpty) {
        for (var prodAttVal in model.ProductAttributeValues!) {
          if (prodAttVal.Attributes!.isNotEmpty) {
            for (var at in prodAttVal.Attributes!) {
              attt.add(at.attribute_name!);
              // d.log('at.attribute_name = ${at.attribute_name}');
            }
          }

          if (prodAttVal.AttributeValues!.isNotEmpty) {
            for (var attVal in prodAttVal.AttributeValues!) {
              vall.add(attVal.attributeValue_name!);
              // d.log(
              //     'attVal.attributeValue_name = ${attVal.attributeValue_name}');
            }
          }
        }

        att = [];
        val = [];

        att = [
          ...{...attt}
        ];
        val = [
          ...{...vall}
        ];
      }

      double price = 0;
      double old_price = 0;
      double off = 0;

      if (model.ProductAttributeValues![model.selVarient!].price1 != null && model.ProductAttributeValues![model.selVarient!].price1!.isNotEmpty) {
        price = verfiedDouble(model.ProductAttributeValues![model.selVarient!].price1);
      }

      if (model.ProductAttributeValues![model.selVarient!].old_price != null &&
          model.ProductAttributeValues![model.selVarient!].old_price!.isNotEmpty) {
        old_price = verfiedDouble(model.ProductAttributeValues![model.selVarient!].old_price);
      }

      d.log(
          'listItem  model.product_name =${model.product_name} --- att[] = ${att.toString()}  val[] = ${val.toString()} -- model.price1= ${model.price1}- old_price=${model.old_price}');

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

      // if (model.ProductImages != null && model.ProductImages!.isNotEmpty) {
      //   // d.log('model.ProductImages![0].image_url! = ${model.ProductImages![0].image_url!}');
      // }

      _controller[index].text = model.ProductAttributeValues![model.selVarient!].cartCount ?? '0';

      d.log('ProductList listItem price = $price and off=$off  _controller[index=$index].text=${_controller[index].text} ');
      try {
        return SlideAnimation(
            position: index,
            itemCount: productList.length,
            slideDirection: SlideDirection.fromBottom,
            animationController: _animationController,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                child: Selector<CartProvider, Tuple2<List<String?>, String?>>(
                  builder: (context, data, child) {
                    d.log('data =$data');
                    if (data.item1.isNotEmpty &&
                        model.ProductAttributeValues != null &&
                        model.ProductAttributeValues!.isNotEmpty &&
                        data.item1.contains(model.ProductAttributeValues![model.selVarient!].prodAttValue_id)) {
                      d.log('if');
                      _controller[index].text = data.item2 ?? '0';
                    } else {
                      // d.log('else');
                      if (CUR_MERCHANTID != null && model.ProductAttributeValues != null && model.ProductAttributeValues!.isNotEmpty) {
                        _controller[index].text = model.ProductAttributeValues![model.selVarient!].cartCount!;
                        d.log('ProductList if else');
                      } else {
                        _controller[index].text = "0";
                        d.log('else else');
                      }
                    }

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          elevation: 10,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Hero(
                                        tag: "$index${model.product_id}",
                                        child: ClipRRect(
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                            child: Stack(
                                              children: [
                                                Image.network(model.ProductImages![0].image_url!,
                                                    width: 125, height: 125, errorBuilder: (context, error, stackTrace) => erroWidget(125)),

                                                //!NetworkImag
                                                // FadeInImage(
                                                //   image: NetworkImage(model
                                                //       .ProductImages![0]
                                                //       .image_url!),
                                                //   height: 125.0,
                                                //   width: 110.0,
                                                //   fit: extendImg
                                                //       ? BoxFit.fill
                                                //       : BoxFit.contain,
                                                //   imageErrorBuilder: (context,
                                                //           error, stackTrace) =>
                                                //       erroWidget(125),
                                                //   placeholder: placeHolder(125),
                                                // ),
                                                Positioned.fill(
                                                    child: model.active! == "0"
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
                                                        decoration: const BoxDecoration(
                                                          color: colors.red,
                                                        ),
                                                        margin: const EdgeInsets.all(5),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(5.0),
                                                          child: Text(
                                                            "${off.toStringAsFixed(0)}%",
                                                            style: const TextStyle(color: colors.whiteTemp, fontWeight: FontWeight.bold, fontSize: 9),
                                                          ),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            ))),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              model.product_name!,
                                              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            model.ProductAttributeValues!.isNotEmpty
                                                ? model.ProductAttributeValues![model.selVarient!].Attributes != null &&
                                                        model.ProductAttributeValues![model.selVarient!].Attributes!.isNotEmpty
                                                    ? ListView.builder(
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: att.length >= 2 ? 2 : att.length,
                                                        itemBuilder: (context, index) {
                                                          return Row(children: [
                                                            Flexible(
                                                              child: Text(
                                                                "${att[index].trim()}:",
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .subtitle2!
                                                                    .copyWith(color: Theme.of(context).colorScheme.lightBlack),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsetsDirectional.only(start: 5.0),
                                                              child: Text(
                                                                val[index],
                                                                maxLines: 1,
                                                                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                                                                    color: Theme.of(context).colorScheme.lightBlack, fontWeight: FontWeight.bold),
                                                              ),
                                                            )
                                                          ]);
                                                        })
                                                    : Container()
                                                : Container(),
                                            model.noOfRating! != "0"
                                                ? Row(
                                                    children: [
                                                      RatingBarIndicator(
                                                        rating: verfiedDouble(model.rating!),
                                                        itemBuilder: (context, index) => const Icon(
                                                          Icons.star_rate_rounded,
                                                          color: Colors.amber,
                                                        ),
                                                        unratedColor: Colors.grey.withOpacity(0.5),
                                                        itemCount: 5,
                                                        itemSize: 18.0,
                                                        direction: Axis.horizontal,
                                                      ),
                                                      Text(
                                                        " (${model.noOfRating!})",
                                                        style: Theme.of(context).textTheme.overline,
                                                      )
                                                    ],
                                                  )
                                                : Container(),
                                            Row(
                                              children: <Widget>[
                                                ImageFiltered(
                                                  imageFilter:
                                                      IS_LOGGINED ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                                  child: Text('${getPriceFormat(context, price)!} ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2!
                                                          .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold)),
                                                ),
                                                ImageFiltered(
                                                    imageFilter:
                                                        IS_LOGGINED ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                                    child: Text(
                                                      model.ProductAttributeValues!.isNotEmpty
                                                          ? verfiedDouble(model.ProductAttributeValues![model.selVarient!].old_price!) != 0
                                                              ? getPriceFormat(context,
                                                                  verfiedDouble(model.ProductAttributeValues![model.selVarient!].old_price!))!
                                                              : ""
                                                          : "",

                                                      // '${getPriceFormat(context, old_price)!} ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .overline!
                                                          .copyWith(decoration: TextDecoration.lineThrough, letterSpacing: 0),
                                                    )),
                                              ],
                                            ),
                                            _controller[index].text != "0"
                                                ? Row(
                                                    children: [
                                                      const Spacer(),
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
                                                                              d.log(' removeFromCart(index) index=$index');
                                                                              removeFromCart(index);
                                                                            }
                                                                          },
                                                                        ),
                                                                        SizedBox(
                                                                          width: 37,
                                                                          height: 20,
                                                                          child: Stack(
                                                                            children: [
                                                                              TextField(
                                                                                textAlign: TextAlign.center,
                                                                                readOnly: true,
                                                                                style: TextStyle(
                                                                                    fontSize: 12, color: Theme.of(context).colorScheme.fontColor),
                                                                                controller: _controller[index],
                                                                                // _controller[index],
                                                                                decoration: const InputDecoration(
                                                                                  border: InputBorder.none,
                                                                                ),
                                                                              ),
                                                                              PopupMenuButton<String>(
                                                                                tooltip: '',
                                                                                icon: const Icon(
                                                                                  Icons.arrow_drop_down,
                                                                                  size: 1,
                                                                                ),
                                                                                onSelected: (String value) {
                                                                                  if (_isProgress == false) {
                                                                                    d.log('addToCart(index, value, 2)');
                                                                                    addToCart(index, value, 2, price.toString());
                                                                                  }
                                                                                },
                                                                                itemBuilder:
                                                                                    //!Max allowed items per carts
                                                                                    (BuildContext context) {
                                                                                  return model.itemsCounter!
                                                                                      .map<PopupMenuItem<String>>((String value) {
                                                                                    return PopupMenuItem(
                                                                                        value: value,
                                                                                        child: Text(value,
                                                                                            style: TextStyle(
                                                                                                color: Theme.of(context).colorScheme.fontColor)));
                                                                                  }).toList();
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        // ),

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
                                                                            d.log(
                                                                                'onTap addToCart _controller[index=$index].text=${_controller[index].text} --- model.qtyStepSize=${model.qtyStepSize} --- _isProgress=$_isProgress');
                                                                            if (_isProgress == false) {
                                                                              addToCart(
                                                                                  index,
                                                                                  (int.parse(_controller[index].text) + int.parse(model.qtyStepSize!))
                                                                                      .toString(),
                                                                                  2,
                                                                                  price.toString());
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
                                    )
                                  ],
                                ),
                              ]),
                            ),
                            onTap: () {
                              Product model = productList[index];
                              d.log('product onTap() product_id= ${model.product_id} index=$index ');

                              //!ProductDetail
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => ProductDetail(
                                          model: model,
                                          index: index,
                                          secPos: 0,
                                          list: true,
                                        )),
                              );
                            },
                          ),
                        ),
                        _controller[index].text == "0" && model.active == '1'
                            ? Positioned.directional(
                                textDirection: Directionality.of(context),
                                bottom: -10,
                                end: 15,
                                child: InkWell(
                                  onTap: () {
                                    if (_isProgress == false) {
                                      //!addToCart
                                      addToCart(index, (int.parse(_controller[index].text) + int.parse(model.qtyStepSize!)).toString(), 1,
                                          price.toString());
                                    }
                                  },
                                  child: Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        Positioned.directional(
                            textDirection: Directionality.of(context),
                            top: -10,
                            end: 15,
                            child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: model.isFavLoading!
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: colors.primary,
                                              strokeWidth: 0.7,
                                            )),
                                      )
                                    : Selector<FavoriteProvider, List<String?>>(
                                        builder: (context, data, child) {
                                          return InkWell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                !data.contains(model.product_id) ? Icons.favorite_border : Icons.favorite,
                                                size: 20,
                                                color: colors.red,
                                              ),
                                            ),
                                            onTap: () {
                                              if (CUR_MERCHANTID != null) {
                                                !data.contains(model.product_id) ? _setFav(-1, model) : _removeFav(-1, model);
                                              } else {
                                                if (!data.contains(model.product_id)) {
                                                  model.isFavLoading = true;
                                                  model.isFav = "1";
                                                  context.read<FavoriteProvider>().addFavItem(model);
                                                  db.addAndRemoveFav(model.product_id!, true);
                                                  model.isFavLoading = false;
                                                } else {
                                                  model.isFavLoading = true;
                                                  model.isFav = "0";
                                                  context
                                                      .read<FavoriteProvider>()
                                                      .removeFavItem(model.ProductAttributeValues![model.selVarient!].prodAttValue_id!);
                                                  db.addAndRemoveFav(model.product_id!, false);
                                                  model.isFavLoading = false;
                                                }
                                                setState(() {});
                                              }
                                            },
                                          );
                                        },
                                        selector: (_, provider) => provider.favIdList,
                                      )))
                      ],
                    );
                  },
                  selector: (_, provider) => Tuple2(
                      provider.cartIdList,
                      provider.qtyList(
                          model.product_id!,
                          model.ProductAttributeValues != null
                              ? model.ProductAttributeValues!.isNotEmpty
                                  ? model.selVarient != null
                                      ? model.ProductAttributeValues![model.selVarient!].prodAttValue_id!
                                      : '0'
                                  : '0'
                              : '0')),
                  // Tuple2(provider.cartIdList, provider.qtyList(model.product_id!, model.product_id!)),
                )));
      } catch (e) {
        d.log('ProductList listItem error =$e');
      }
    }
    return Container();
  }

  _setFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted) {
          setState(() {
            index == -1 ? model.isFavLoading = true : productList[index].isFavLoading = true;
          });
        }

        var parameter = {MERCHANT_ID: CUR_MERCHANTID, PRODUCT_ID: model.product_id};

        apiBaseHelper.postNumoAPICall(postNumoFavoriteApi, parameter).then((getdata) {
          if (getdata != null) {
            index == -1 ? model.isFav = "1" : productList[index].isFav = "1";

            context.read<FavoriteProvider>().addFavItem(model);
          }
          //  else {
          //   setSnackbar(msg!, context);
          // }

          if (mounted) {
            setState(() {
              index == -1 ? model.isFavLoading = false : productList[index].isFavLoading = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });

        // apiBaseHelper.postAPICall(setFavoriteApi, parameter).then((getdata) {
        //   bool error = getdata["error"];
        //   String? msg = getdata["message"];
        //   if (!error) {
        //     index == -1 ? model.isFav = "1" : productList[index].isFav = "1";
        //     context.read<FavoriteProvider>().addFavItem(model);
        //   } else {
        //     setSnackbar(msg!, context);
        //   }
        //   if (mounted) {
        //     setState(() {
        //       index == -1 ? model.isFavLoading = false : productList[index].isFavLoading = false;
        //     });
        //   }
        // }, onError: (error) {
        //   setSnackbar(error.toString(), context);
        // });

      } on TimeoutException catch (_) {
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

  _removeFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted) {
          setState(() {
            index == -1 ? model.isFavLoading = true : productList[index].isFavLoading = true;
          });
        }

        var parameter = {USER_ID: CUR_MERCHANTID, PRODUCT_ID: model.product_id};
        apiBaseHelper.postAPICall(removeFavApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            index == -1 ? model.isFav = "0" : productList[index].isFav = "0";
            context.read<FavoriteProvider>().removeFavItem(model.ProductAttributeValues![model.selVarient!].prodAttValue_id!);
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted) {
            setState(() {
              index == -1 ? model.isFavLoading = false : productList[index].isFavLoading = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
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

  removeFromCart(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_MERCHANTID != null) {
        if (mounted) {
          setState(() {
            _isProgress = true;
          });
        }

        int qty;

        qty = (int.parse(_controller[index].text) - int.parse(productList[index].qtyStepSize!));

        if (qty < int.parse(productList[index].minOrderQty!)) {
          qty = 0;
        }

        try {
          d.log('ProductList removeFromCart qty=$qty productList[index=$index].minOrderQty=${productList[index].minOrderQty}');

          var parameter = {
            PRODATTVALUE_ID: productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id,
            MERCHANT_ID: CUR_MERCHANTID,
            CARTITEM_QTY: qty.toString()
          };

          apiBaseHelper.postNumoAPICall(postNumoCartItemsApi, parameter).then((getdata) {
            // bool error = getdata["error"];
            // String? msg = getdata["message"];
            // if (!error) {
            var data = getdata['rows'][0];
            d.log('ProductList addToCart data=$data');

            // String? qty = data['total_quantity'];
            // String? qty = data[CARTITEM_QTY] ?? '0';
            String? cartCount = getdata[COUNT].toString();
            // CUR_CART_COUNT = data['cart_count'];

            // context.read<UserProvider>().setCartCount(data['cart_count']);
            context.read<UserProvider>().setCartCount(cartCount);

            productList[index].ProductAttributeValues![productList[index].selVarient!].cartCount = qty.toString();

            var cart = data[CARTITEMS];
            List<SectionModel> cartList = (cart as List).map((cart) => SectionModel.fromCart(cart)).toList();
            context.read<CartProvider>().setCartlist(cartList);
            // } else {
            //   setSnackbar(msg!, context);
            // }
            if (mounted) {
              setState(() {
                _isProgress = false;
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
            if (mounted) {
              setState(() {
                _isProgress = false;
              });
            }
          });
        } catch (e) {
          d.log('ProductList addToCart error=$e');
          setSnackbar("${getTranslated(context, 'somethingMSg')}", context);
          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        }

        // apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
        //   bool error = getdata["error"];
        //   String? msg = getdata["message"];
        //   if (!error) {
        //     var data = getdata["data"];
        //     String? qty = data['total_quantity'];
        //     context.read<UserProvider>().setCartCount(data['cart_count']);
        //     productList[index].ProductAttributeValues![productList[index].selVarient!].cartCount = qty.toString();
        //     var cart = getdata["cart"];
        //     List<SectionModel> cartList = (cart as List).map((cart) => SectionModel.fromCart(cart)).toList();
        //     context.read<CartProvider>().setCartlist(cartList);
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
        //   setState(() {
        //     _isProgress = false;
        //   });
        // });

      } else {
        setState(() {
          _isProgress = true;
        });

        int qty;

        qty = (int.parse(_controller[index].text) - int.parse(productList[index].qtyStepSize!));

        if (qty < int.parse(productList[index].minOrderQty!)) {
          qty = 0;
          db.removeCart(
              productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id!, productList[index].product_id!, context);
          context.read<CartProvider>().removeCartItem(productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id!);
        } else {
          context.read<CartProvider>().updateCartItem(productList[index].product_id!, qty.toString(), productList[index].selVarient!,
              productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id!);
          db.updateCart(productList[index].product_id!, productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id!,
              qty.toString());
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

  Future getProduct(String top) async {
    d.log('ProductList - getProduct ');

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (isLoadingmore) {
          if (mounted) {
            setState(() {
              isLoadingmore = false;
              if (_controller1.hasListeners && _controller1.text.isNotEmpty) {
                _isLoading = true;
              }
            });
          }

          var parameter = {
            // SEARCH: query.trim(),
            // LIMIT: perPage.toString(),
            // OFFSET: offset.toString(),
            // TOP_RETAED: top,
            CATEGORY_ID: widget.category_id
          };

          if (CUR_MERCHANTID != null) parameter[MERCHANT_ID] = CUR_MERCHANTID!;
          if (selId != "") {
            parameter[PRODATTVALUE_ID] = selId;
          }
          if (widget.tag!) parameter[TAG] = widget.category_name!;
          // if (widget.fromSeller!) {
          //   parameter["seller_id"] = widget.category_id!;
          // } else {
          //   parameter[CATEGORY_ID] = widget.category_id;
          // }

          if (widget.dis != null) {
            parameter[DISCOUNT] = widget.dis.toString();
          } else {
            parameter[SORT] = sortBy;
            parameter[ORDER] = orderBy;
          }

          if (_currentRangeValues != null && _currentRangeValues!.start.round().toString() != "0") {
            parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
          }

          if (_currentRangeValues != null && _currentRangeValues!.end.round().toString() != "0") {
            parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
          }

          // var tempUri = Uri.parse('${getNumoProductByCategoryApi.toString()}${widget.category_id}');
          // d.log('tempUri = ${tempUri.toString()}');

          apiBaseHelper.getNumoAPICall(getNumoProductByCategoryApi, parameter, widget.category_id).then((alldata) {
            //  d.log('getdata = $alldata');
            d.log('getdata.length = ${alldata.length}');

            var productsData = alldata["data"];
            var totalitem = alldata["total"];
            var maxPrice = alldata["max_price"];
            var minPrice = alldata["min_price"];

            // bool error = getdata["error"];
            // String? msg = getdata["message"];

            // if (_isFirstLoad) {
            //   filterList = getdata["filters"];

            //  = getdata[MINPRICE].toString();
            //  = getdata[MAXPRICE].toString();

            //   _isFirstLoad = false;
            // }

            // Map<String, dynamic> tempData = getdata;

            String? search = ''; // getdata['search'];

            _isLoading = false;
            // if (offset == 0) notificationisnodata = error;

            // if (!error) {
            if (true) {
              // d.log('productsData = $productsData');
              d.log('productsData.length = ${productsData.length}');
              d.log('totalitem = $totalitem');

              total = totalitem;
              if (mounted) {
                Future.delayed(
                    Duration.zero,
                    () => setState(() {
                          if ((offset) < total) {
                            List mainlist = productsData;
                            // d.log('mainlist.length = ${mainlist.length}');

                            if (mainlist.isNotEmpty) {
                              List<Product> items = [];
                              List<Product> allitems = [];

                              items.addAll(mainlist.map((data) => Product.fromJson(data)).toList());

                              allitems.addAll(items);
                              d.log('getProduct getAvailVarient ${allitems.length}');
                              getAvailVarient(allitems);
                            }
                          } else {
                            // if (msg != "Products Not Found !") {
                            //   notificationisnodata = true;
                            // }
                            isLoadingmore = false;
                          }
                        }));
              }
            }

            //  else {
            //   // if (msg != "Products Not Found !") {
            //   //   notificationisnodata = true;
            //   // }
            //   isLoadingmore = false;
            //   if (mounted) setState(() {});
            // }
            setState(() {
              _isLoading = false;
            });
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });

          // apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
          //   bool error = getdata["error"];
          //   String? msg = getdata["message"];

          //   if (_isFirstLoad) {
          //     filterList = getdata["filters"];

          //     minPrice = getdata[MINPRICE].toString();
          //     maxPrice = getdata[MAXPRICE].toString();

          //     _isFirstLoad = false;
          //   }

          //   Map<String, dynamic> tempData = getdata;

          //   String? search = getdata['search'];

          //   _isLoading = false;
          //   if (offset == 0) notificationisnodata = error;

          //   if (!error) {
          //     total = int.parse(getdata["total"]);
          //     if (mounted) {
          //       Future.delayed(
          //           Duration.zero,
          //           () => setState(() {
          //                 if ((offset) < total) {
          //                   List mainlist = getdata['data'];

          //                   if (mainlist.isNotEmpty) {
          //                     List<Product> items = [];
          //                     List<Product> allitems = [];

          //                     items.addAll(mainlist
          //                         .map((data) => Product.fromJson(data))
          //                         .toList());

          //                     allitems.addAll(items);

          //                     getAvailVarient(allitems);
          //                   }
          //                 } else {
          //                   if (msg != "Products Not Found !") {
          //                     notificationisnodata = true;
          //                   }
          //                   isLoadingmore = false;
          //                 }
          //               }));
          //     }
          //   } else {
          //     if (msg != "Products Not Found !") {
          //       notificationisnodata = true;
          //     }
          //     isLoadingmore = false;
          //     if (mounted) setState(() {});
          //   }
          //   setState(() {
          //     _isLoading = false;
          //   });
          // }, onError: (error) {
          //   setSnackbar(error.toString(), context);
          // });

        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        if (mounted) {
          setState(() {
            isLoadingmore = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  void getAvailVarient(List<Product> tempList) {
    // d.log('ProductList getAvailVarient');
    // d.log('ProductList tempList.length=${tempList.length}');
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].ProductAttributeValues!.isNotEmpty) {
        for (int i = 0; i < tempList[j].ProductAttributeValues!.length; i++) {
          if (tempList[j].ProductAttributeValues![i].active == "1") {
            tempList[j].selVarient = i;
            // d.log('tempList[j].ProductAttributeValues![i].prodAttValue_id=${tempList[j].ProductAttributeValues![i].prodAttValue_id}');
            break;
          }
        }
      }
    }

    // d.log('offset =${offset.toString()}');
    // d.log('tempList.length =${tempList.length}');

    if (offset == 0) {
      productList = [];
    }

    if (offset == 0 && buildResult) {
      Product element = Product(product_name: 'Search Result for "$query"', product_image: "", catName: "All Categories", history: false);
      productList.insert(0, element);
    }

    productList.addAll(tempList);

    isLoadingmore = true;
    offset = offset + perPage;
  }

  Widget productItem(int index, bool pad) {
    d.log('Product List productItem index=$index');
    List<String> att = [], val = [];

    if (index < productList.length) {
      Product model = productList[index];
      String? unit_name, contains;

      totalProduct = productList.length.toString();

      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }

      List<String> attt = [], vall = [];

      attt.clear();
      vall.clear();

      att.clear();
      val.clear();

      if (model.ProductAttributeValues!.isNotEmpty) {
        unit_name = model.ProductAttributeValues![model.selVarient!].unit_name;
        contains = model.ProductAttributeValues![model.selVarient!].contains;

        for (var prodAttVal in model.ProductAttributeValues!) {
          if (prodAttVal.Attributes!.isNotEmpty) {
            for (var at in prodAttVal.Attributes!) {
              attt.add(at.attribute_name!);
              // d.log('at.attribute_name = ${at.attribute_name}');
            }
          }

          if (prodAttVal.AttributeValues!.isNotEmpty) {
            for (var attVal in prodAttVal.AttributeValues!) {
              vall.add(attVal.attributeValue_name!);
              // d.log(
              //     'attVal.attributeValue_name = ${attVal.attributeValue_name}');
            }
          }
        }

        att = [];
        val = [];

        att = [
          ...{...attt}
        ];
        val = [
          ...{...vall}
        ];
      }

      double price = 0;
      double old_price = 0;
      double off = 0;

      if (model.ProductAttributeValues![model.selVarient!].price1 != null && model.ProductAttributeValues![model.selVarient!].price1!.isNotEmpty) {
        price = verfiedDouble(model.ProductAttributeValues![model.selVarient!].price1);
      }

      if (model.ProductAttributeValues![model.selVarient!].old_price != null &&
          model.ProductAttributeValues![model.selVarient!].old_price!.isNotEmpty) {
        old_price = verfiedDouble(model.ProductAttributeValues![model.selVarient!].old_price);
      }

      d.log(
          'productItem  model.product_name =${model.product_name} --- att[] = ${att.toString()}  val[] = ${val.toString()} -- model.price1= ${model.price1}- old_price=${model.old_price}');

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

      // if (model.ProductImages != null && model.ProductImages!.isNotEmpty) {
      //   // d.log('model.ProductImages![0].image_url! = ${model.ProductImages![0].image_url!}');
      // }

      _controller[index].text = model.ProductAttributeValues![model.selVarient!].cartCount ?? '0';

      d.log('productItem price = $price and off=$off');

      double width = deviceWidth! * 0.5;

      return SlideAnimation(
          position: index,
          itemCount: productList.length,
          slideDirection: SlideDirection.fromBottom,
          animationController: _animationController1,
          child: Selector<CartProvider, Tuple2<List<String?>, String?>>(
            builder: (context, data, child) {
              d.log('productItem CartProvider data=$data ');
              if (data.item1.isNotEmpty &&
                  model.ProductAttributeValues != null &&
                  model.ProductAttributeValues!.isNotEmpty &&
                  data.item1.contains(model.product_id)) {
                _controller[index].text = data.item2 ?? '0';
              } else {
                if (CUR_MERCHANTID != null && model.ProductAttributeValues != null && model.ProductAttributeValues!.isNotEmpty) {
                  _controller[index].text = model.ProductAttributeValues![model.selVarient!].cartCount!;
                  d.log('ProductList if else');
                } else {
                  _controller[index].text = "0";
                  d.log('else else');
                }
              }

              return InkWell(
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  margin: EdgeInsetsDirectional.only(bottom: 10, end: 10, start: pad ? 10 : 0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                  child: Hero(
                                    tag: "$index${model.product_id}",
                                    child: FadeInImage(
                                      fadeInDuration: const Duration(milliseconds: 150),
                                      image: NetworkImage(model.ProductImages![0].image_url!),
                                      height: double.maxFinite,
                                      width: double.maxFinite,
                                      fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                      placeholder: placeHolder(width),
                                      imageErrorBuilder: (context, error, stackTrace) => erroWidget(width),
                                    ),
                                  )),
                              Positioned.fill(
                                  child: model.active! == "0"
                                      ? Container(
                                          height: 55,
                                          color: Theme.of(context).colorScheme.white70,
                                          // width: double.maxFinite,
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
                                  ? Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: colors.red,
                                        ),
                                        margin: const EdgeInsets.all(5),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            "${off.toStringAsFixed(0)}%",
                                            style: const TextStyle(color: colors.whiteTemp, fontWeight: FontWeight.bold, fontSize: 9),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              const Divider(
                                height: 1,
                              ),
                              Positioned.directional(
                                textDirection: Directionality.of(context),
                                end: 0,
                                // bottom: -18,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    model.active == "0" || !cartBtnList
                                        ? Container()
                                        : _controller[index].text == "0"
                                            ? InkWell(
                                                onTap: () {
                                                  if (_isProgress == false) {
                                                    addToCart(index, (int.parse(_controller[index].text) + int.parse(model.qtyStepSize!)).toString(),
                                                        1, price.toString());
                                                  }
                                                },
                                                child: Card(
                                                  elevation: 1,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.shopping_cart_outlined,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsetsDirectional.only(start: 3.0, bottom: 5, top: 3),
                                                child: Row(
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
                                                          removeFromCart(index);
                                                        }
                                                      },
                                                    ),
                                                    Container(
                                                      width: 37,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).colorScheme.white70,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Selector<CartProvider, Tuple2<List<String?>, String?>>(
                                                            builder: (context, data, child) {
                                                              return TextField(
                                                                textAlign: TextAlign.center,
                                                                readOnly: true,
                                                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.fontColor),
                                                                controller: _controller[index],
                                                                decoration: const InputDecoration(
                                                                  border: InputBorder.none,
                                                                ),
                                                              );
                                                            },
                                                            selector: (_, provider) => Tuple2(
                                                                provider.cartIdList,
                                                                provider.qtyList(
                                                                    model.product_id!,
                                                                    (model.ProductAttributeValues != null && model.ProductAttributeValues!.isNotEmpty)
                                                                        ? model.ProductAttributeValues![model.selVarient!].prodAttValue_id!
                                                                        : '0')),
                                                          ),
                                                          PopupMenuButton<String>(
                                                            tooltip: '',
                                                            icon: const Icon(
                                                              Icons.arrow_drop_down,
                                                              size: 0,
                                                            ),
                                                            onSelected: (String value) {
                                                              if (_isProgress == false) {
                                                                addToCart(index, value, 2, price.toString());
                                                              }
                                                            },
                                                            itemBuilder: (BuildContext context) {
                                                              d.log('productItem model.itemsCounter');
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
                                                    ), // ),

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
                                                          d.log('prductItem addToCart index=$index');
                                                          addToCart(
                                                              index,
                                                              (int.parse(_controller[index].text) + int.parse(model.qtyStepSize!)).toString(),
                                                              2,
                                                              price.toString());
                                                        }
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                    Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: model.isFavLoading!
                                            ? const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: CircularProgressIndicator(
                                                      color: colors.primary,
                                                      strokeWidth: 0.7,
                                                    )),
                                              )
                                            : Selector<FavoriteProvider, List<String?>>(
                                                builder: (context, data, child) {
                                                  d.log('productItem FavoriteProvider data=$data');
                                                  return InkWell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(
                                                        !data.contains(model.product_id) ? Icons.favorite_border : Icons.favorite,
                                                        size: 15,
                                                        color: colors.red,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (CUR_MERCHANTID != null) {
                                                        d.log('productItem onTap data=$data');

                                                        !data.contains(model.product_id) ? _setFav(-1, model) : _removeFav(-1, model);
                                                      } else {
                                                        if (!data.contains(model.product_id)) {
                                                          model.isFavLoading = true;
                                                          model.isFav = "1";
                                                          context.read<FavoriteProvider>().addFavItem(model);
                                                          db.addAndRemoveFav(model.product_id!, true);
                                                          model.isFavLoading = false;
                                                        } else {
                                                          model.isFavLoading = true;
                                                          model.isFav = "0";
                                                          context
                                                              .read<FavoriteProvider>()
                                                              .removeFavItem(model.ProductAttributeValues![model.selVarient!].prodAttValue_id!);
                                                          db.addAndRemoveFav(model.product_id!, false);
                                                          model.isFavLoading = false;
                                                        }
                                                        setState(() {});
                                                      }
                                                    },
                                                  );
                                                },
                                                selector: (_, provider) => provider.favIdList,
                                              )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: verfiedDouble(model.rating!),
                              itemBuilder: (context, index) => const Icon(
                                Icons.star_rate_rounded,
                                color: Colors.amber,
                                //color: colors.primary,
                              ),
                              unratedColor: Colors.grey.withOpacity(0.5),
                              itemCount: 5,
                              itemSize: 12.0,
                              direction: Axis.horizontal,
                              itemPadding: const EdgeInsets.all(0),
                            ),
                            Text(
                              " (${model.noOfRating!})",
                              style: Theme.of(context).textTheme.overline,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            ImageFiltered(
                              imageFilter: IS_LOGGINED ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Text('${getPriceFormat(context, price)!} ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold)),
                            ),
                            Flexible(
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    child: ImageFiltered(
                                        imageFilter: IS_LOGGINED ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: Text(
                                          model.ProductAttributeValues!.isNotEmpty
                                              ? verfiedDouble(model.ProductAttributeValues![model.selVarient!].old_price!) != 0
                                                  ? getPriceFormat(
                                                      context, verfiedDouble(model.ProductAttributeValues![model.selVarient!].old_price!))!
                                                  : ""
                                              : "",

                                          // '${getPriceFormat(context, old_price)!} ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline!
                                              .copyWith(decoration: TextDecoration.lineThrough, letterSpacing: 0),
                                        )),
                                  ),
                                ],
                              ),
                            )
                            // : Container()
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: model.ProductAttributeValues!.isNotEmpty
                                    ? model.ProductAttributeValues![model.selVarient!].Attributes != null &&
                                            model.ProductAttributeValues![model.selVarient!].Attributes!.isNotEmpty
                                        ? ListView.builder(
                                            padding: const EdgeInsets.only(bottom: 5.0),
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: att.length >= 2 ? 2 : att.length,
                                            itemBuilder: (context, index) {
                                              return Row(children: [
                                                Flexible(
                                                  child: Text(
                                                    "${att[index].trim()}:",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(color: Theme.of(context).colorScheme.lightBlack),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsetsDirectional.only(start: 5.0),
                                                    child: Text(
                                                      val[index],
                                                      maxLines: 1,
                                                      overflow: TextOverflow.visible,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption!
                                                          .copyWith(color: Theme.of(context).colorScheme.lightBlack, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                )
                                              ]);
                                            })
                                        : Container()
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                        unit_name!.isNotEmpty && verfiedDouble(contains) > 1
                            ? Padding(
                                padding: const EdgeInsetsDirectional.only(start: 5.0, bottom: 5),
                                child: Text(
                                  "$unit_name  ($contains) قطعه / حبه",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
                                ),
                                //  Row(
                                //   children: [
                                //     Flexible(
                                //       child: Text(
                                //         "$unit_name  ",
                                //         maxLines: 1,
                                //         overflow: TextOverflow.ellipsis,
                                //         style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
                                //       ),
                                //     ),
                                //     Flexible(
                                //       fit: FlexFit.tight,
                                //       child: Padding(
                                //         padding: const EdgeInsetsDirectional.only(start: 5.0),
                                //         child: Text(
                                //           '($contains) قطعه / حبه',
                                //           maxLines: 1,
                                //           overflow: TextOverflow.visible,
                                //           style: Theme.of(context)
                                //               .textTheme
                                //               .caption!
                                //               .copyWith(color: Theme.of(context).colorScheme.lightBlack, fontWeight: FontWeight.bold),
                                //         ),
                                //       ),
                                //     )
                                //   ],
                                // ),
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 5.0, bottom: 5),
                          child: Text(
                            model.product_name!,
                            style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //),
                ),
                onTap: () {
                  Product model = productList[index];
                  d.log('productItem onTap ProductDetail model.product_id=${model.product_id}');
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProductDetail(
                              model: model,
                              index: index,
                              secPos: 0,
                              list: true,
                            )),
                  );
                },
              );
            },
            selector: (_, provider) => Tuple2(
                provider.cartIdList,
                provider.qtyList(
                    model.product_id!,
                    (model.ProductAttributeValues != null && model.ProductAttributeValues!.isNotEmpty)
                        ? model.ProductAttributeValues![model.selVarient!].prodAttValue_id!
                        : '0')),
          ));
    } else {
      return Container();
    }
  }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                    child: Text(
                      getTranslated(context, 'SORT_BY')!,
                      style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                    )),
              ),
              InkWell(
                onTap: () {
                  sortBy = '';
                  orderBy = 'DESC';
                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                      total = 0;
                      offset = 0;
                      productList.clear();
                    });
                  }
                  getProduct("1");
                  Navigator.pop(context, 'option 1');
                },
                child: Container(
                  width: deviceWidth,
                  color: sortBy == '' ? colors.primary : Theme.of(context).colorScheme.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(getTranslated(context, 'TOP_RATED')!,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: sortBy == '' ? Theme.of(context).colorScheme.white : Theme.of(context).colorScheme.fontColor)),
                ),
              ),
              InkWell(
                  child: Container(
                      width: deviceWidth,
                      color: sortBy == 'Product.createdAt' && orderBy == 'DESC' ? colors.primary : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(getTranslated(context, 'F_NEWEST')!,
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              color: sortBy == 'Product.createdAt' && orderBy == 'DESC'
                                  ? Theme.of(context).colorScheme.white
                                  : Theme.of(context).colorScheme.fontColor))),
                  onTap: () {
                    sortBy = 'Product.createdAt';
                    orderBy = 'DESC';
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                        total = 0;
                        offset = 0;
                        productList.clear();
                      });
                    }
                    getProduct("0");
                    Navigator.pop(context, 'option 1');
                  }),
              InkWell(
                  child: Container(
                      width: deviceWidth,
                      color: sortBy == 'Product.createdAt' && orderBy == 'ASC' ? colors.primary : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        getTranslated(context, 'F_OLDEST')!,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: sortBy == 'Product.createdAt' && orderBy == 'ASC'
                                ? Theme.of(context).colorScheme.white
                                : Theme.of(context).colorScheme.fontColor),
                      )),
                  onTap: () {
                    sortBy = 'Product.createdAt';
                    orderBy = 'ASC';
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                        total = 0;
                        offset = 0;
                        productList.clear();
                      });
                    }
                    getProduct("0");
                    Navigator.pop(context, 'option 2');
                  }),
              InkWell(
                  child: Container(
                      width: deviceWidth,
                      color: sortBy == 'pv.price' && orderBy == 'ASC' ? colors.primary : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        getTranslated(context, 'F_LOW')!,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: sortBy == 'pv.price' && orderBy == 'ASC'
                                ? Theme.of(context).colorScheme.white
                                : Theme.of(context).colorScheme.fontColor),
                      )),
                  onTap: () {
                    sortBy = 'pv.price';
                    orderBy = 'ASC';
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                        total = 0;
                        offset = 0;
                        productList.clear();
                      });
                    }
                    getProduct("0");
                    Navigator.pop(context, 'option 3');
                  }),
              InkWell(
                  child: Container(
                      width: deviceWidth,
                      color: sortBy == 'pv.price' && orderBy == 'DESC' ? colors.primary : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        getTranslated(context, 'F_HIGH')!,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: sortBy == 'pv.price' && orderBy == 'DESC'
                                ? Theme.of(context).colorScheme.white
                                : Theme.of(context).colorScheme.fontColor),
                      )),
                  onTap: () {
                    sortBy = 'pv.price';
                    orderBy = 'DESC';
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                        total = 0;
                        offset = 0;
                        productList.clear();
                      });
                    }
                    getProduct("0");
                    Navigator.pop(context, 'option 4');
                  }),
            ]),
          );
        });
      },
    );
  }

  Future<void> addToCart(int index, String qty, int from, String price) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_MERCHANTID != null) {
        if (mounted) {
          setState(() {
            _isProgress = true;
          });
        }

        d.log('ProductList addToCart qty=$qty productList[index=$index].minOrderQty=${productList[index].minOrderQty}');
        if (int.parse(qty) < int.parse(productList[index].minOrderQty!)) {
          qty = productList[index].minOrderQty.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        try {
          d.log('ProductList addToCart before parameter');

          var parameter = {
            MERCHANT_ID: CUR_MERCHANTID,
            PRODATTVALUE_ID: productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id,
            CARTITEM_QTY: qty,
            CARTITEM_PRICE: price
          };

          d.log('ProductList addToCart parameter=$parameter');

          apiBaseHelper.postNumoAPICall(postNumoCartItemsApi, parameter).then((getdata) {
            d.log('ProductList addToCart getdata=$getdata');

            var data = getdata['rows'][0];
            d.log('ProductList addToCart data=$data');

            String? cartCount = getdata[COUNT].toString();
            context.read<UserProvider>().setCartCount(cartCount);

            productList[index].ProductAttributeValues![productList[index].selVarient!].cartCount = qty;

            var carts = data[CARTITEMS];
            List<SectionModel> cartList = (carts as List).map((cart) => SectionModel.fromCart(cart)).toList();
            context.read<CartProvider>().setCartlist(cartList);
            // } else {
            //   setSnackbar(msg!, context);
            // }
            if (mounted) {
              setState(() {
                _isProgress = false;
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
            if (mounted) {
              setState(() {
                _isProgress = false;
              });
            }
          });
        } catch (e) {
          d.log('ProductList addToCart error=$e');
          setSnackbar("${getTranslated(context, 'somethingMSg')}", context);
          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        }

        // apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
        //   bool error = getdata["error"];
        //   String? msg = getdata["message"];
        //   if (!error) {
        //     var data = getdata["data"];
        //     String? qty = data['total_quantity'];
        //     // CUR_CART_COUNT = data['cart_count'];
        //     context.read<UserProvider>().setCartCount(data['cart_count']);
        //     productList[index].ProductAttributeValues![productList[index].selVarient!].cartCount = qty.toString();
        //     var cart = getdata["cart"];
        //     List<SectionModel> cartList = (cart as List).map((cart) => SectionModel.fromCart(cart)).toList();
        //     context.read<CartProvider>().setCartlist(cartList);
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
        //   if (mounted) {
        //     setState(() {
        //       _isProgress = false;
        //     });
        //   }
        // });

      } else {
        setState(() {
          _isProgress = true;
        });

        if (from == 1) {
          List<Product>? prList = [];
          prList.add(productList[index]);
          context.read<CartProvider>().addCartItem(SectionModel(
                cartItem_qty: qty,
                productList: prList,
                prodAttValue_id: productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id!,
                product_id: productList[index].product_id,
              ));
          db.insertCart(productList[index].product_id!, productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id!,
              qty, context);
        } else {
          if (int.parse(qty) > int.parse(productList[index].itemsCounter!.last)) {
            // qty = productList[index].minOrderQty.toString();

            setSnackbar("${getTranslated(context, 'MAXQTY')!} ${productList[index].itemsCounter!.last}", context);
          } else {
            context.read<CartProvider>().updateCartItem(productList[index].product_id!, qty, productList[index].selVarient!,
                productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id!);
            db.updateCart(
                productList[index].product_id!, productList[index].ProductAttributeValues![productList[index].selVarient!].prodAttValue_id!, qty);
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

  _showForm() {
    // try {
    d.log('ProductList - _showForm ');

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.white,
          padding: const EdgeInsets.only(bottom: 15),
          //padding: const EdgeInsets.symmetric(vertical: ),
          child: Column(
            children: [
              // getSubHeadingsTabBar(),

              Container(
                color: Theme.of(context).colorScheme.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
                    height: 44,
                    child: TextField(
                      controller: _controller1,
                      autofocus: false,
                      focusNode: searchFocusNode,
                      enabled: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.gray),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          fillColor: Theme.of(context).colorScheme.gray,
                          filled: true,
                          isDense: true,
                          hintText: getTranslated(context, 'searchHint'),
                          hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              ),
                          prefixIcon: const Padding(padding: EdgeInsets.all(15.0), child: Icon(Icons.search)),
                          suffixIcon: _controller1.text != ''
                              ? IconButton(
                                  onPressed: () {
                                    d.log('_showForm onPressed getProduct');
                                    FocusScope.of(context).unfocus();
                                    _controller1.text = '';
                                    offset = 0;
                                    // getProduct('0');
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: colors.primary,
                                  ),
                                )
                              : InkWell(
                                  child: const Icon(
                                    Icons.mic,
                                    color: colors.primary,
                                  ),
                                  onTap: () {
                                    lastWords = '';
                                    if (!_hasSpeech) {
                                      initSpeechState();
                                    } else {
                                      showSpeechDialog();
                                    }
                                  },
                                )),
                    ),
                  ),
                ),
              ),

              filterOptions(),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? shimmer(context)
              : notificationisnodata
                  ? getNoItem(context)
                  : listType
                      ? ListView.builder(
                          controller: controller,
                          shrinkWrap: true,
                          itemCount: (offset < total) ? productList.length + 1 : productList.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            // d.log('_showForm itemBuilder index=$index');
                            return (index == productList.length && isLoadingmore) ? singleItemSimmer(context) : listItem(index);
                          },
                        )
                      : GridView.count(
                          padding: const EdgeInsetsDirectional.only(top: 5),
                          crossAxisCount: 2,
                          controller: controller,
                          childAspectRatio: 0.6,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: List.generate(
                            (offset < total) ? productList.length + 1 : productList.length,
                            (index) {
                              d.log('_showForm GridView index=$index');
                              return (index == productList.length && isLoadingmore)
                                  ? simmerSingleProduct(context)
                                  : productItem(index, index % 2 == 0 ? true : false);
                            },
                          )),
        ),
      ],
    );
    // } catch (e) {
    //   d.log('error on _showForm = $e');
    // }
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      // lastError = '${error.errorMsg} - ${error.permanent}';
      setSnackbar(error.errorMsg, context);
    });
  }

  void statusListener(String status) {
    setStater(() {
      lastStatus = status;
    });
  }

  void startListening() {
    lastWords = '';
    speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setStater(() {});
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  void stopListening() {
    speech.stop();
    setStater(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setStater(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = result.recognizedWords;
      query = lastWords.replaceAll(' ', '');
    });

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        clearAll();

        _controller1.text = lastWords;
        _controller1.selection = TextSelection.fromPosition(TextPosition(offset: _controller1.text.length));

        setState(() {});
        Navigator.of(context).pop();
      });
    }
  }

  clearAll() {
    setState(() {
      query = _controller1.text;
      offset = 0;
      isLoadingmore = true;
      productList.clear();
    });
  }

  showSpeechDialog() {
    return dialogAnimate(context, StatefulBuilder(builder: (BuildContext context, StateSetter setStater1) {
      setStater = setStater1;
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        title: Text(
          'Search for desired product',
          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(blurRadius: .26, spreadRadius: level * 1.5, color: Theme.of(context).colorScheme.black.withOpacity(.05))],
                color: Theme.of(context).colorScheme.white,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: IconButton(
                  icon: const Icon(
                    Icons.mic,
                    color: colors.primary,
                  ),
                  onPressed: () {
                    if (!_hasSpeech) {
                      initSpeechState();
                    } else {
                      !_hasSpeech || speech.isListening ? null : startListening();
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(lastWords),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
              child: Center(
                child: speech.isListening
                    ? Text(
                        "I'm listening...",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
                      )
                    : Text(
                        'Not listening',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      );
    }));
  }

  Future<void> initSpeechState() async {
    var hasSpeech =
        await speech.initialize(onError: errorListener, onStatus: statusListener, debugLogging: false, finalTimeout: const Duration(milliseconds: 0));
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) showSpeechDialog();
  }

  Widget _tags() {
    if (tagList != null && tagList!.isNotEmpty) {
      List<Widget> chips = [];
      for (int i = 0; i < tagList!.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(tagList![i], style: TextStyle(color: Theme.of(context).colorScheme.white)),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
          onSelected: (bool selected) {
            if (mounted) {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ProductList(
                      category_name: tagList![i],
                      tag: true,
                      fromSeller: false,
                    ),
                  ));
            }
          },
        );

        chips.add(Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: tagChip));
      }

      return Container(
        height: 50,
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListView(scrollDirection: Axis.horizontal, shrinkWrap: true, children: chips),
      );
    } else {
      return Container();
    }
  }

  filterOptions() {
    return Container(
      height: 45.0,
      width: deviceWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.gray,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
              onPressed: () {
                filterDialog();
              },
              icon: const Icon(
                Icons.filter_list,
                color: colors.primary,
              ),
              label: Text(
                getTranslated(context, 'FILTER')!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                ),
              )),
          TextButton.icon(
              onPressed: sortDialog,
              icon: const Icon(
                Icons.swap_vert,
                color: colors.primary,
              ),
              label: Text(
                getTranslated(context, 'SORT_BY')!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                ),
              )),
          InkWell(
            child: Icon(
              listType ? Icons.grid_view : Icons.list,
              color: colors.primary,
            ),
            onTap: () {
              d.log('on listType productList=$productList');
              productList.isNotEmpty
                  ? setState(() {
                      _animationController!.reverse();
                      _animationController1!.reverse();
                      listType = !listType;
                    })
                  : null;
            },
          ),
        ],
      ),
    );
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        _currentRangeValues = RangeValues(double.parse(minPrice), verfiedDouble(maxPrice));
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsetsDirectional.only(top: 30.0),
                child: AppBar(
                  title: Text(
                    getTranslated(context, 'FILTER')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 5,
                  backgroundColor: Theme.of(context).colorScheme.white,
                  leading: Builder(builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.all(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsetsDirectional.only(end: 4.0),
                          child: Icon(Icons.arrow_back_ios_rounded, color: colors.primary),
                        ),
                      ),
                    );
                  }),
                )),
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.lightWhite,
              padding: const EdgeInsetsDirectional.only(start: 7.0, end: 7.0, top: 7.0),
              child: filterList != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsetsDirectional.only(top: 10.0),
                      itemCount: filterList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              SizedBox(
                                  width: deviceWidth,
                                  child: Card(
                                      elevation: 0,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Price Range',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(color: Theme.of(context).colorScheme.lightBlack, fontWeight: FontWeight.normal),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          )))),
                              RangeSlider(
                                values: _currentRangeValues!,
                                min: verfiedDouble(minPrice),
                                max: verfiedDouble(maxPrice),
                                divisions: 10,
                                labels: RangeLabels(
                                  _currentRangeValues!.start.round().toString(),
                                  _currentRangeValues!.end.round().toString(),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    _currentRangeValues = values;
                                  });
                                },
                              ),
                            ],
                          );
                        } else {
                          index = index - 1;
                          attsubList = filterList[index]['attribute_values'].split(',');

                          attListId = filterList[index]['attribute_values_id'].split(',');

                          List<Widget?> chips = [];
                          List<String> att = filterList[index]['attribute_values']!.split(',');

                          List<String> attSType = filterList[index]['swatche_type'].split(',');

                          List<String> attSValue = filterList[index]['swatche_value'].split(',');

                          for (int i = 0; i < att.length; i++) {
                            Widget itemLabel;
                            if (attSType[i] == "1") {
                              String clr = (attSValue[i].substring(1));

                              String color = "0xff$clr";

                              itemLabel = Container(
                                width: 25,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Color(int.parse(color))),
                              );
                            } else if (attSType[i] == "2") {
                              itemLabel = ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(attSValue[i],
                                      width: 80, height: 80, errorBuilder: (context, error, stackTrace) => erroWidget(80)));
                            } else {
                              itemLabel = Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(att[i],
                                    style: TextStyle(
                                        color: selectedId.contains(attListId![i])
                                            ? Theme.of(context).colorScheme.white
                                            : Theme.of(context).colorScheme.fontColor)),
                              );
                            }

                            choiceChip = ChoiceChip(
                              selected: selectedId.contains(attListId![i]),
                              label: itemLabel,
                              labelPadding: const EdgeInsets.all(0),
                              selectedColor: colors.primary,
                              backgroundColor: Theme.of(context).colorScheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(attSType[i] == "1" ? 100 : 10),
                                side: BorderSide(color: selectedId.contains(attListId![i]) ? colors.primary : colors.black12, width: 1.5),
                              ),
                              onSelected: (bool selected) {
                                attListId = filterList[index]['attribute_values_id'].split(',');

                                if (mounted) {
                                  setState(() {
                                    if (selected == true) {
                                      selectedId.add(attListId![i]);
                                    } else {
                                      selectedId.remove(attListId![i]);
                                    }
                                  });
                                }
                              },
                            );

                            chips.add(choiceChip);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: deviceWidth,
                                child: Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      filterList[index]['name'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                              chips.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Wrap(
                                        children: chips.map<Widget>((Widget? chip) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: chip,
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : Container()
                            ],
                          );
                        }
                      })
                  : Container(),
            )),
            Container(
              color: Theme.of(context).colorScheme.white,
              child: Row(children: <Widget>[
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 20),
                  width: deviceWidth! * 0.4,
                  child: OutlinedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          selectedId.clear();
                        });
                      }
                    },
                    child: Text(getTranslated(context, 'DISCARD')!),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  child: SimBtn(
                      width: 0.4,
                      height: 35,
                      title: getTranslated(context, 'APPLY'),
                      onBtnSelected: () {
                        selId = selectedId.join(',');

                        if (mounted) {
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        }
                        getProduct("0");
                        Navigator.pop(context, 'Product Filter');
                      }),
                ),
              ]),
            )
          ]);
        });
      },
    );
  }

  // Widget getSubHeadingsTabBar() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //     child: TabBar(
  //       controller: _tabController,
  //       tabs: [
  //         getTab(getTranslated(context, "ALL_DETAILS")!),
  //         getTab(getTranslated(context, "PROCESSING")!),
  //         getTab(getTranslated(context, "DELIVERED")!),
  //         getTab(getTranslated(context, "CANCELLED")!),
  //         getTab(getTranslated(context, "RETURNED")!),
  //       ],
  //       indicator: BoxDecoration(
  //         shape: BoxShape.rectangle,
  //         borderRadius: BorderRadius.circular(50),
  //         color: colors.primary,
  //       ),
  //       isScrollable: true,
  //       unselectedLabelColor: Theme.of(context).colorScheme.black,
  //       labelColor: Theme.of(context).colorScheme.white,
  //       automaticIndicatorColorAdjustment: true,
  //       indicatorPadding: const EdgeInsets.symmetric(horizontal: 1.0),
  //     ),
  //   );
  // }

  // getTab(String title) {
  //   return Container(
  //     padding: const EdgeInsets.all(5.0),
  //     height: 35,
  //     child: Center(
  //       child: Text(title),
  //     ),
  //   );
  // }

}
