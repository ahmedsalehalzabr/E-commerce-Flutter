// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:collection/src/iterable_extensions.dart';
import 'package:numo/Helper/SqliteData.dart';
import 'package:numo/Screen/Cart.dart';
import 'package:numo/Screen/FaqsProduct.dart';
import 'package:numo/Screen/ListItemCompare.dart';
import 'package:numo/Provider/CartProvider.dart';
import 'package:numo/Provider/FavoriteProvider.dart';
import 'package:numo/Provider/HomeProvider.dart';
import 'package:numo/Provider/ProductDetailProvider.dart';
import 'package:numo/Provider/UserProvider.dart';
import 'package:numo/Screen/ReviewList.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tuple/tuple.dart';

import 'package:url_launcher/url_launcher.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Model/Faqs_Model.dart';
import '../Model/Section_Model.dart';
import '../Model/User.dart';
import 'CompareList.dart';
import 'Favorite.dart';
import 'HomePage.dart';
import 'Login.dart';
import 'Product_Preview.dart';
import 'Review_Gallary.dart';
import 'Review_Preview.dart';
import 'Search.dart';

class ProductDetail extends StatefulWidget {
  final Product? model;

  final int? secPos, index;
  final bool? list;

  const ProductDetail({Key? key, this.model, this.secPos, this.index, this.list}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateItem();
}

List<User> reviewList = [];
List<imgModel> revImgList = [];
// List<imgModel> revImgList = [];
int offset = 0;
int total = 0;

List<FaqsModel> faqsProductList = [];
int faqsOffset = 0;
int faqsTotal = 0;

class StateItem extends State<ProductDetail> with TickerProviderStateMixin {
  int _curSlider = 0;
  final _pageController = PageController();
  final List<int?> _selectedIndex = [];
  ChoiceChip? choiceChip, tagChip;
  int _oldSelVarient = 0;
  bool _isLoading = true;
  bool _isFaqsLoading = true;
  var star1 = "0", star2 = "0", star3 = "0", star4 = "0", star5 = "0";
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  int notificationoffset = 0;
  late int totalProduct = 0;

  bool notificationisloadmore = true, notificationisgettingdata = false, notificationisnodata = false;
  List<Product> productList = [];
  List<Product> productList1 = [];
  bool seeView = false;
  List<Attribute> attList = [];
  List<AttributeValue> attvalList = [];

  var isDarkTheme;
  late ShortDynamicLink shortenedLink;
  String? shareLink;
  late String curPin;
  late double growStepWidth, beginWidth, endWidth = 0.0;
  TextEditingController qtyController = TextEditingController();
  List<String?> sliderList = [];
  int? varSelected;

  List<Product> compareList = [];
  bool isBottom = false;
  var db = DatabaseHelper();
  bool qtyChange = false;
  bool? available, outOfStock;
  bool hasVariants = false;
  int? selectIndex = 0;
  final edtFaqs = TextEditingController();
  final GlobalKey<FormState> faqsKey = GlobalKey<FormState>();
  List<String> wholeAtt = [];

  /* int faqsOffset = 0;
  late int totalFaqs = 0;

  bool faqsIsLoadMore = true, faqsIsGettingData = false, faqsIsNoData = false;
  List<FaqsModel> faqsProductList = [];*/

  @override
  void initState() {
    super.initState();
    getProduct1();
    sliderList.clear();
    log(' widget.model!.ProductImages![0].image_url');
    log(widget.model!.ProductImages![0].image_url!);
    sliderList.insert(0, widget.model!.ProductImages![0].image_url!);

    // log('initState 222');
    addImage().then((value) {
      // if (widget.model!.videType != "" &&
      //     widget.model!.video!.isNotEmpty &&
      //     widget.model!.video != "") {
      //   sliderList.insert(1, "youtube");
      // }
    });

    // revImgList.clear();
    // if (widget.model!.reviewList!.isNotEmpty)
    //   for (int i = 0;
    //       i < widget.model!.reviewList![0].productRating!.length;
    //       i++) {
    //     for (int j = 0;
    //         j < widget.model!.reviewList![0].productRating![i].imgList!.length;
    //         j++) {
    //       imgModel m = imgModel.fromJson(
    //           i, widget.model!.reviewList![0].productRating![i].imgList![j]);
    //       revImgList.add(m);
    //     }
    //   }

    getShare();
    _oldSelVarient = widget.model!.selVarient!;

    reviewList.clear();
    offset = 0;
    total = 0;
    // getReview();
    getDeliverable();
    notificationoffset = 0;
    getProduct();
    faqsProductList.clear();
    faqsOffset = 0;
    faqsTotal = 0;
    // getProductFaqs();
    compareList = context.read<ProductDetailProvider>().compareList;

    // log('initState 333');

    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    // log('initState 444');

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
    // log('initState 555');

    _selectedIndex.clear();
    if (widget.model!.stockType == '0' || widget.model!.stockType == '1') {
      if (widget.model!.active == '1') {
        available = true;
        outOfStock = false;
        _oldSelVarient = widget.model!.selVarient!;
      } else {
        available = false;
        outOfStock = true;
      }
    } else if (widget.model!.stockType == '') {
      available = true;
      outOfStock = false;
      _oldSelVarient = widget.model!.selVarient!;
    } else if (widget.model!.stockType == '2') {
      if (widget
              // .model!.ProductAttributeValues![widget.model!.selVarient!].active ==
              .model!
              .ProductAttributeValues![widget.model!.selVarient!]
              .active ==
          '1') {
        available = true;
        outOfStock = false;
        _oldSelVarient = widget.model!.selVarient!;
      } else {
        available = false;
        outOfStock = true;
      }
    }

    // log('initState 666');

    List<Attribute> attListtemp = [];
    List<AttributeValue> attvalListtemp = [];

    hasVariants = false;

    if (widget.model!.ProductAttributeValues != null && widget.model!.ProductAttributeValues!.isNotEmpty) {
      hasVariants = true;
    }
//for retrive the AttributeValue_id's from the current selected ProductAttributeValue
    List<String> selList = hasVariants
        ? List.from(widget.model!.ProductAttributeValues![widget.model!.selVarient!].AttributeValues!.map((e) => e.attributeValue_id))
        : [];
    var allAttVals = [];

    log('selList =$selList');

    //for retrive all attributes and attributeValues of all ProductAttributeValues
    for (int i = 0; i < widget.model!.ProductAttributeValues!.length; i++) {
      attListtemp.addAll(widget.model!.ProductAttributeValues![i].Attributes!);
      attvalListtemp.addAll(widget.model!.ProductAttributeValues![i].AttributeValues!);
    }

    var seenAtt = Set<String>();
    attList = attListtemp.where((att) => seenAtt.add(att.attribute_id!)).toList();

    var seenAttVal = Set<String>();
    attvalList = attvalListtemp.where((att) => seenAttVal.add(att.attributeValue_id!)).toList();

    // log('attListtemp =$attListtemp ------ attvalListtemp=$attvalListtemp');
    log('attList =$attList ------ attvalList=$attvalList');

    for (int i = 0; i < attList.length; i++) {
      for (int j = 0; j < attvalList.length; j++) {
        if (attList[i].attribute_id == attvalList[j].attribute_id) {
          if (selList.contains(attvalList[j].attributeValue_id)) {
            log('index i=$i --j=$j');
            log('index attList[i].attribute_id=${int.parse(attList[i].attribute_id!)} -- attvalList[j].attributeValue_id=${int.parse(attvalList[j].attributeValue_id!)}');
            _selectedIndex.insert(i, j);
          }
        }
      }
      if (_selectedIndex.length == i) _selectedIndex.insert(i, null);
    }

    log('attvalList = ${attvalList.length}');
    log('attList = ${attList.length}');
    log('selList = ${selList.length}');
    allAttVals.addAll(attvalList.map((e) => e.attributeValue_id));
    log('allAttVals = ${allAttVals.length}');

    //attrIds = attr_value_ids = attributeValue_id's in all ProductAttributeValues in the Product
    // List<String> wholeAtt = widget.model!.attrIds!.split(',');
    //to remove all dublicated
    wholeAtt = [
      ...{...allAttVals}
    ];
//or use this to remove all duplicated  var distinctIds = ids.toSet().toList();

    log('wholeAtt=$wholeAtt');
    log('_selectedIndex=${_selectedIndex.toString()}');
  }

  @override
  void dispose() {
    buttonController!.dispose();
    edtFaqs.dispose();
    super.dispose();
  }

  Future<void> addImage() async {
    log('ProductDetail addImage started sliderList.length=${sliderList.length}');
    if (widget.model!.ProductImages != "" && widget.model!.ProductImages!.isNotEmpty) {
      sliderList.addAll(widget.model!.ProductImages!.map((e) => e.image_url));
    }

    for (int i = 0; i < widget.model!.ProductAttributeValues!.length; i++) {
      for (int j = 0; j < widget.model!.ProductAttributeValues![i].ProductImages!.length; j++) {
        sliderList.add(widget.model!.ProductAttributeValues![i].ProductImages![j].image_url);
      }
    }
  }

  Future<void> createDynamicLink() async {
    String documentDirectory;

    if (Platform.isIOS) {
      documentDirectory = (await getApplicationDocumentsDirectory()).path;
    } else {
      documentDirectory = (await getExternalStorageDirectory())!.path;
    }

    final response1 = await get(Uri.parse(widget.model!.ProductImages != null && widget.model!.ProductImages!.isNotEmpty
        ? widget.model!.ProductImages![0].image_url
        : erroWidget(double.maxFinite)));
    final bytes1 = response1.bodyBytes;

    final File imageFile = File('$documentDirectory/temp.png');

    imageFile.writeAsBytesSync(bytes1);
    Share.shareFiles([imageFile.path], text: "${widget.model!.product_name}\n${shortenedLink.shortUrl.toString()}\n$shareLink");
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
                Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) => super.widget));
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

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isBottom ? Colors.transparent.withOpacity(0.5) : Theme.of(context).canvasColor,
      body: _isNetworkAvail
          ? Stack(
              children: <Widget>[
                _showContent(),
                Selector<CartProvider, bool>(
                  builder: (context, data, child) {
                    return showCircularProgress(data, colors.primary);
                  },
                  selector: (_, provider) => provider.isProgress,
                ),
              ],
            )
          : noInternet(context),
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget _slider() {
    double height = MediaQuery.of(context).size.height * .43;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ProductPreview(
                pos: _curSlider,
                secPos: widget.secPos,
                index: widget.index,
                id: widget.model!.product_id,
                imgList: sliderList,
                list: widget.list,
                video: widget.model!.video,
                videoType: widget.model!.videType,
                from: true,
                // screenSize: MediaQuery.of(context).size,
              ),
            ));
      },
      child: Stack(
        children: <Widget>[
          Hero(
              tag: "${widget.index}${widget.model!.product_id}",
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: statusBarHeight + kToolbarHeight),
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: sliderList.length,
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  reverse: false,
                  onPageChanged: (index) {
                    setState(() {
                      _curSlider = index;
                    });
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        sliderList[index] != "youtube"
                            ? FadeInImage(
                                image: NetworkImage(sliderList[index]!),
                                placeholder: const AssetImage(
                                  "assets/images/sliderph.png",
                                ),
                                fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                imageErrorBuilder: (context, error, stackTrace) => erroWidget(height),
                              )
                            : playIcon()
                      ],
                    );
                  },
                ),
              )),
          Positioned(
            bottom: 30,
            height: 20,
            width: deviceWidth,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: map<Widget>(
                sliderList,
                (index, url) {
                  return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: _curSlider == index ? 30.0 : 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.primary),
                        borderRadius: BorderRadius.circular(20.0),
                        color: _curSlider == index ? colors.primary : Colors.transparent,
                      ));
                },
              ),
            ),
          ),
          indicatorImage(),
        ],
      ),
    );
  }

  Widget shareIcn() {
    return InkWell(
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(
          Icons.share,
          size: 25.0,
          color: colors.primary,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 6.0),
            child: Text(
              getTranslated(context, 'SHARE_PRODUCT')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
            ),
          ),
        )
      ]),
      onTap: () {
        createDynamicLink();
      },
    );
  }

  Widget compareIcn() {
    return InkWell(
        onTap: () {
          if (compareList.isNotEmpty) {
            if (compareList[0].categoryId == widget.model!.categoryId) {
              compareSheet();
            } else {
              catCompareDailog();
            }
          } else {
            compareSheet();
          }
        },
        child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.compare,
            size: 25.0,
            color: colors.primary,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 6.0),
              child: Text(
                getTranslated(context, 'COMPARE_PRO')!,
                style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ]));
  }

  void loadMoreComPro() {
    setState(() {
      context.read<ProductDetailProvider>().setProNotiLoading(true);
      if (context.read<ProductDetailProvider>().offset < context.read<ProductDetailProvider>().total) getProduct1();
    });
  }

  void compareSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        isDismissible: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
                height: 365,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      height: 300,
                      padding: const EdgeInsetsDirectional.only(top: 20.0, start: 10.0, end: 10.0),
                      child: Selector<ProductDetailProvider, List<Product>>(
                        builder: (context, data, child) {
                          return data.isNotEmpty
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    return ListItemCom(
                                      productList: data[index],
                                      isSelected: (bool value) {
                                        setState(() {
                                          if (value) {
                                            var extPro = compareList.firstWhereOrNull((cp) => cp.product_id == data[index].product_id);
                                            if (extPro == null) {
                                              context.read<ProductDetailProvider>().addCompareList(data[index]);
                                            }
                                          } else {
                                            compareList.removeWhere((item) => item.product_id == data[index].product_id);
                                          }
                                        });
                                      },
                                      key: Key(data[index].product_id.toString()),
                                      index: index,
                                      len: data.length,
                                      secPos: widget.secPos,
                                    );
                                  },
                                )
                              : shimmerCompare();
                        },
                        selector: (_, productDetailPro) => productDetailPro.productList,
                      )),
                  Padding(
                      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0),
                      child: SimBtn(
                          width: 0.33,
                          height: 35,
                          title: getTranslated(context, 'COMPARE_LBL'),
                          onBtnSelected: () async {
                            var extPro = compareList.firstWhereOrNull((cp) => cp.product_id == widget.model!.product_id);

                            if (extPro == null) {
                              context.read<ProductDetailProvider>().addComFirstIndex(widget.model!);
                            } else {
                              compareList.removeWhere((item) => item.product_id == widget.model!.product_id);
                              await context.read<ProductDetailProvider>().addComFirstIndex(widget.model!);
                            }

                            setState(() {});
                            if (compareList.length > 1) {
                              await Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => const CompareList()));
                            } else {
                              setSnackbar(getTranslated(context, 'PLS_SEL_ONE_MORE_PRO_LBL')!, context);
                            }
                          }))
                ]));
          });
        });
  }

  catCompareDailog() async {
    await dialogAnimate(context, StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
          content: Text(
            getTranslated(context, 'COMPARETEXTDIG')!,
            style: Theme.of(this.context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(
                  getTranslated(context, 'OPENLIST')!,
                  style: Theme.of(this.context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => const CompareList()));
                }),
            TextButton(
                child: Text(
                  getTranslated(context, 'CLEARLIST')!,
                  style: Theme.of(this.context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  context.read<ProductDetailProvider>().removeCompareList();
                  Navigator.of(context).pop(false);
                  await getProduct1().whenComplete(() {
                    compareSheet();
                  });
                }),
          ],
        );
      });
    }));
  }

  Widget favImg() {
    return Selector<FavoriteProvider, List<String?>>(
      builder: (context, data, child) {
        return InkWell(
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            widget.model!.isFavLoading!
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 0.7,
                    ))
                : Icon(
                    !data.contains(widget.model!.product_id) ? Icons.favorite_border : Icons.favorite,
                    size: 25,
                    color: colors.primary,
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 6.0),
                child: Text(
                  getTranslated(context, 'FAVORITE')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                ),
              ),
            ),
          ]),
          onTap: () {
            if (CUR_MERCHANTID != null) {
              !data.contains(widget.model!.product_id) ? _setFav(-1) : _removeFav(-1);
            } else {
              if (!data.contains(widget.model!.product_id)) {
                widget.model!.isFavLoading = true;
                widget.model!.isFav = "1";
                context.read<FavoriteProvider>().addFavItem(widget.model);
                db.addAndRemoveFav(widget.model!.product_id!, true);
                widget.model!.isFavLoading = false;
              } else {
                widget.model!.isFavLoading = true;
                widget.model!.isFav = "0";
                context.read<FavoriteProvider>().removeFavItem(widget.model!.ProductAttributeValues![widget.model!.selVarient!].prodAttValue_id!);
                db.addAndRemoveFav(widget.model!.product_id!, false);
                widget.model!.isFavLoading = false;
              }
              setState(() {});
            }
          },
        );
      },
      selector: (_, provider) => provider.favIdList,
    );
  }

  indicatorImage() {
    String? indicator = widget.model!.indicator;
    return Positioned.fill(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
          alignment: Alignment.bottomLeft,
          child: indicator == "1"
              ? SvgPicture.asset("assets/images/vag.svg")
              : indicator == "2"
                  ? SvgPicture.asset("assets/images/nonvag.svg")
                  : Container()),
    ));
  }

  _rate() {
    return widget.model!.noOfRating! != "0"
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RatingBarIndicator(
                  rating: verfiedDouble(widget.model!.rating!),
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 12.0,
                  direction: Axis.horizontal,
                ),
                Text(
                  " ${widget.model!.rating!}",
                  style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
                ),
                Text(
                  " | ${widget.model!.noOfRating!} ${getTranslated(context, 'RATINGS')}",
                  style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
                )
              ],
            ),
          )
        : Container();
  }

  Widget _inclusiveTaxText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        "(${getTranslated(context, 'EXCLU_TAX')})",
        style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.lightBlack2, fontSize: 12),
      ),
    );
  }

  _price(pos, from) {
    log('Product_Detail _price pos=$pos from=$from');
    double price = widget.model!.ProductAttributeValues != null && widget.model!.ProductAttributeValues!.isNotEmpty
        ? widget.model!.ProductAttributeValues![pos].price1 == 'null'
            ? 0
            : verfiedDouble(widget.model!.ProductAttributeValues![pos].price1!)
        : 0;

    if (price == 0) {
      price = widget.model!.ProductAttributeValues != null && widget.model!.ProductAttributeValues!.isNotEmpty
          ? widget.model!.ProductAttributeValues![pos].old_price == 'null'
              ? 1
              : verfiedDouble(widget.model!.ProductAttributeValues![pos].old_price!)
          : 1;
    }
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${getPriceFormat(context, price)!} ',
                style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).colorScheme.fontColor)),
            from
                ? Selector<CartProvider, Tuple2<List<String?>, String?>>(
                    builder: (context, data, child) {
                      log('Product_Detail _price data=$data');
                      if (!qtyChange) {
                        if (data.item1.contains(widget.model!.ProductAttributeValues![pos].prodAttValue_id)) {
                          qtyController.text = data.item2.toString();
                        } else {
                          String qty = widget.model!.ProductAttributeValues != null && widget.model!.ProductAttributeValues!.isNotEmpty
                              ? widget.model!.ProductAttributeValues![pos].cartCount!
                              : "0";
                          if (qty == "0") {
                            qtyController.text = widget.model!.minOrderQty.toString();
                          } else {
                            qtyController.text = qty;
                          }
                        }
                        log('Product_Detail _price  qtyController.text=${qtyController.text}');
                      } else {
                        qtyChange = false;
                      }

                      return Padding(
                        padding: const EdgeInsetsDirectional.only(start: 3.0, bottom: 5, top: 3),
                        child: widget.model!.active == "0"
                            ? Container()
                            : Row(
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
                                      log('--- qtyController.text=${qtyController.text}');
                                      if (context.read<CartProvider>().isProgress == false && (int.parse(qtyController.text)) > 1) {
                                        log('--- if');
                                        addAndRemoveQty(
                                            qtyController.text,
                                            2,
                                            widget.model!.itemsCounter!.length * int.parse(widget.model!.qtyStepSize!),
                                            int.parse(widget.model!.qtyStepSize!));
                                      }
                                    },
                                  ),
                                  Container(
                                    width: 37,
                                    height: 20,
                                    color: Colors.transparent,
                                    child: Stack(
                                      children: [
                                        TextField(
                                          textAlign: TextAlign.center,
                                          readOnly: true,
                                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.fontColor),
                                          controller: qtyController,
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
                                            if (context.read<CartProvider>().isProgress == false) {
                                              addAndRemoveQty(value, 3, widget.model!.itemsCounter!.length * int.parse(widget.model!.qtyStepSize!),
                                                  int.parse(widget.model!.qtyStepSize!));
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return widget.model!.itemsCounter!.map<PopupMenuItem<String>>((String value) {
                                              return PopupMenuItem(
                                                  value: value, child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.fontColor)));
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
                                      log(' +++ qtyController.text=${qtyController.text}');

                                      if (context.read<CartProvider>().isProgress == false) {
                                        log('+++if');

                                        addAndRemoveQty(
                                            qtyController.text,
                                            1,
                                            widget.model!.itemsCounter!.length * int.parse(widget.model!.qtyStepSize!),
                                            int.parse(widget.model!.qtyStepSize!));
                                      }
                                    },
                                  )
                                ],
                              ),
                      );
                    },
                    selector: (_, provider) => Tuple2(
                        provider.cartIdList,
                        provider.qtyList(
                            widget.model!.product_id!,
                            widget.model!.ProductAttributeValues != null && widget.model!.ProductAttributeValues!.isNotEmpty
                                ? widget.model!.ProductAttributeValues![pos].prodAttValue_id!
                                : '0')),
                  )
                : Container(),
          ],
        ));
  }

  removeFromCart() async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (CUR_MERCHANTID != null) {
          if (mounted) {
            setState(() {
              context.read<CartProvider>().setProgress(true);
            });
          }

          int qty;

          Product model = widget.model!;

          qty = (int.parse(qtyController.text) - int.parse(model.qtyStepSize!));

          if (qty < int.parse(model.minOrderQty!)) {
            qty = 0;
          }

          var parameter = {
            PRODATTVALUE_ID: model.ProductAttributeValues![_oldSelVarient].prodAttValue_id,
            USER_ID: CUR_MERCHANTID,
            QTY: qty.toString()
          };

          apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              String? qty = data['total_quantity'];

              model.ProductAttributeValues![_oldSelVarient].cartCount = qty.toString();
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              setState(() {
                context.read<CartProvider>().setProgress(false);
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
            setState(() {
              context.read<CartProvider>().setProgress(false);
            });
          });
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const Login()),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  _offPrice(pos) {
    double price = widget.model!.ProductAttributeValues != null && widget.model!.ProductAttributeValues!.isNotEmpty
        ? widget.model!.ProductAttributeValues![pos].old_price == 'null'
            ? 0
            : verfiedDouble(widget.model!.ProductAttributeValues![pos].old_price!)
        : 0;

    if (price != 0) {
      double off =
          (verfiedDouble(widget.model!.ProductAttributeValues![pos].price1!) - verfiedDouble(widget.model!.ProductAttributeValues![pos].old_price!))
              .toDouble();
      off = off * 100 / verfiedDouble(widget.model!.ProductAttributeValues![pos].price1!);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _inclusiveTaxText(),
            Row(
              children: <Widget>[
                Text(
                  '${getPriceFormat(context, verfiedDouble(widget.model!.ProductAttributeValues![pos].old_price!))!} ',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      decoration: TextDecoration.lineThrough, letterSpacing: 0, color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7)),
                ),
                Text(" | ${off.toStringAsFixed(0)}% ${getTranslated(context, 'OFF_LBL')}",
                    style: Theme.of(context).textTheme.overline!.copyWith(color: colors.primary, letterSpacing: 0)),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Text(
        widget.model!.product_name!,
        style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
      ),
    );
  }

  _desc() {
    return widget.model!.product_desc != null && widget.model!.product_desc != '' && widget.model!.product_desc!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Html(
              data: widget.model?.product_fullDesc ?? 'noData',
              onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) async {
                if (await canLaunch(url!)) {
                  await launch(
                    url,
                    forceSafariVC: false,
                    forceWebView: false,
                  );
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          )
        : Container();
  }

  onSelectFun(bool selected, int index, int i, bool available, bool outOfStock, int? selectIndex) async {
    log('Product Detail onSelectFun Started ');
    if (mounted) {
      setState(() {
        available = false;
        _selectedIndex[index] = selected ? i : null;
        List<int> selectedId = [];
        List<bool> check = [];

        for (int i = 0; i < widget.model!.ProductAttributeValues![widget.model!.selVarient!].Attributes!.length; i++) {
          List<String> attId = List<String>.from(attvalList.map((e) => e.attribute_id == attList[i].attribute_id ? e.attributeValue_id : ''));
          attId.removeWhere((e) => e.isEmpty);

          log('onSelectFun attId=$attId  -- i=$i');
          if (_selectedIndex[i] != null) {
            selectedId.add(int.parse(attId[_selectedIndex[i]!]));
          }
        }
        check.clear();
        late List<String> sinId;
        findMatch:
        for (int i = 0; i < widget.model!.ProductAttributeValues!.length; i++) {
          sinId = widget.model!.ProductAttributeValues![i].AttributeValues!.map((e) => e.attributeValue_id!).toList();

          // widget.model!.ProductAttributeValues![i].attribute_value_ids!.split(",");

          for (int j = 0; j < selectedId.length; j++) {
            if (sinId.contains(selectedId[j].toString())) {
              check.add(true);

              if (selectedId.length == sinId.length && check.length == selectedId.length) {
                varSelected = i;
                selectIndex = i;
                break findMatch;
              }
            } else {
              check.clear();
              selectIndex = null;
              break;
            }
          }
          log('sinId =$sinId ');
        }

        if (selectedId.length == sinId.length && check.length == selectedId.length) {
          if (widget.model!.stockType == "0" || widget.model!.stockType == "1") {
            if (widget.model!.active == "1") {
              available = true;
              outOfStock = false;
              _oldSelVarient = varSelected!;
            } else {
              available = false;
              outOfStock = true;
              _oldSelVarient = varSelected!;
            }
          } else if (widget.model!.stockType == "") {
            available = true;
            outOfStock = false;
            _oldSelVarient = varSelected!;
          } else if (widget.model!.stockType == "2") {
            if (widget.model!.ProductAttributeValues![varSelected!].active == "1") {
              available = true;
              outOfStock = false;
              _oldSelVarient = varSelected!;
            } else {
              available = false;
              outOfStock = true;
              _oldSelVarient = varSelected!;
            }
          }
        } else {
          available = false;
          outOfStock = false;
        }
        if (widget.model!.ProductAttributeValues![_oldSelVarient].ProductImages!.isNotEmpty) {
          int oldVarTotal = 0;
          if (_oldSelVarient > 0)
            for (int i = 0; i < _oldSelVarient; i++) {
              oldVarTotal = oldVarTotal + widget.model!.ProductAttributeValues![i].ProductImages!.length;
            }
          int p = widget.model!.otherImage!.length + 1 + oldVarTotal;

          _pageController.jumpToPage(p);
        }
      });
    }
    widget.model!.selVarient = _oldSelVarient;
    if (available) {
      if (CUR_MERCHANTID != null) {
        if (widget.model!.ProductAttributeValues![widget.model!.selVarient!].cartCount! != "0") {
          qtyController.text = widget.model!.ProductAttributeValues![widget.model!.selVarient!].cartCount!;
          qtyChange = true;
        } else {
          qtyController.text = widget.model!.minOrderQty.toString();
          qtyChange = true;
        }
      } else {
        String qty = (await db.checkCartItemExists(
            widget.model!.product_id!, widget.model!.ProductAttributeValues![widget.model!.selVarient!].prodAttValue_id!))!;
        if (qty == "0") {
          qtyController.text = widget.model!.minOrderQty.toString();
          qtyChange = true;
        } else {
          widget.model!.ProductAttributeValues![widget.model!.selVarient!].cartCount = qty;
          qtyController.text = qty;
          qtyChange = true;
        }
      }
    }
    setState(() {});
  }

  _getVarient() {
    return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: Card(
          elevation: 0,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attList.isNotEmpty ? attList.length : 0,
            itemBuilder: (context, index) {
              // log('_getVarient index=$index');
              List<Widget?> chips = [];

              List<String> att = List<String>.from(attvalList.map((e) => e.attribute_id == attList[index].attribute_id ? e.attributeValue_name : ''));
              att.removeWhere((e) => e.isEmpty);

              // log('Product_Detail _getVarient');

              List<String> attId = List<String>.from(attvalList.map((e) => e.attribute_id == attList[index].attribute_id ? e.attributeValue_id : ''));
              attId.removeWhere((e) => e.isEmpty);

              log('Product_Detail _getVarient attId=(attributeValue_id)=$attId &&  att=(attributeValue_name)=$att');

              List<String> attSType =
                  List<String>.from(attvalList.map((e) => e.attribute_id == attList[index].attribute_id ? attList[index].attributeType_id : ''));
              attSType.removeWhere((e) => e.isEmpty);

              // log('Product_Detail _getVarient attSType (attributeType_id)=$attSType');
              List<String> attSValue =
                  List<String>.from(attvalList.map((e) => e.attribute_id == attList[index].attribute_id ? e.attributeValue_value ?? '' : ''));
              attSValue.removeWhere((e) => e.isEmpty);

              // log('Product_Detail _getVarient attSValue (attributeValue_value)=$attSValue');
              int? varSelected;

              for (int i = 0; i < att.length; i++) {
                Widget itemLabel;
                if (attSType[i] == '1') {
                  String clr = (attSValue[i].substring(1));
                  String color = '0xff$clr';
                  itemLabel = Container(
                    width: 25,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Color(int.parse(color))),
                  );
                } else {
                  itemLabel = Text(att[i], //--${attId[i]}',
                      style: TextStyle(
                          color: _selectedIndex[index] == (i) ? Theme.of(context).colorScheme.white : Theme.of(context).colorScheme.fontColor));
                }

                if (_selectedIndex[index] != null && wholeAtt.contains(attId[i])) {
                  log('_selectedIndex=$_selectedIndex .length=${_selectedIndex.length}  _selectedIndex[index=$index]=${_selectedIndex[index]} i=$i && wholeAtt.contains(attId[i=$i])=$wholeAtt contains(${attId[i]}) --   selected: ${_selectedIndex.length > index ? attId.length == 1 ? true : _selectedIndex[index] == i : false}');
                  choiceChip = ChoiceChip(
                    // selected: _selectedIndex.length > index ? _selectedIndex[index] == i : false,
                    selected: _selectedIndex.length > index
                        ? attId.length == 1
                            ? true
                            : _selectedIndex[index] == i
                        : false,
                    label: itemLabel,
                    selectedColor: colors.primary,
                    backgroundColor: Theme.of(context).colorScheme.white,
                    labelPadding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(attSType[i] == '1' ? 100 : 10),
                      side: BorderSide(color: _selectedIndex[index] == (i) ? colors.primary : colors.black12, width: 1.5),
                    ),
                    onSelected:
                        // att.length == 1
                        //     ? null
                        //     :
                        (bool selected) async {
                      log('Product Detail _getVarient onSelected -- _oldSelVarient=$_oldSelVarient  widget.model!.selVarient=${widget.model!.selVarient}');
                      // log('i=$i');
                      // log('_selectedIndex[index]=${_selectedIndex[index]}');
                      if (selected) {
                        if (mounted) {
                          setState(() {
                            widget.model!.selVarient = _oldSelVarient;
                            available = false;
                            _selectedIndex[index] = selected ? i : null;
                            List<int> selectedId = []; //list where user choosen item id is stored
                            List<bool> check = [];
                            for (int k = 0; k < attList.length; k++) {
                              List<String> attId =
                                  List<String>.from(attvalList.map((e) => e.attribute_id == attList[k].attribute_id ? e.attributeValue_id : ''));
                              attId.removeWhere((e) => e.isEmpty);
                              log('2222 Product_Detail _getVarient attId(attributeValue_id)=$attId');

                              if (_selectedIndex[k] != null && _selectedIndex[k]! < attId.length) {
                                selectedId.add(int.parse(attId[_selectedIndex[k]!]));
                              }
                            }
                            check.clear();
                            late List<String> sinId;
                            // sinId = attvalList.map((e) => e.attributeValue_id!).toList();

                            findMatch:
                            for (int x = 0; x < widget.model!.ProductAttributeValues!.length; x++) {
                              sinId = widget.model!.ProductAttributeValues![x].AttributeValues!.map((e) => e.attributeValue_id!).toList();

                              for (int j = 0; j < selectedId.length; j++) {
                                log('findMatch sinId =$sinId -- selectedId[j]=${selectedId[j]} -- j=$j -- x=$x');

                                if (sinId.contains(selectedId[j].toString())) {
                                  check.add(true);
                                  if (selectedId.length == sinId.length && check.length == selectedId.length) {
                                    // if ( check.length == selectedId.length) {
                                    log('findMatch selectIndex=$x');
                                    varSelected = x; //get the selected index of ProductAttributeValue.
                                    selectIndex = x; //get the selected index of ProductAttributeValue.
                                    break findMatch;
                                  }
                                } else {
                                  check.clear();
                                  selectIndex = null;
                                  break;
                                }
                              }
                            }
                            log('sinId =$sinId    selectedId =$selectedId');

                            if (selectedId.length == sinId.length && check.length == selectedId.length) {
                              if (widget.model!.stockType == '0' || widget.model!.stockType == '1') {
                                if (widget.model!.active == '1') {
                                  available = true;
                                  outOfStock = false;
                                  _oldSelVarient = varSelected!;
                                } else {
                                  available = false;
                                  outOfStock = true;
                                }
                              } else if (widget.model!.stockType == '') {
                                available = true;
                                outOfStock = false;
                                _oldSelVarient = varSelected!;
                              } else if (widget.model!.stockType == '2') {
                                if (widget.model!.ProductAttributeValues![varSelected!].active == '1') {
                                  available = true;
                                  outOfStock = false;
                                  _oldSelVarient = varSelected!;
                                } else {
                                  available = false;
                                  outOfStock = true;
                                }
                              }
                            } else {
                              available = false;
                              outOfStock = false;
                            }
                            if (widget.model!.ProductAttributeValues![_oldSelVarient].ProductImages!.isNotEmpty) {
                              int oldVarTotal = 0;
                              if (_oldSelVarient > 0) {
                                for (int i = 0; i < _oldSelVarient; i++) {
                                  oldVarTotal = oldVarTotal + widget.model!.ProductAttributeValues![i].ProductImages!.length;
                                }
                              }
                              int p = widget.model!.ProductImages!.length + 1 + oldVarTotal;
                              _pageController.jumpToPage(p);
                            }
                          });
                        } else {}
                      } else {
                        null;
                      }
                      if (available!) {
                        if (CUR_MERCHANTID != null) {
                          log('3333 Product_Detail _getVarient if(CUR_MERCHANTID($CUR_MERCHANTID) !=null) -- widget.model!.ProductAttributeValues![_oldSelVarient].cartCount!=${widget.model!.ProductAttributeValues![_oldSelVarient].cartCount!}');

                          if (widget.model!.ProductAttributeValues![_oldSelVarient].cartCount! != "0") {
                            qtyController.text = widget.model!.ProductAttributeValues![_oldSelVarient].cartCount!;
                            qtyChange = true;
                          } else {
                            qtyController.text = widget.model!.minOrderQty.toString();
                            qtyChange = true;
                          }
                        } else {
                          log('4444 Product_Detail _getVarient else qty=db.checkCartItemExists(widget.model!.ProductAttributeValues![_oldSelVarient].prodAttValue_id!(${widget.model!.ProductAttributeValues![_oldSelVarient].prodAttValue_id!})');
                          String qty = (await db.checkCartItemExists(
                              widget.model!.product_id!, widget.model!.ProductAttributeValues![_oldSelVarient].prodAttValue_id!))!;
                          if (qty == "0") {
                            qtyController.text = widget.model!.minOrderQty.toString();
                            qtyChange = true;
                          } else {
                            widget.model!.ProductAttributeValues![_oldSelVarient].cartCount = qty;
                            qtyController.text = qty;
                            qtyChange = true;
                          }
                        }
                      }
                    },
                  );

                  chips.add(choiceChip);
                }
              }
              // log('Product Detail _getVarient  _selectedIndex[index]=${_selectedIndex[index]}');
              // String value = _selectedIndex[index] != null && _selectedIndex[index]! <= att.length
              _selectedIndex[index] != null && _selectedIndex[index]! >= att.length ? _selectedIndex[index] != att.length - 1 : '';
              String value = _selectedIndex[index] != null
                  ? _selectedIndex[index]! < att.length
                      ? att[_selectedIndex[index]!]
                      : att[att.length - 1]
                  : getTranslated(context, 'VAR_SEL')!.substring(2, getTranslated(context, 'VAR_SEL')!.length);
              return chips.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                "${attList[index].attribute_name!} : ",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                value,
                                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                                      color: Theme.of(context).colorScheme.fontColor,
                                    ),
                              ),
                            ],
                          ),
                          Wrap(
                            children: chips.map<Widget>((Widget? chip) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: chip,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    )
                  : Container();
            },
          ),
        ));
  }

  void _pincodeCheck() {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: ListView(shrinkWrap: true, children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) => validatePincode(val!, getTranslated(context, 'PIN_REQUIRED')),
                                onSaved: (String? value) {
                                  if (value != null) curPin = value;
                                },
                                style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.location_on),
                                  hintText: getTranslated(context, 'PINCODEHINT_LBL'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SimBtn(
                                    width: 1.0,
                                    height: 35,
                                    title: getTranslated(context, 'APPLY'),
                                    onBtnSelected: () async {
                                      if (validateAndSave()) {
                                        validatePin(curPin, false);
                                      }
                                    }),
                              ),
                            ],
                          )),
                    ))
              ]),
            );
          });
        });
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  applyVarient() {
    if (mounted) {
      setState(() {
        widget.model!.selVarient = _oldSelVarient;
      });
    }
  }

  addAndRemoveQty(String qty, int from, int totalLen, int itemCounter) {
    Product model = widget.model!;

    if (CUR_MERCHANTID != null || CUR_MERCHANTID != "") {
      if (from == 1) {
        if (int.parse(qty) >= totalLen) {
          qtyController.text = totalLen.toString();
          qtyChange = true;
          setSnackbar("${getTranslated(context, 'MAXQTY')!}  $qty", context);
        } else {
          qtyController.text = (int.parse(qty) + (itemCounter)).toString();
          qtyChange = true;
        }
      } else if (from == 2) {
        if (int.parse(qty) <= int.parse(model.minOrderQty!)) {
          qtyController.text = itemCounter.toString();
          qtyChange = true;
        } else {
          qtyController.text = (int.parse(qty) - itemCounter).toString();
          qtyChange = true;
        }
      } else {
        qtyController.text = qty;
        qtyChange = true;
      }
      context.read<CartProvider>().setProgress(false);
      setState(() {});
    } else {
      if (from == 1) {
        if (int.parse(qty) >= totalLen) {
          qtyController.text = totalLen.toString();
          setSnackbar("${getTranslated(context, 'MAXQTY')!}  $qty", context);
        } else {
          qtyController.text = (int.parse(qty) + (itemCounter)).toString();
          qtyChange = true;
        }
      } else if (from == 2) {
        if (int.parse(qty) <= int.parse(model.minOrderQty!)) {
          qtyController.text = itemCounter.toString();
          qtyChange = true;
        } else {
          qtyController.text = (int.parse(qty) - itemCounter).toString();
          qtyChange = true;
        }
      } else {
        qtyController.text = qty;
        qtyChange = true;
      }
      context.read<CartProvider>().setProgress(false);
      setState(() {});
    }
  }

  Future<void> addToCart(String qty, bool intent, bool from, Product product) async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        setState(() {
          qtyChange = true;
        });
        if (CUR_MERCHANTID != null) {
          try {
            if (mounted) {
              setState(() {
                context.read<CartProvider>().setProgress(true);
              });
            }

            Product model = widget.model!;

            if (int.parse(qty) < int.parse(model.minOrderQty!)) {
              qty = model.minOrderQty.toString();
              setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
            }

            var parameter = {
              MERCHANTUSER_ID: CUR_MERCHANTID,
              MERCHANT_ID: CUR_MERCHANTID,
              PRODATTVALUE_ID: model.ProductAttributeValues![_oldSelVarient].prodAttValue_id,
              CARTITEM_QTY: qty,
            };

            apiBaseHelper.postNumoAPICall(getNumoCartsApi, parameter).then((getdata) {
              // bool error = getdata["error"];
              // String? msg = getdata["message"];
              // if (!error) {
              // var data = getdata["data"];
              var data = getdata;

              widget.model!.ProductAttributeValues![_oldSelVarient].cartCount = qty.toString();
              if (from) {
                context.read<UserProvider>().setCartCount(data['cart_count']);
                var cart = getdata["cart"];
                List<SectionModel> cartList = [];
                cartList = (cart as List).map((cart) => SectionModel.fromCart(cart)).toList();

                context.read<CartProvider>().setCartlist(cartList);
                if (intent) {
                  cartTotalClear();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const Cart(
                        fromBottom: false,
                      ),
                    ),
                  );
                }
              }
              // } else {
              //   setSnackbar(msg!, context);
              // }
              if (mounted) {
                setState(() {
                  context.read<CartProvider>().setProgress(false);
                });
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });

            // apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
            //   bool error = getdata["error"];
            //   String? msg = getdata["message"];
            //   if (!error) {
            //     var data = getdata["data"];
            //     widget.model!.ProductAttributeValues![_oldSelVarient].cartCount = qty.toString();
            //     if (from) {
            //       context.read<UserProvider>().setCartCount(data['cart_count']);
            //       var cart = getdata["cart"];
            //       List<SectionModel> cartList = [];
            //       cartList = (cart as List).map((cart) => SectionModel.fromCart(cart)).toList();
            //       context.read<CartProvider>().setCartlist(cartList);
            //       if (intent) {
            //         cartTotalClear();
            //         Navigator.push(
            //           context,
            //           CupertinoPageRoute(
            //             builder: (context) => const Cart(
            //               fromBottom: false,
            //             ),
            //           ),
            //         );
            //       }
            //     }
            //   } else {
            //     setSnackbar(msg!, context);
            //   }
            //   if (mounted) {
            //     setState(() {
            //       context.read<CartProvider>().setProgress(false);
            //     });
            //   }
            // }, onError: (error) {
            //   setSnackbar(error.toString(), context);
            // });

          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            if (mounted) {
              setState(() {
                context.read<CartProvider>().setProgress(false);
              });
            }
          }
        } else {
          List<Product>? prList = [];
          prList.add(widget.model!);
          context.read<CartProvider>().addCartItem(SectionModel(
                cartItem_qty: qty,
                productList: prList,
                prodAttValue_id: widget.model!.ProductAttributeValues![_oldSelVarient].prodAttValue_id!,
                product_id: widget.model!.product_id,
              ));
          db.insertCart(widget.model!.product_id!, widget.model!.ProductAttributeValues![_oldSelVarient].prodAttValue_id!, qty, context);
          Future.delayed(const Duration(milliseconds: 100)).then((_) async {
            if (from && intent) {
              cartTotalClear();
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const Cart(
                    fromBottom: false,
                  ),
                ),
              );
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> getReview() async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var parameter = {
            PRODUCT_ID: widget.model!.product_id,
            LIMIT: perPage.toString(),
            OFFSET: offset.toString(),
          };
          apiBaseHelper.postAPICall(getRatingApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              total = int.parse(getdata["total"]);

              star1 = getdata["star_1"];
              star2 = getdata["star_2"];
              star3 = getdata["star_3"];
              star4 = getdata["star_4"];
              star5 = getdata["star_5"];
              if ((offset) < total) {
                var data = getdata["data"];
                reviewList = (data as List).map((data) => User.forReview(data)).toList();

                offset = offset + perPage;
              }
            } else {
              if (msg != "No ratings found !") setSnackbar(msg!, context);
            }
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          if (mounted) {
            setState(() {
              _isLoading = false;
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
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  _setFav(int index) async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          if (mounted) {
            setState(() {
              index == -1 ? widget.model!.isFavLoading = true : productList[index].isFavLoading = true;
            });
          }

          var parameter = {USER_ID: CUR_MERCHANTID, PRODUCT_ID: widget.model!.product_id};
          apiBaseHelper.postAPICall(setFavoriteApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              index == -1 ? widget.model!.isFav = "1" : productList[index].isFav = "1";

              context.read<FavoriteProvider>().addFavItem(widget.model);
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              setState(() {
                index == -1 ? widget.model!.isFavLoading = false : productList[index].isFavLoading = false;
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
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  _removeFav(int index) async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          if (mounted) {
            setState(() {
              index == -1 ? widget.model!.isFavLoading = true : productList[index].isFavLoading = true;
            });
          }

          var parameter = {USER_ID: CUR_MERCHANTID, PRODUCT_ID: widget.model!.product_id};
          apiBaseHelper.postAPICall(removeFavApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              index == -1 ? widget.model!.isFav = "0" : productList[index].isFav = "0";
              context.read<FavoriteProvider>().removeFavItem(widget.model!.ProductAttributeValues![widget.model!.selVarient!].prodAttValue_id!);
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              setState(() {
                index == -1 ? widget.model!.isFavLoading = false : productList[index].isFavLoading = false;
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
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  _showContent() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Expanded(
          child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: <Widget>[
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * .43,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.white,
          stretch: true,
          leading: Builder(builder: (BuildContext context) {
            log('Product_Detail _showContent Builder');
            return Container(
              margin: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: colors.primary,
                  ),
                ),
              ),
            );
          }),
          actions: [
            IconButton(
                icon: SvgPicture.asset(
                  "${imagePath}search.svg",
                  height: 20,
                  color: colors.primary,
                ),
                onPressed: () {
                  log('Product_Detail _showContent IconeButton onPressed nivigate-> search');
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const Search(),
                      ));
                }),
            IconButton(
                icon: SvgPicture.asset(
                  "${imagePath}desel_fav.svg",
                  height: 20,
                  color: colors.primary,
                ),
                onPressed: () {
                  log('Product_Detail _showContent IconeButton onPressed nivigate-> Favorite');

                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const Favorite(),
                      ));
                }),
            Selector<UserProvider, String>(
              builder: (context, data, child) {
                log('Product_Detail _showContent Selector UserProvider data=$data');

                return IconButton(
                  icon: Stack(
                    children: [
                      Center(
                          child: SvgPicture.asset(
                        "${imagePath}appbarCart.svg",
                        color: colors.primary,
                      )),
                      (data != "" && data.isNotEmpty && data != "0")
                          ? Positioned(
                              bottom: 20,
                              right: 0,
                              child: Container(
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: colors.primary),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: Text(
                                        data,
                                        style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.white),
                                      ),
                                    ),
                                  )),
                            )
                          : Container()
                    ],
                  ),
                  onPressed: () {
                    log('_showContent Selector UserProvider IconeButton onPressed navigate-> Cart');

                    cartTotalClear();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const Cart(
                          fromBottom: false,
                        ),
                      ),
                    );
                  },
                );
              },
              selector: (_, homeProvider) => homeProvider.curCartCount,
            )
          ],
          title: Text(
            widget.model!.product_name ?? '',
            maxLines: 1,
            style: const TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _slider(),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                showBtn(), //share favorite , compare under product image galary
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _title(),
                          _rate(),
                          _price(_oldSelVarient, true),
                          _offPrice(_oldSelVarient),
                          _shortDesc(),
                        ],
                      ),
                    ),
                    _getVarient(),
                    _specification(),
                    _speciExtraBtnDetails(),
                    _deliverPincode(),
                  ],
                ),
                reviewList.isNotEmpty
                    ? Card(
                        elevation: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _reviewTitle(),
                            _reviewStar(),
                            _reviewImg(),
                            _review(),
                          ],
                        ),
                      )
                    : Container(),
                // faqsQuesAndAns(),
                productList.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          getTranslated(context, 'MORE_PRODUCT')!,
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                        ),
                      )
                    : Container(),
                productList.isNotEmpty
                    ? Container(
                        height: 230,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                                getProduct();
                              }
                              return true;
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: (notificationoffset < totalProduct) ? productList.length + 1 : productList.length,
                              itemBuilder: (context, index) {
                                return (index == productList.length && !notificationisloadmore) ? simmerSingle() : productItem(index, 2);
                              },
                            )))
                    : Container(
                        height: 0,
                      ),
              ],
            )
          ]),
        )
      ])),
      widget.model!.ProductAttributeValues != null && widget.model!.ProductAttributeValues!.isNotEmpty
          ? widget.model!.ProductAttributeValues![widget.model!.selVarient!].Attributes!.isNotEmpty //isEmpty
              ? widget.model!.active != "0"
                  ? Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white,
                        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                String qty;
                                qty = qtyController.text;
                                addToCart(qty, false, true, widget.model!);
                              },
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'ADD_CART')!,
                                style: Theme.of(context).textTheme.button!.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
                              )),
                            ),
                          )),
                          Expanded(
                              child: SimBtn(
                                  width: 0.8,
                                  height: 55,
                                  title: getTranslated(context, 'BUYNOW'),
                                  onBtnSelected: () async {
                                    String qty;

                                    qty = qtyController.text;

                                    addToCart(qty, true, true, widget.model!);
                                  })),
                        ],
                      ),
                    )
                  : Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white,
                        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
                      ),
                      child: Center(
                          child: Text(
                        getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                        style: Theme.of(context).textTheme.button!.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                      )),
                    )
              : available!
                  ? Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white,
                        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                String qty;

                                qty = qtyController.text;

                                addToCart(qty, false, true, widget.model!);
                              },
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'ADD_CART')!,
                                style: Theme.of(context).textTheme.button!.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
                              )),
                            ),
                          )),
                          Expanded(
                              child: SimBtn(
                                  width: 0.8,
                                  height: 55,
                                  title: getTranslated(context, 'BUYNOW'),
                                  onBtnSelected: () async {
                                    String qty;

                                    qty = qtyController.text;

                                    addToCart(qty, true, true, widget.model!);
                                  })),
                        ],
                      ),
                    )
                  : available == false || outOfStock == true
                      ? outOfStock == true
                          ? Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.white,
                                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
                              ),
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                                style: Theme.of(context).textTheme.button!.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                              )),
                            )
                          : Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.white,
                                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
                              ),
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'VAR_NT_AVAIL_LBL')!,
                                style: Theme.of(context).textTheme.button!.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                              )),
                            )
                      : Container()
          : Container()
    ]);
  }

  postQues() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(getTranslated(context, 'HAVE_DOUBTS_REG_THIS_PRO_LBL')!,
              style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.fontColor)),
          Padding(
              padding: EdgeInsetsDirectional.only(top: 10, bottom: 5),
              child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    openPostQueBottomSheet();
                  },
                  child: Container(
                      width: double.maxFinite,
                      height: 38.5,
                      alignment: FractionalOffset.center,
                      decoration: BoxDecoration(
                        //color: colors.primary,
                        border: Border.all(color: Theme.of(context).colorScheme.lightBlack.withOpacity(0.4)),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(getTranslated(context, 'POST_YR_QUE_LBL')!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle2!.copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                              )))))
        ],
      ),
    );
  }

  Future<void> setFaqsQue() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_MERCHANTID, PRODUCT_ID: widget.model!.product_id, QUESTION: edtFaqs.text.trim()};
        apiBaseHelper.postAPICall(setProductFaqsApi, parameter).then((getdata) {
          print("getdata****$getdata");
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            setSnackbar(msg!, context);
            edtFaqs.clear();
            Navigator.pop(context);
          } else {
            setSnackbar(msg!, context);
          }
          context.read<CartProvider>().setProgress(false);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else if (mounted) {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  void openPostQueBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: const BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            return Form(
              key: faqsKey,
              child: Wrap(
                children: [
                  bottomSheetHandle(context),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                      color: Theme.of(context).colorScheme.white,
                    ),
                    padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                            child: Text(
                              getTranslated(context, 'WRITE_QUE_LBL')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.fontColor),
                            )),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(top: 10.0),
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                              Padding(
                                padding: EdgeInsetsDirectional.only(start: 20, end: 20),
                                child: Container(
                                  // padding: EdgeInsetsDirectional.only(start: 10,end: 10),
                                  height: MediaQuery.of(context).size.height * 0.25,
                                  decoration:
                                      BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Theme.of(context).colorScheme.lightWhite),
                                  child: TextFormField(
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.fontColor,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 14.0),
                                    onChanged: (value) {},
                                    onSaved: ((String? val) {}),
                                    maxLines: null,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return getTranslated(context, 'PLS_PRO_MORE_DET_LBL');
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: getTranslated(context, 'TYPE_YR_QUE_LBL'),
                                      contentPadding: const EdgeInsetsDirectional.all(25.0),
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.lightWhite,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: const BorderSide(width: 0.0, style: BorderStyle.none)),
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    controller: edtFaqs,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.all(20),
                                child: SimBtn(
                                  title: getTranslated(context, 'SUBMIT_LBL'),
                                  height: 45,
                                  width: deviceWidth,
                                  onBtnSelected: () {
                                    final form = faqsKey.currentState!;

                                    form.save();
                                    if (form.validate()) {
                                      context.read<CartProvider>().setProgress(true);
                                      setFaqsQue();
                                    }
                                  },
                                ),
                              )
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  faqsQuesAndAns() {
    return Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 10, end: 10, bottom: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _faqsQue(),
              CUR_MERCHANTID != "" && CUR_MERCHANTID != null ? postQues() : SizedBox(),
              if (faqsProductList.isNotEmpty) _allQuesBtn()
            ],
          ),
        ));
  }

  _allQuesBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => FaqsProduct(widget.model!.product_id)),
            );
          },
          child: Row(
            children: [
              Text(
                getTranslated(context, 'ALL_QUE_LBL')!,
                style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).colorScheme.lightBlack.withOpacity(0.7),
              )
            ],
          ) /*ListTile(
            dense: true,

            title: Text(
              "All Questions",
              style: TextStyle(color: Theme.of(context).colorScheme.fontColor,fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),*/
          ),
    );
  }

  showBtn() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(top: 5.0),
        child: Card(
            elevation: 0,
            child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 5, end: 5, top: 5.0, bottom: 5.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: favImg(),
                    ),
                    Expanded(
                      flex: 2,
                      child: shareIcn(),
                    ),
                    Expanded(
                      flex: 3,
                      child: compareIcn(),
                    ),
                  ],
                ))));
  }

  simmerSingle() {
    return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.simmerBase,
          highlightColor: Theme.of(context).colorScheme.simmerHigh,
          child: Container(
            width: deviceWidth! * 0.45,
            height: 250,
            color: Theme.of(context).colorScheme.white,
          ),
        ));
  }

  shimmerCompare() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.gray,
      highlightColor: Theme.of(context).colorScheme.gray,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 8.0),
            child: Container(
              width: deviceWidth! * 0.45,
              height: 255,
              color: Theme.of(context).colorScheme.white,
            )),
        itemCount: 10,
      ),
    );
  }

  _madeIn() {
    String? madeIn = widget.model!.madein;

    return madeIn != "" && madeIn!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListTile(
              trailing: Text(madeIn),
              dense: true,
              title: Text(
                getTranslated(context, 'MADE_IN')!,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          )
        : Container();
  }

  Widget productItem(int index, int from) {
    if (index < productList.length) {
      String? offPer;
      double price = productList[index].ProductAttributeValues != null && productList[index].ProductAttributeValues!.isNotEmpty
          ? verfiedDouble(productList[index].ProductAttributeValues![0].old_price!)
          : 0;

      if (price == 0) {
        price = productList[index].ProductAttributeValues != null && productList[index].ProductAttributeValues!.isNotEmpty
            ? verfiedDouble(productList[index].ProductAttributeValues![0].price1!)
            : 0;
      } else {
        double off = verfiedDouble(productList[index].ProductAttributeValues![0].price1!) - price;
        offPer = ((off * 100) / verfiedDouble(productList[index].ProductAttributeValues![0].price1!)).toStringAsFixed(0);
      }

      double width = deviceWidth! * 0.45;

      return SizedBox(
          height: 255,
          width: width,
          child: Card(
            elevation: 0.2,
            margin: const EdgeInsetsDirectional.only(bottom: 5, end: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  from == 1
                      ? Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsetsDirectional.only(end: 5.0, top: 5.0),
                          child: const Icon(
                            Icons.circle,
                            size: 30,
                          ))
                      : Container(),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                            padding: const EdgeInsetsDirectional.only(top: 8.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                              child: Hero(
                                tag: "$index${productList[index].product_id}",
                                child: FadeInImage(
                                  image: NetworkImage(productList[index].ProductImages != null && productList[index].ProductImages!.isNotEmpty
                                      ? productList[index].ProductImages![0].image_url
                                      : erroWidget(double.maxFinite)),
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                  imageErrorBuilder: (context, error, stackTrace) => erroWidget(
                                    double.maxFinite,
                                  ),
                                  placeholder: placeHolder(
                                    double.maxFinite,
                                  ),
                                ),
                              ),
                            )),
                        offPer != null
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  decoration: BoxDecoration(color: colors.red, borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.all(5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      "$offPer%",
                                      style: const TextStyle(color: colors.whiteTemp, fontWeight: FontWeight.bold, fontSize: 9),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        const Divider(
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 5.0,
                      top: 5,
                    ),
                    child: Row(
                      children: [
                        RatingBarIndicator(
                          rating: verfiedDouble(productList[index].rating!),
                          itemBuilder: (context, index) => const Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                          ),
                          unratedColor: Colors.grey.withOpacity(0.5),
                          itemCount: 5,
                          itemSize: 12.0,
                          direction: Axis.horizontal,
                          itemPadding: const EdgeInsets.all(0),
                        ),
                        Text(
                          " (${productList[index].noOfRating!})",
                          style: Theme.of(context).textTheme.overline,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 5.0, top: 5, bottom: 5),
                    child: Text(
                      productList[index].product_name!,
                      style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      // Text('${getPriceFormat(context, price)!} ',
                      //     style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold)),
                      ImageFiltered(
                        imageFilter: IS_LOGGINED ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Text('${getPriceFormat(context, price)!} ',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold)),
                      ),
                      // Text(
                      //   productList[index].ProductAttributeValues != null && productList[index].ProductAttributeValues!.isNotEmpty
                      //       ? verfiedDouble(productList[index].ProductAttributeValues![0].old_price!) != 0
                      //           ? getPriceFormat(context, verfiedDouble(productList[index].ProductAttributeValues![0].price1!))!
                      //           : ""
                      //       : '',
                      //   style: Theme.of(context).textTheme.overline!.copyWith(decoration: TextDecoration.lineThrough, letterSpacing: 0),
                      // ),
                      ImageFiltered(
                          imageFilter: IS_LOGGINED ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Text(
                            productList[index].ProductAttributeValues != null && productList[index].ProductAttributeValues!.isNotEmpty
                                ? verfiedDouble(productList[index].ProductAttributeValues![0].old_price!) != 0
                                    ? getPriceFormat(context, verfiedDouble(productList[index].ProductAttributeValues![0].price1!))!
                                    : ""
                                : '',
                            style: Theme.of(context).textTheme.overline!.copyWith(decoration: TextDecoration.lineThrough, letterSpacing: 0),
                          )),
                    ],
                  ),
                ],
              ),
              onTap: () {
                Product model = productList[index];
                notificationoffset = 0;
                Navigator.push(
                  context,
                  PageRouteBuilder(pageBuilder: (_, __, ___) => ProductDetail(model: model, secPos: widget.secPos, index: index, list: true)),
                );
              },
            ),
          ));
    } else {
      return Container();
    }
  }

  Widget _faqsQue() {
    return _isFaqsLoading
        ? const Center(child: CircularProgressIndicator())
        : faqsProductList.isNotEmpty
            ? Padding(
                padding: EdgeInsetsDirectional.only(start: 10, end: 10, top: 12, bottom: 10),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(getTranslated(context, 'QUE_ANS_LBL')!,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                            /* horizontal: 20,*/
                            vertical: 5),
                        itemCount: faqsProductList.length >= 5 ? 5 : faqsProductList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${getTranslated(context, 'Q_LBL')}: ${faqsProductList[index].question!}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.fontColor, fontSize: 12.5),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "${getTranslated(context, 'A_LBL')}: ${faqsProductList[index].answer!}",
                                    style: TextStyle(color: Theme.of(context).colorScheme.lightBlack, fontSize: 11),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  faqsProductList[index].uname!,
                                  style: TextStyle(color: Theme.of(context).colorScheme.lightBlack2, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 13,
                                      color: Theme.of(context).colorScheme.lightBlack.withOpacity(0.8),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(start: 3.0),
                                      child: Text(
                                        faqsProductList[index].ansBy!,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.lightBlack.withOpacity(0.5),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        }),
                  )
                ]),
              )
            : const SizedBox();
  }

  Widget _review() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            itemCount: reviewList.length >= 2 ? 2 : reviewList.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reviewList[index].username!,
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                      const Spacer(),
                      Text(
                        reviewList[index].date!,
                        style: TextStyle(color: Theme.of(context).colorScheme.lightBlack, fontSize: 11),
                      )
                    ],
                  ),
                  RatingBarIndicator(
                    rating: verfiedDouble(reviewList[index].rating!),
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: colors.primary,
                    ),
                    itemCount: 5,
                    itemSize: 12.0,
                    direction: Axis.horizontal,
                  ),
                  reviewList[index].comment != "" && reviewList[index].comment!.isNotEmpty
                      ? Text(
                          reviewList[index].comment ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Container(),
                  reviewImage(index),
                ],
              );
            });
  }

  Future<void> getProductFaqs() async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var parameter = {
            PRODUCT_ID: widget.model!.product_id,
            LIMIT: perPage.toString(),
            OFFSET: faqsOffset.toString(),
          };
          print("param*****$parameter");
          apiBaseHelper.postAPICall(getProductFaqsApi, parameter).then((getdata) {
            print("getdata***faqs****$getdata");
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              faqsTotal = int.parse(getdata["total"]);

              if ((faqsOffset) < faqsTotal) {
                var data = getdata["data"];
                faqsProductList = (data as List).map((data) => FaqsModel.fromJson(data)).toList();

                faqsOffset = faqsOffset + perPage;
              }
            } else {
              if (msg == "FAQs does not exist") {
                //setSnackbar(msg!, context);
              }
            }
            if (mounted) {
              setState(() {
                _isFaqsLoading = false;
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          if (mounted) {
            setState(() {
              _isFaqsLoading = false;
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
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  /* Future getProductFaqs() async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          if (faqsIsLoadMore) {
            if (mounted) {
              setState(() {
                faqsIsLoadMore = false;
                faqsIsGettingData = true;
                if (faqsOffset == 0) {
                  faqsProductList = [];
                }
              });
            }

            var parameter = {
              PRODUCT_ID: widget.model!.product_id,
              LIMIT: perPage.toString(),
              OFFSET: faqsOffset.toString(),
            };

            if (CUR_MERCHANTID != null) parameter[USER_ID] = CUR_MERCHANTID;

            apiBaseHelper.postAPICall(getProductFaqsApi, parameter).then(
                (getdata) {
              bool error = getdata["error"];

              faqsIsGettingData = false;
              if (faqsOffset == 0) faqsIsNoData = error;

              if (!error) {
                totalFaqs = int.parse(getdata["total"]);
                if (mounted) {
                  Future.delayed(
                      Duration.zero,
                      () => setState(() {
                            List mainlist = getdata['data'];

                            if (mainlist.isNotEmpty) {
                              List<FaqsModel> items = [];
                              List<FaqsModel> allitems = [];

                              items.addAll(mainlist
                                  .map((data) => FaqsModel.fromJson(data))
                                  .toList());

                              allitems.addAll(items);
                              for (FaqsModel item in items) {
                                faqsProductList
                                    .where((i) => i.product_id == item.product_id)
                                    .map((obj) {
                                  allitems.remove(item);
                                  return obj;
                                }).toList();
                              }
                              faqsProductList.addAll(allitems);
                              faqsIsLoadMore = true;

                              faqsOffset = faqsOffset + perPage;
                            } else {
                              faqsIsLoadMore = false;
                            }
                          }));
                }
              } else {
                faqsIsLoadMore = false;
                if (mounted) if (mounted) setState(() {});
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          if (mounted) {
            setState(() {
              faqsIsLoadMore = false;
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
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }*/

  Future getProduct() async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          if (notificationisloadmore) {
            if (mounted) {
              setState(() {
                notificationisloadmore = false;
                notificationisgettingdata = true;
                if (notificationoffset == 0) {
                  productList = [];
                }
              });
            }

            var parameter = {
              // CATID: widget.model!.category_id,
              // LIMIT: perPage.toString(),
              // OFFSET: notificationoffset.toString(),
              ID: widget.model!.product_id,
              // IS_SIMILAR: "1"
            };

            // if (CUR_MERCHANTID != null) parameter[USER_ID] = CUR_MERCHANTID;

            // var tempUri = Uri.parse('${getNumoRelatedByIDApi.toString()}${widget.model!.product_id}');
            // log('tempUri = ${tempUri.toString()}');

            apiBaseHelper.getNumoAPICall(getNumoRelatedByIDApi, parameter, widget.model!.product_id).then((getdata) {
              // bool error = getdata["error"];
              List dataList = [];
              dataList.addAll(getdata['Related']);

              // log('Product_Detail getProduct getdata=$getdata');
              // log('Product_Detail getProduct datalist=$dataList');
              notificationisgettingdata = false;
              if (notificationoffset == 0) notificationisnodata = false;

              if (true) {
                totalProduct = dataList.length;
                // int.parse(getdata["total"]);
                if (mounted) {
                  Future.delayed(
                      Duration.zero,
                      () => setState(() {
                            List mainlist = dataList;

                            if (mainlist.isNotEmpty) {
                              List<Product> items = [];
                              List<Product> allitems = [];

                              items.addAll(mainlist.map((data) => Product.fromJson(data)).toList());

                              allitems.addAll(items);
                              for (Product item in items) {
                                productList.where((i) => i.product_id == item.product_id).map((obj) {
                                  allitems.remove(item);
                                  return obj;
                                }).toList();
                              }
                              productList.addAll(allitems);
                              notificationisloadmore = true;

                              notificationoffset = notificationoffset + perPage;
                            } else {
                              notificationisloadmore = false;
                            }
                          }));
                }
              }
              //  else {
              //   notificationisloadmore = false;
              //   if (mounted) if (mounted) setState(() {});
              // }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });

            // apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
            //   bool error = getdata["error"];
            //   notificationisgettingdata = false;
            //   if (notificationoffset == 0) notificationisnodata = error;
            //   if (!error) {
            //     totalProduct = int.parse(getdata["total"]);
            //     if (mounted) {
            //       Future.delayed(
            //           Duration.zero,
            //           () => setState(() {
            //                 List mainlist = getdata['data'];
            //                 if (mainlist.isNotEmpty) {
            //                   List<Product> items = [];
            //                   List<Product> allitems = [];
            //                   items.addAll(mainlist
            //                       .map((data) => Product.fromJson(data))
            //                       .toList());
            //                   allitems.addAll(items);
            //                   for (Product item in items) {
            //                     productList
            //                         .where(
            //                             (i) => i.product_id == item.product_id)
            //                         .map((obj) {
            //                       allitems.remove(item);
            //                       return obj;
            //                     }).toList();
            //                   }
            //                   productList.addAll(allitems);
            //                   notificationisloadmore = true;
            //                   notificationoffset = notificationoffset + perPage;
            //                 } else {
            //                   notificationisloadmore = false;
            //                 }
            //               }));
            //     }
            //   } else {
            //     notificationisloadmore = false;
            //     if (mounted) if (mounted) setState(() {});
            //   }
            // }, onError: (error) {
            //   setSnackbar(error.toString(), context);
            // });

          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          if (mounted) {
            setState(() {
              notificationisloadmore = false;
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
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> getProduct1() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          // CATID: widget.model!.category_id,
          ID: widget.model!.product_id,
          // IS_SIMILAR: "1"
        };

        // if (CUR_MERCHANTID != null) parameter[USER_ID] = CUR_MERCHANTID;

        // var tempUri = Uri.parse('${getNumoProductsApi.toString()}${widget.model!.product_id}');
        // log('tempUri = ${tempUri.toString()}');

        apiBaseHelper.getNumoAPICall(getNumoProductsApi, parameter, null).then((getdata) {
          // bool error = getdata["error"];

          // log('Product Detail getProduct1 getdata=$getdata');
          List dataList = [];
          dataList.add(getdata);
          if (true) {
            // context
            //     .read<ProductDetailProvider>()
            //     .setProTotal(int.parse(getdata["total"]));
            // context.read<ProductDetailProvider>().setProTotal(150);
            // log('getdata =$getdata');
            List mainlist = dataList[0];

            if (mainlist.isNotEmpty) {
              List<Product> items = [];
              List<Product> allitems = [];
              productList1 = [];

              items.addAll(mainlist.map((data) => Product.fromJson(data)).toList());

              allitems.addAll(items);

              for (Product item in items) {
                productList1.where((i) => i.product_id == item.product_id).map((obj) {
                  allitems.remove(item);
                  return obj;
                }).toList();
              }
              productList1.addAll(allitems);

              context.read<ProductDetailProvider>().setProductList(productList1);

              context.read<ProductDetailProvider>().setProOffset(context.read<ProductDetailProvider>().offset + perPage);
            }
          }
          // else {
          //   if (mounted) {
          //     setState(() {
          //       context.read<ProductDetailProvider>().setProNotiLoading(false);
          //     });
          //   }
          // }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });

        // apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
        //   bool error = getdata["error"];
        //   if (!error) {
        //     context
        //         .read<ProductDetailProvider>()
        //         .setProTotal(int.parse(getdata["total"]));
        //     List mainlist = getdata['data'];
        //     if (mainlist.isNotEmpty) {
        //       List<Product> items = [];
        //       List<Product> allitems = [];
        //       productList1 = [];
        //       items.addAll(
        //           mainlist.map((data) => Product.fromJson(data)).toList());
        //       allitems.addAll(items);
        //       for (Product item in items) {
        //         productList1.where((i) => i.product_id == item.product_id).map((obj) {
        //           allitems.remove(item);
        //           return obj;
        //         }).toList();
        //       }
        //       productList1.addAll(allitems);
        //       context
        //           .read<ProductDetailProvider>()
        //           .setProductList(productList1);
        //       context.read<ProductDetailProvider>().setProOffset(
        //           context.read<ProductDetailProvider>().offset + perPage);
        //     }
        //   } else {
        //     if (mounted) {
        //       setState(() {
        //         context.read<ProductDetailProvider>().setProNotiLoading(false);
        //       });
        //     }
        //   }
        // }, onError: (error) {
        //   setSnackbar(error.toString(), context);
        // });

      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
        if (mounted) {
          setState(() {
            context.read<ProductDetailProvider>().setProNotiLoading(false);
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

  _specification() {
    return widget.model?.product_desc != '' ||
            widget.model!.ProductAttributeValues![widget.model!.selVarient!].Attributes!.isNotEmpty ||
            widget.model!.madein != "" && widget.model!.madein!.isNotEmpty
        ? Card(
            elevation: 0,
            child: InkWell(
              child: Column(children: [
                ListTile(
                  dense: true,
                  title: Text(
                    getTranslated(context, 'SPECIFICATION')!,
                    style: TextStyle(color: Theme.of(context).colorScheme.lightBlack),
                  ),
                  trailing: InkWell(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        !seeView ? Icons.add : Icons.remove,
                        size: 10,
                        color: colors.primary,
                      ),
                      Padding(
                          padding: const EdgeInsetsDirectional.only(start: 2.0),
                          child: Text(!seeView ? getTranslated(context, 'MORE_LBL')! : getTranslated(context, 'LESS_LBL')!,
                              style: Theme.of(context).textTheme.caption!.copyWith(color: colors.primary)))
                    ]),
                    onTap: () {
                      setState(() {
                        seeView = !seeView;
                      });
                    },
                  ),
                ),
                !seeView
                    ? SizedBox(
                        height: 70,
                        width: deviceWidth! - 10,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _desc(),
                            widget.model!.product_desc != ''
                                ? const Divider(
                                    height: 3.0,
                                  )
                                : Container(),
                            _attr(),
                            widget.model!.madein != "" && widget.model!.madein!.isNotEmpty ? const Divider() : Container(),
                            _madeIn(),
                          ]),
                        ))
                    : Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          _desc(),
                          widget.model!.product_desc != null && widget.model!.product_desc!.isNotEmpty
                              ? widget.model!.product_desc!.isNotEmpty
                                  ? const Divider(
                                      height: 3.0,
                                    )
                                  : Container()
                              : Container(),
                          _attr(),
                          widget.model!.madein != "" && widget.model!.madein!.isNotEmpty ? const Divider() : Container(),
                          _madeIn(),
                        ]),
                      )
              ]),
            ),
          )
        : Container();
  }

  _deliverPincode() {
    String pin = context.read<UserProvider>().curPincode;
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: _pincodeCheck,
        child: ListTile(
          dense: true,
          title: Text(
            pin == '' ? getTranslated(context, 'SELOC')! : getTranslated(context, 'DELIVERTO')! + pin,
            style: TextStyle(color: Theme.of(context).colorScheme.lightBlack),
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
      ),
    );
  }

  _speciExtraBtnDetails() {
    //for testing Ansi and should be added to Product Table
    widget.model!.codAllowed = '1';
    widget.model!.isCancelable = '1';
    widget.model!.cancleTill = '6';
    widget.model!.isReturnable = '1';
    widget.model!.warranty = 'مكفول لمدة شهرين';
    widget.model!.gurantee = 'ضمان لمدة سنة';

//-------widget.model!.isCancelable;
    String? cod = widget.model!.codAllowed;
    if (cod == "1") {
      cod = getTranslated(context, 'CashOnDelivery') ?? "";
    } else {
      cod = getTranslated(context, 'NoCashOnDelivery') ?? "";
    }

    String? cancleable = widget.model!.isCancelable;
    if (cancleable == "1") {
      cancleable = getTranslated(context, 'Cancellable_Till')! + widget.model!.cancleTill!;
    } else {
      cancleable = getTranslated(context, "No_Cancellable");
    }

    String? returnable = widget.model!.isReturnable;
    if (returnable == "1") {
      returnable = getTranslated(context, 'Days_Returnable')! + RETURN_DAYS!;
    } else {
      returnable = getTranslated(context, "No_Returnable");
    }

    String? gaurantee = widget.model!.gurantee; //= 'ضمان لمدة سنة'; //;
    String? warranty = widget.model!.warranty; //= 'مكفول لمدة شهرين'; //;

    return Card(
        elevation: 0,
        child: Container(
            height: 100,
            padding: const EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
            width: deviceWidth,
            child: Row(
              children: [
                widget.model!.codAllowed == "1"
                    ? Expanded(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: SvgPicture.asset(
                                  'assets/images/cod.svg',
                                  height: 45.0,
                                  width: 45.0,
                                  fit: BoxFit.cover,
                                  color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
                                )),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: 72,
                            child: Text(
                              cod,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ))
                    : Container(
                        width: 0,
                      ),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 7.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: SvgPicture.asset(
                                  widget.model!.isCancelable == "1" ? "assets/images/cancelable.svg" : "assets/images/notcancelable.svg",
                                  height: 45.0,
                                  width: 45.0,
                                  fit: BoxFit.cover,
                                  color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 72,
                              child: Text(
                                cancleable!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ))),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 7.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: SvgPicture.asset(
                                  widget.model!.isReturnable == "1" ? "assets/images/returnable.svg" : "assets/images/notreturnable.svg",
                                  height: 45.0,
                                  width: 45.0,
                                  fit: BoxFit.cover,
                                  color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 72,
                              child: Text(
                                returnable!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ))),
                gaurantee != "" && gaurantee!.isNotEmpty
                    ? Expanded(
                        child: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 7.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: SvgPicture.asset(
                                      "assets/images/guarantee.svg",
                                      height: 45.0,
                                      width: 45.0,
                                      fit: BoxFit.cover,
                                      color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: 72,
                                  child: Text(
                                    "$gaurantee ${getTranslated(context, 'GUARANTY_LBL')}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold, fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            )))
                    : Container(
                        width: 0,
                      ),
                warranty != "" && warranty!.isNotEmpty
                    ? Expanded(
                        child: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 7.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: SvgPicture.asset(
                                      "assets/images/warranty.svg",
                                      height: 45.0,
                                      width: 45.0,
                                      fit: BoxFit.cover,
                                      color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: 72,
                                  child: Text(
                                    "$warranty ${getTranslated(context, 'WARRENTY')}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold, fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            )))
                    : Container(
                        width: 0,
                      )
              ],
            )));
  }

  _reviewTitle() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Row(
          children: [
            Text(
              getTranslated(context, 'CUSTOMER_REVIEW_LBL')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.lightBlack, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  getTranslated(context, 'VIEW_ALL')!,
                  style: const TextStyle(color: colors.primary),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ReviewList(widget.model!.product_id, widget.model)),
                );
              },
            )
          ],
        ));
  }

  reviewImage(int i) {
    return SizedBox(
      height: reviewList[i].imgList!.isNotEmpty ? 50 : 0,
      child: ListView.builder(
        itemCount: reviewList[i].imgList!.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 10, bottom: 5.0, top: 5),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ProductPreview(
                        pos: index,
                        secPos: widget.secPos,
                        index: widget.index,
                        id: '$index${reviewList[i].id}',
                        imgList: reviewList[i].imgList,
                        list: true,
                        from: false,
                        // screenSize: MediaQuery.of(context).size,
                      ),
                    ));
              },
              child: Hero(
                tag: "$index${reviewList[i].id}",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: FadeInImage(
                    image: NetworkImage(reviewList[i].imgList![index]),
                    height: 50.0,
                    width: 50.0,
                    placeholder: placeHolder(50),
                    imageErrorBuilder: (context, error, stackTrace) => erroWidget(50),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _shortDesc() {
    // log('Product_Details _shortDesc widget.model!.product_desc=${widget.model!.product_desc}');
    // log('Product_Details _shortDesc widget.model!.product_fullDesc=${widget.model!.product_fullDesc}');
    return widget.model!.product_desc == "" || widget.model!.product_desc == 'null' || widget.model!.product_desc == null
        ? Container()
        : Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 8, top: 8, bottom: 5),
            child: Text(
              // widget.model!.product_desc,
              widget.model?.product_desc ?? '',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          );
  }

  _attr() {
    return widget.model!.ProductAttributeValues != null && widget.model!.ProductAttributeValues!.isNotEmpty
        ? widget.model!.ProductAttributeValues![widget.model!.selVarient!].Attributes!.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.model!.ProductAttributeValues![widget.model!.selVarient!].Attributes!.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                        start: 25.0, top: 10.0, bottom: widget.model!.madein != "" && widget.model!.madein!.isNotEmpty ? 0.0 : 7.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            widget.model!.ProductAttributeValues![widget.model!.selVarient!].Attributes![i].attribute_name!,
                            style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7)),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Padding(
                                padding: const EdgeInsetsDirectional.only(start: 5.0),
                                child: Text(
                                  widget.model!.ProductAttributeValues![widget.model!.selVarient!].AttributeValues![i].attributeValue_name!,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor),
                                ))),
                      ],
                    ),
                  );
                },
              )
            : Container()
        : Container();
  }

  Future<void> getShare() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: deepLinkUrlPrefix,
      link: Uri.parse('https://$deepLinkName/?index=${widget.index}&secPos=${widget.secPos}&list=${widget.list}&id=${widget.model!.product_id}'),
      androidParameters: const AndroidParameters(
        packageName: packageName,
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: iosPackage,
        minimumVersion: '1',
        appStoreId: appStoreId,
      ),
    );

    shortenedLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);

    Future.delayed(Duration.zero, () {
      shareLink = "\n$appName\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n${getTranslated(context, 'IOSLBL')}\n$iosLink";
    });
  }

  playIcon() {
    return Align(
        alignment: Alignment.center,
        child: (widget.model!.videType != "" && widget.model!.video!.isNotEmpty && widget.model!.video != "")
            ? const Icon(
                Icons.play_circle_fill_outlined,
                color: colors.primary,
                size: 35,
              )
            : Container());
  }

  _reviewImg() {
    return revImgList.isNotEmpty
        ? SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: revImgList.length > 5 ? 5 : revImgList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: InkWell(
                    onTap: () async {
                      if (index == 4) {
                        Navigator.push(context, CupertinoPageRoute(builder: (context) => ReviewGallary(productModel: widget.model)));
                      } else {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => ReviewPreview(
                                      index: index,
                                      productModel: widget.model,
                                    )));
                      }
                    },
                    child: Stack(
                      children: [
                        FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: NetworkImage(
                            revImgList[index].img!,
                          ),
                          height: 100.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                          placeholder: placeHolder(80),
                          imageErrorBuilder: (context, error, stackTrace) => erroWidget(80),
                        ),
                        index == 4
                            ? Container(
                                height: 100.0,
                                width: 80.0,
                                color: colors.black54,
                                child: Center(
                                    child: Text(
                                  "+${revImgList.length - 5}",
                                  style: TextStyle(color: Theme.of(context).colorScheme.white, fontWeight: FontWeight.bold),
                                )),
                              )
                            : Container()
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : Container();
  }

  Future<void> validatePin(String pin, bool first) async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var parameter = {
            ZIPCODE: pin,
            PRODUCT_ID: widget.model!.product_id,
          };
          apiBaseHelper.postAPICall(checkDeliverableApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];

            if (error) {
              curPin = '';
            } else {
              if (pin != context.read<UserProvider>().curPincode) {
                context.read<HomeProvider>().setSecLoading(true);
                getSection();
              }
              context.read<UserProvider>().setPincode(pin);
            }
            if (!first) {
              Navigator.pop(context);
              setSnackbar(msg!, context);
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
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  void getSection() {
    try {
      Map parameter = {PRODUCT_LIMIT: "6", PRODUCT_OFFSET: "0"};

      if (CUR_MERCHANTID != null) parameter[USER_ID] = CUR_MERCHANTID!;
      String curPin = context.read<UserProvider>().curPincode;
      if (curPin != '') parameter[ZIPCODE] = curPin;

      apiBaseHelper.postAPICall(getSectionApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        sectionList.clear();
        if (!error) {
          var data = getdata["data"];

          sectionList = (data as List).map((data) => SectionModel.fromJson(data)).toList();
        } else {
          if (curPin != '') context.read<UserProvider>().setPincode('');
          setSnackbar(
            msg!,
            context,
          );
        }

        context.read<HomeProvider>().setSecLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSecLoading(false);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> getDeliverable() async {
    String pin = context.read<UserProvider>().curPincode;
    if (pin != '') {
      validatePin(pin, true);
    }
  }

  _reviewStar() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                widget.model!.rating ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              Text("${reviewList.length}  ${getTranslated(context, "RATINGS")!}")
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                getRatingBarIndicator(5.0, 5),
                getRatingBarIndicator(4.0, 4),
                getRatingBarIndicator(3.0, 3),
                getRatingBarIndicator(2.0, 2),
                getRatingBarIndicator(1.0, 1),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getRatingIndicator(int.parse(star5)),
                getRatingIndicator(int.parse(star4)),
                getRatingIndicator(int.parse(star3)),
                getRatingIndicator(int.parse(star2)),
                getRatingIndicator(int.parse(star1)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTotalStarRating(star5),
              getTotalStarRating(star4),
              getTotalStarRating(star3),
              getTotalStarRating(star2),
              getTotalStarRating(star1),
            ],
          ),
        ),
      ],
    );
  }

  getRatingIndicator(var totalStar) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: [
          Container(
            height: 10,
            width: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(
                  width: 0.5,
                  color: colors.primary,
                )),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: colors.primary,
            ),
            width: (totalStar / reviewList.length) * MediaQuery.of(context).size.width / 3,
            height: 10,
          ),
        ],
      ),
    );
  }

  getRatingBarIndicator(var ratingStar, var totalStars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RatingBarIndicator(
        textDirection: TextDirection.rtl,
        rating: ratingStar,
        itemBuilder: (context, index) => const Icon(
          Icons.star_rate_rounded,
          color: colors.yellow,
        ),
        itemCount: totalStars,
        itemSize: 20.0,
        direction: Axis.horizontal,
        unratedColor: Colors.transparent,
      ),
    );
  }

  getTotalStarRating(var totalStar) {
    return SizedBox(
        width: 20,
        height: 20,
        child: Text(
          totalStar,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ));
  }
}

class AnimatedProgressBar extends AnimatedWidget {
  final Animation<double> animation;

  const AnimatedProgressBar({Key? key, required this.animation}) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.0,
      width: animation.value,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.black),
    );
  }
}
