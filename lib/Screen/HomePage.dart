import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:numo/Helper/ApiBaseHelper.dart';
import 'package:numo/Helper/AppBtn.dart';
import 'package:numo/Helper/CapExtension.dart';
import 'package:numo/Helper/Color.dart';
import 'package:numo/Helper/Constant.dart';
import 'package:numo/Helper/Session.dart';
import 'package:numo/Helper/SimBtn.dart';
import 'package:numo/Helper/SqliteData.dart';
import 'package:numo/Helper/String.dart';
import 'package:numo/Model/Model.dart';
import 'package:numo/Model/Section_Model.dart';
import 'package:numo/Provider/CartProvider.dart';
import 'package:numo/Provider/CategoryProvider.dart';
import 'package:numo/Provider/FavoriteProvider.dart';
import 'package:numo/Provider/HomeProvider.dart';
import 'package:numo/Provider/SettingProvider.dart';
import 'package:numo/Provider/UserProvider.dart';
import 'package:numo/Screen/Search.dart';

import 'package:numo/Screen/SubCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:version/version.dart';

import 'Login.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';
import 'SectionList.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List<SectionModel> sectionList = [];
List<Product> catList = [];
List<Product> popularList = [];
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
List<String> tagList = [];
List<Product> sellerList = [];
List<Model> homeSliderList = [];
List<Widget> pages = [];
int count = 1;

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  final _controller = PageController();
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Model> offerImages = [];
  final ScrollController _scrollBottomBarController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  double beginAnim = 0.0;

  double endAnim = 1.0;
  var db = DatabaseHelper();

  //String? curPin;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    log('HomePage initState 1');
    setUserData();
    log('HomePage initState 2');

    callApi();
    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    log('HomePage initState 3');

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
    log('HomePage initState 4');

    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
    log('HomePage initState 5');
  }

  setUserData() {
    try {
      log('HomePage setUserData start');

      SettingProvider setting = Provider.of<SettingProvider>(context, listen: false);
      UserProvider user = Provider.of<UserProvider>(context, listen: false);
      user.setMerchantUserName(setting.merchantUser_name!);
      log('HomePage setUserData setting.merchantUser_name=${setting.merchantUser_name}');
      user.setMerchantUserPhone1(setting.merchantUser_phone1!);
      log('HomePage setUserData setting.merchantUser_phone1=${setting.merchantUser_phone1}');
      user.setMerchantComName(setting.merchant_comName!);
      log('HomePage setUserData setting.merchant_comName=${setting.merchant_comName}');
      user.setMerchantUserImage(setting.merchantUser_image);
      user.setMerchantEmail(setting.merchant_email ?? '');

      setState(() {});
      log('HomePage setUserData end');
    } catch (e) {
      log('HomePage setUserData error =$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('HomePage - build');
    hideAppbarAndBottomBarOnScroll(_scrollBottomBarController, context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        body: _isNetworkAvail
            ? RefreshIndicator(
                color: colors.primary,
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  controller: _scrollBottomBarController,
                  child: Column(
                    children: [
                      _deliverPincode(),
                      _getSearchBar(),
                      _slider(),
                      _getCatHeading(getTranslated(context, 'CAT_LIST')!),
                      _catList(),

                      // _section(),
                    ],
                  ),
                ))
            : noInternet(context));
  }

  Future<void> _refresh() {
    log('HomePage - _refresh');
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setSecLoading(true);
    context.read<HomeProvider>().setSliderLoading(true);
    cartTotalClear();
    return callApi();
  }

  Widget _slider() {
    // log('HomePage - _slider');
    double height = deviceWidth! / 2.2;

    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        // log('HomePage _slider builder');
        return data
            ? sliderLoading()
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: height,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: PageView.builder(
                          itemCount: homeSliderList.length,
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          physics: const AlwaysScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() {
                              context.read<HomeProvider>().setCurSlider(index);
                            });
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return pages[index];
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    height: 40,
                    left: 0,
                    width: deviceWidth,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: map<Widget>(
                        homeSliderList,
                        (index, url) {
                          return AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: context.read<HomeProvider>().curSlider == index ? 25 : 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: context.read<HomeProvider>().curSlider == index
                                    ? Theme.of(context).colorScheme.fontColor
                                    : Theme.of(context).colorScheme.lightBlack.withOpacity(0.7),
                              ));
                        },
                      ),
                    ),
                  ),
                ],
              );
      },
      selector: (_, homeProvider) => homeProvider.sliderLoading,
    );
  }

  void _animateSlider() {
    // log('HomePage - _animateSlider');
    Future.delayed(const Duration(seconds: 10)).then((_) {
      if (mounted) {
        int nextPage = _controller.hasClients ? _controller.page!.round() + 1 : _controller.initialPage;

        if (nextPage == homeSliderList.length) {
          nextPage = 0;
        }
        if (_controller.hasClients) {
          _controller.animateToPage(nextPage, duration: const Duration(milliseconds: 200), curve: Curves.linear).then((_) {
            _animateSlider();
          });
        }
      }
    });
  }

  _singleSection(int index) {
    // log('HomePage - _singleSection');
    Color back;
    int pos = index % 5;
    if (pos == 0) {
      back = Theme.of(context).colorScheme.back1;
    } else if (pos == 1) {
      back = Theme.of(context).colorScheme.back2;
    } else if (pos == 2) {
      back = Theme.of(context).colorScheme.back3;
    } else if (pos == 3) {
      back = Theme.of(context).colorScheme.back4;
    } else {
      back = Theme.of(context).colorScheme.back5;
    }

    return sectionList[index].productList!.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          decoration: BoxDecoration(
                              color: back, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)))),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _getHeading(sectionList[index].title ?? "", index),
                        _getSection(index),
                      ],
                    ),
                  ],
                ),
              ),
              offerImages.length > index ? _getOfferImage(index) : Container(),
            ],
          )
        : Container();
  }

  _getHeading(String title, int index) {
    // log('HomePage - _getHeading');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  color: colors.yellow,
                ),
                padding: const EdgeInsetsDirectional.only(start: 12, bottom: 3, top: 3, end: 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(color: colors.blackTemp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsetsDirectional.only(start: 12.0, end: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(sectionList[index].shortDesc ?? "",
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor)),
                ),
                TextButton(
                    style: TextButton.styleFrom(
                        minimumSize: Size.zero, //
                        backgroundColor: (Theme.of(context).colorScheme.white),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                    child: Text(
                      getTranslated(context, 'SHOP_NOW')!,
                      style:
                          Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      SectionModel model = sectionList[index];
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => SectionList(
                              index: index,
                              section_model: model,
                            ),
                          ));
                    }),
              ],
            )),
      ],
    );
  }

  _getCatHeading(String title) {
    // log('HomePage - _getHeading');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomRight,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  color: colors.yellow,
                ),
                padding: const EdgeInsetsDirectional.only(start: 12, bottom: 5, top: 2, end: 15),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(color: colors.blackTemp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(),
            ],
          ),
        ),
        // Padding(
        //     padding: const EdgeInsetsDirectional.only(start: 12.0, end: 15.0),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Expanded(
        //           child: Text("$title", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor)),
        //         ),
        //         // TextButton(
        //         //     style: TextButton.styleFrom(
        //         //         minimumSize: Size.zero, //
        //         //         backgroundColor: (Theme.of(context).colorScheme.white),
        //         //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
        //         //     child: Text(
        //         //       getTranslated(context, 'SHOP_NOW')!,
        //         //       style:
        //         //           Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
        //         //     ),
        //         //     onPressed: () {
        //         //       log('title 333');
        //         //     }
        //         //     // () {
        //         //     //   SectionModel model = sectionList[index];
        //         //     //   Navigator.push(
        //         //     //       context,
        //         //     //       CupertinoPageRoute(
        //         //     //         builder: (context) => SectionList(
        //         //     //           index: index,
        //         //     //           section_model: model,
        //         //     //         ),
        //         //     //       ));
        //         //     // }
        //         //     ),
        //       ],
        //     )),
      ],
    );
  }

  _getOfferImage(index) {
    log('HomePage - _getOfferImage');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        child: FadeInImage(
            fadeInDuration: const Duration(milliseconds: 150),
            image: NetworkImage(offerImages[index].image!),
            width: double.maxFinite,
            imageErrorBuilder: (context, error, stackTrace) => erroWidget(50),

            // errorWidget: (context, url, e) => placeHolder(50),
            placeholder: const AssetImage(
              "assets/images/sliderph.png",
            )),
        onTap: () {
          if (offerImages[index].type == "products") {
            Product? item = offerImages[index].list;

            Navigator.push(
              context,
              PageRouteBuilder(
                  //transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) => ProductDetail(model: item, secPos: 0, index: 0, list: true
                      //  title: sectionList[secPos].title,
                      )),
            );
          } else if (offerImages[index].type == "categories") {
            Product item = offerImages[index].list;
            if (item.Childern == "" || item.Childern!.isEmpty) {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ProductList(
                      category_name: item.category_name,
                      category_id: item.category_id,
                      tag: false,
                      fromSeller: false,
                    ),
                  ));
            } else {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SubCategory(
                      title: item.product_name!,
                      subList: item.Childern,
                    ),
                  ));
            }
          }
        },
      ),
    );
  }

  _getSection(int i) {
    // log('HomePage - _getSection');
    var orient = MediaQuery.of(context).orientation;

    return sectionList[i].style == DEFAULT
        ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: GridView.count(
                padding: const EdgeInsetsDirectional.only(top: 5),
                crossAxisCount: 2,
                shrinkWrap: true,
                //childAspectRatio: 0.8,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  sectionList[i].productList!.length < 4 ? sectionList[i].productList!.length : 4,
                  (index) {
                    return productItem(i, index, index % 2 == 0 ? true : false);
                  },
                )),
          )
        : sectionList[i].style == STYLE1
            ? sectionList[i].productList!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: SizedBox(
                                height: orient == Orientation.portrait ? deviceHeight! * 0.4 : deviceHeight, child: productItem(i, 0, true))),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  height: orient == Orientation.portrait ? deviceHeight! * 0.2 : deviceHeight! * 0.5,
                                  child: productItem(i, 1, false)),
                              SizedBox(
                                  height: orient == Orientation.portrait ? deviceHeight! * 0.2 : deviceHeight! * 0.5,
                                  child: productItem(i, 2, false)),
                            ],
                          ),
                        ),
                      ],
                    ))
                : Container()
            : sectionList[i].style == STYLE2
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  height: orient == Orientation.portrait ? deviceHeight! * 0.2 : deviceHeight! * 0.5, child: productItem(i, 0, true)),
                              SizedBox(
                                  height: orient == Orientation.portrait ? deviceHeight! * 0.2 : deviceHeight! * 0.5, child: productItem(i, 1, true)),
                            ],
                          ),
                        ),
                        Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: SizedBox(
                                height: orient == Orientation.portrait ? deviceHeight! * 0.4 : deviceHeight, child: productItem(i, 2, false))),
                      ],
                    ))
                : sectionList[i].style == STYLE3
                    ? Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                                flex: 1,
                                fit: FlexFit.loose,
                                child: SizedBox(
                                    height: orient == Orientation.portrait ? deviceHeight! * 0.3 : deviceHeight! * 0.6,
                                    child: productItem(i, 0, false))),
                            SizedBox(
                              height: orient == Orientation.portrait ? deviceHeight! * 0.2 : deviceHeight! * 0.5,
                              child: Row(
                                children: [
                                  Flexible(flex: 1, fit: FlexFit.loose, child: productItem(i, 1, true)),
                                  Flexible(flex: 1, fit: FlexFit.loose, child: productItem(i, 2, true)),
                                  Flexible(flex: 1, fit: FlexFit.loose, child: productItem(i, 3, false)),
                                ],
                              ),
                            ),
                          ],
                        ))
                    : sectionList[i].style == STYLE4
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: SizedBox(
                                        height: orient == Orientation.portrait ? deviceHeight! * 0.25 : deviceHeight! * 0.5,
                                        child: productItem(i, 0, false))),
                                SizedBox(
                                  height: orient == Orientation.portrait ? deviceHeight! * 0.2 : deviceHeight! * 0.5,
                                  child: Row(
                                    children: [
                                      Flexible(flex: 1, fit: FlexFit.loose, child: productItem(i, 1, true)),
                                      Flexible(flex: 1, fit: FlexFit.loose, child: productItem(i, 2, false)),
                                    ],
                                  ),
                                ),
                              ],
                            ))
                        : Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: GridView.count(
                                padding: const EdgeInsetsDirectional.only(top: 5),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.2,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 0,
                                children: List.generate(
                                  sectionList[i].productList!.length < 6 ? sectionList[i].productList!.length : 6,
                                  (index) {
                                    return productItem(i, index, index % 2 == 0 ? true : false);
                                  },
                                )));
  }

  Widget productItem(int secPos, int index, bool pad) {
    // log('HomePage - productItem');
    if (sectionList[secPos].productList!.length > index) {
      String? offPer;
      double price = double.parse(sectionList[secPos].productList![index].ProductAttributeValues![0].old_price!);
      if (price == 0) {
        price = double.parse(sectionList[secPos].productList![index].ProductAttributeValues![0].price1!);
      } else {
        double off = double.parse(sectionList[secPos].productList![index].ProductAttributeValues![0].price1!) - price;
        offPer = ((off * 100) / double.parse(sectionList[secPos].productList![index].ProductAttributeValues![0].price1!)).toStringAsFixed(0);
      }

      double width = deviceWidth! * 0.5;

      return Card(
        elevation: 0.0,

        margin: const EdgeInsetsDirectional.only(bottom: 2, end: 2),
        //end: pad ? 5 : 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag: "$index${sectionList[secPos].productList![index].product_id}",
                          child: FadeInImage(
                            fadeInDuration: const Duration(milliseconds: 150),
                            image: NetworkImage(sectionList[secPos].productList![index].product_image!),
                            height: double.maxFinite,
                            width: double.maxFinite,
                            fit: extendImg ? BoxFit.fill : BoxFit.fitHeight,
                            imageErrorBuilder: (context, error, stackTrace) => erroWidget(double.maxFinite),
                            //fit: BoxFit.fill,
                            placeholder: placeHolder(width),
                          ),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 10.0,
                  top: 5,
                ),
                child: Text(
                  sectionList[secPos].productList![index].product_name!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10.0, top: 2),
                  child: Text('${getPriceFormat(context, price)!} ',
                      style: TextStyle(fontSize: 11.0, color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold))),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 10.0, bottom: 8, top: 2),
                child: double.parse(sectionList[secPos].productList![index].ProductAttributeValues![0].old_price!) != 0
                    ? Row(
                        children: <Widget>[
                          Text(
                            double.parse(sectionList[secPos].productList![index].ProductAttributeValues![0].old_price!) != 0
                                ? getPriceFormat(
                                    context, double.parse(sectionList[secPos].productList![index].ProductAttributeValues![0].old_price!))!
                                : "",
                            style: Theme.of(context).textTheme.overline!.copyWith(
                                decoration: TextDecoration.lineThrough,
                                letterSpacing: 0,
                                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.6)),
                          ),
                          Flexible(
                            child: Text(" | " "-$offPer%",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.overline!.copyWith(color: colors.primary, letterSpacing: 0)),
                          ),
                        ],
                      )
                    : Container(
                        height: 5,
                      ),
              )
            ],
          ),
          onTap: () {
            Product model = sectionList[secPos].productList![index];
            Navigator.push(
              context,
              PageRouteBuilder(
                  // transitionDuration: Duration(milliseconds: 150),
                  pageBuilder: (_, __, ___) => ProductDetail(
                        model: model, secPos: secPos, index: index, list: false,

                        //  title: sectionList[secPos].title,
                      )),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  _section() {
    log('HomePage - _section');
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: sectionLoading()))
            : ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: sectionList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _singleSection(index);
                },
              );
      },
      selector: (_, homeProvider) => homeProvider.secLoading,
    );
  }

  _catList() {
    // log('HomePage - _catList');
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        // log('HomePage _catList builder');
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : Container(
                // height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child:

                    //********************New GridView */
                    GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 5 / 4, crossAxisSpacing: 0, mainAxisSpacing: 0),
                  // const SliverGridDelegateWithMaxCrossAxisExtent(
                  //     maxCrossAxisExtent: 200, childAspectRatio: 3 / 2, crossAxisSpacing: 0, mainAxisSpacing: 20),
                  itemCount: catList.length, //< 10 ? catList.length : 10,
                  // scrollDirection: Axis.vertical,

                  shrinkWrap: true, //true
                  physics: const ScrollPhysics(),
                  itemBuilder: (context, index) {
                    // if (index == 0) {
                    //   return Container();
                    // } else {
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 1),
                      child: InkWell(
                        onTap: () async {
                          log('HomePage _catList catList[index] =${catList[index].categoryId}');

                          // if (catList[index].Childern == null ||
                          //     catList[index].Childern!.isEmpty) {
                          if (catList[index].category_id != null) {
                            await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ProductList(
                                    //*Product List
                                    category_name: catList[index].category_name,
                                    category_id: catList[index].category_id,
                                    tag: false,
                                    fromSeller: false,
                                  ),
                                ));
                          } else {
                            await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => SubCategory(
                                    //*SubCategory
                                    title: catList[index].category_name!,
                                    subList: catList[index].Childern,
                                  ),
                                ));
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          // crossAxisAlignment: ,
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsetsDirectional.only(bottom: 5.0, top: 8.0),
                                child: Container(
                                    // padding: const EdgeInsetsDirectional.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.fontColor.withOpacity(0.48),
                                          spreadRadius: 2,
                                          blurRadius: 13,
                                          offset: const Offset(5, 5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 45.0,
                                      backgroundColor: Theme.of(context).colorScheme.white,
                                      child: FadeInImage(
                                        fadeInDuration: const Duration(milliseconds: 150),
                                        image: NetworkImage(
                                          catList[index].category_image!,
                                        ),
                                        fit: BoxFit.scaleDown,
                                        imageErrorBuilder: (context, error, stackTrace) => erroWidget(80),
                                        placeholder: placeHolder(120),
                                      ),
                                    ))),
                            SizedBox(
                              // width: 80,
                              child: Text(
                                catList[index].category_name!.toLowerCase().capitalize(),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.w600, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    // }
                  },
                ),

                //********************old listView */
                //  ListView.builder(
                //   itemCount: catList.length, //< 10 ? catList.length : 10,
                //   scrollDirection: Axis.horizontal,
                //   shrinkWrap: false,  //true
                //   physics: const AlwaysScrollableScrollPhysics(),
                //   itemBuilder: (context, index) {
                //     // if (index == 0) {
                //     //   return Container();
                //     // } else {
                //     return Padding(
                //       padding: const EdgeInsetsDirectional.only(end: 17),
                //       child: InkWell(
                //         onTap: () async {
                //           log('catList[index] =${catList[index].categoryId}');
                //           // if (catList[index].Childern == null ||
                //           //     catList[index].Childern!.isEmpty) {
                //           if (catList[index].category_id != null) {
                //             await Navigator.push(
                //                 context,
                //                 CupertinoPageRoute(
                //                   builder: (context) => ProductList(
                //                     //*Product List
                //                     category_name: catList[index].category_name,
                //                     category_id: catList[index].category_id,
                //                     tag: false,
                //                     fromSeller: false,
                //                   ),
                //                 ));
                //           } else {
                //             await Navigator.push(
                //                 context,
                //                 CupertinoPageRoute(
                //                   builder: (context) => SubCategory(
                //                     //*SubCategory
                //                     title: catList[index].category_name!,
                //                     subList: catList[index].Childern,
                //                   ),
                //                 ));
                //           }
                //         },
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           mainAxisSize: MainAxisSize.min,
                //           children: <Widget>[
                //             Padding(
                //                 padding: const EdgeInsetsDirectional.only(bottom: 5.0, top: 8.0),
                //                 child: Container(
                //                     decoration: BoxDecoration(
                //                       color: Theme.of(context).cardColor,
                //                       shape: BoxShape.circle,
                //                       boxShadow: [
                //                         BoxShadow(
                //                           color: Theme.of(context).colorScheme.fontColor.withOpacity(0.048),
                //                           spreadRadius: 2,
                //                           blurRadius: 13,
                //                           offset: const Offset(0, 0), // changes position of shadow
                //                         ),
                //                       ],
                //                     ),
                //                     child: CircleAvatar(
                //                       radius: 52.0, //32.0
                //                       backgroundColor: Theme.of(context).colorScheme.white,
                //                       child: FadeInImage(
                //                         fadeInDuration: const Duration(milliseconds: 150),
                //                         image: NetworkImage(
                //                           catList[index].category_image!,
                //                         ),
                //                         fit: BoxFit.fill,
                //                         imageErrorBuilder: (context, error, stackTrace) => erroWidget(80),
                //                         placeholder: placeHolder(120),
                //                       ),
                //                     ))),
                //             SizedBox(
                //               width: 80,
                //               child: Text(
                //                 catList[index].category_name!.toLowerCase().capitalize(),
                //                 style: Theme.of(context)
                //                     .textTheme
                //                     .caption!
                //                     .copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.w600, fontSize: 12),
                //                 overflow: TextOverflow.ellipsis,
                //                 textAlign: TextAlign.center,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //     // }
                //   },
                // ),
              );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }

  List<T> map<T>(List list, Function handler) {
    // log('HomePage - map');

    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  //for settings
  Future<void> callApi() async {
    log('HomePage - callApi');
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting = Provider.of<SettingProvider>(context, listen: false);

    user.setMerchantUserId(setting.merchantUser_id);
    user.setMerchantId(setting.merchant_id);

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getSetting();
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }

    return;
  }

  Future _getFav() async {
    try {
      log('HomePage - _getFav');
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (CUR_MERCHANTUSERID != null) {
          //!---Should be changed------
          Map<String, String> parameter = {
            MERCHANT_ID: CUR_MERCHANTID!,
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
        } else {
          context.read<FavoriteProvider>().setLoading(false);
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

  void getOfferImages() {
    try {
      log('HomePage - getOfferImages');
      Map parameter = {};

      // apiBaseHelper.postAPICall(getOfferImageApi, parameter).then((getdata) {
      //   bool error = getdata["error"];
      //   String? msg = getdata["message"];
      //   if (!error) {
      //     var data = getdata["data"];
      //     offerImages.clear();
      //     offerImages =
      //         (data as List).map((data) => Model.fromSlider(data)).toList();
      //   } else {
      //     setSnackbar(msg!, context);
      //   }

      //   context.read<HomeProvider>().setOfferLoading(false);
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      //   context.read<HomeProvider>().setOfferLoading(false);
      // });

    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  void getSection() {
    try {
      log('HomePage - getSection');
      Map<String, dynamic> parameter = {}; //= {PRODUCT_LIMIT: "6", PRODUCT_OFFSET: "0"};

      if (CUR_MERCHANTID != null && CUR_MERCHANTID != '') {
        parameter[MERCHANT_ID] = CUR_MERCHANTID!;
      }
      String curPin = context.read<UserProvider>().curPincode;
      if (curPin != '') parameter[ZIPCODE] = curPin;

      apiBaseHelper.getNumoAPICall(getNumoSectionApi, parameter, null).then((getdata) {
        // bool error = getdata["error"];
        // String? msg = getdata["message"];
        sectionList.clear();
        // if (!error) {
        var data = getdata;
        log('HomePage - getSection data =$data');

        //!--Should be uncommented
        // sectionList = data != null ? (data as List).map((data) => SectionModel.fromJson(data)).toList() : [];

        // } else {
        //   if (curPin != '') context.read<UserProvider>().setPincode('');
        //   setSnackbar(msg!, context);
        // }

        context.read<HomeProvider>().setSecLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSecLoading(false);
      });

      // apiBaseHelper.postAPICall(getSectionApi, parameter).then((getdata) {
      //   bool error = getdata["error"];
      //   String? msg = getdata["message"];
      //   sectionList.clear();
      //   if (!error) {
      //     var data = getdata["data"];
      //     // log('data =$data');
      //     sectionList = (data as List)
      //         .map((data) => SectionModel.fromJson(data))
      //         .toList();
      //   } else {
      //     if (curPin != '') context.read<UserProvider>().setPincode('');
      //     setSnackbar(msg!, context);
      //   }
      //   context.read<HomeProvider>().setSecLoading(false);
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      //   context.read<HomeProvider>().setSecLoading(false);
      // });

    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  void getSetting() {
    try {
      // log('HomePage - getSection');
      CUR_MERCHANTID = context.read<SettingProvider>().merchant_id;
      CUR_MERCHANTUSERID = context.read<SettingProvider>().merchantUser_id;
      CUR_TOKEN = context.read<SettingProvider>().accessToken;
      CUR_PINCODE = context.read<SettingProvider>().merchantUser_pincode;
      log('HomePage - getSection CUR_MERCHANTID=$CUR_MERCHANTID CUR_MERCHANTUSERID=$CUR_MERCHANTUSERID CUR_TOKEN=$CUR_TOKEN CUR_PINCODE=$CUR_PINCODE ');

      log(CUR_MERCHANTID.toString());
      Map<String, dynamic> parameter = {};
      if (CUR_MERCHANTID != null) parameter = {MERCHANT_ID: CUR_MERCHANTID};
      if (CUR_MERCHANTUSERID != null) parameter = {MERCHANTUSER_ID: CUR_MERCHANTUSERID};
      // var getData;
      try {
        apiBaseHelper.getNumoAPICall(getNumoSettingApi, parameter, null).then((getdata) async {
          var data = getdata != null ? getdata[0] : [];
          // debugPrint('***********store settings**************');
          // log(data.toString());

          // ============================Global Settings =====================

          if (data[IS_ON_MAINTENANCE] != null) {
            Is_APP_IN_MAINTANCE = data[MAINTAINANCE_MODE];
          }
          if (Is_APP_IN_MAINTANCE != "1") {
            getSlider();
            getCat();
            getSection();
            getOfferImages();
          }

          if (data.toString().contains(MAINTAINANCE_MESSAGE)) {
            IS_APP_MAINTENANCE_MESSAGE = data[MAINTAINANCE_MESSAGE];
          }

          SUPPORTED_LOCALES = data[CURRENCY][CURRENCY_CODE].toString(); //"supported_locals": "INR"

          log('SUPPORTED_LOCALES = $SUPPORTED_LOCALES!');
          cartBtnList = true; //data["cart_btn_on_list"] == "1" ? true : false;
          refer = false; //data["is_refer_earn_on"] == "1" ? true : false;
          CUR_CURRENCY = data[CURRENCY][CURRENCY_CODE].toString();
          RETURN_DAYS = data[PRODUCTSETTING][MAXRETURNDAYS].toString();
          MAX_ITEMS = data[PRODUCTSETTING][MAX_ITEMS_CART].toString();
          MIN_AMT = data[PRODUCTSETTING][MINORDERAMOUNT].toString();
          MAX_AMT = data[PRODUCTSETTING][MAXORDERAMOUNT].toString();
          CUR_DEL_CHR = ''; //data['delivery_charge'];
          extendImg = false; // data["expand_product_images"] == "1" ? true : false;
          MIN_ALLOW_CART_AMT = data[PRODUCTSETTING][MINORDERAMOUNT].toString();
          IS_LOCAL_PICKUP = ''; //data[LOCAL_PICKUP];
          ADMIN_ADDRESS = ''; //data[ADDRESS];
          ADMIN_LAT = ''; // data[LATITUDE];
          ADMIN_LONG = ''; //data[LONGITUDE];
          ADMIN_MOB = '777777777'; // data[SUPPORT_NUM];

          if (Is_APP_IN_MAINTANCE == "1") {
            appMaintenanceDialog(context);
          }

          if (CUR_MERCHANTID != null) {
            // REFER_CODE = getdata['data']['user_data'][0]['referral_code'];

            context.read<UserProvider>().setCartCount('0');

            if (CUR_PINCODE != null) {
              context.read<UserProvider>().setPincode(CUR_PINCODE!);
            }
            if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE!.isEmpty) {
              generateReferral();
            }

            context.read<UserProvider>().setBalance('2650'
                // data["data"]["user_data"][0]["balance"]
                );
            if (Is_APP_IN_MAINTANCE != "1") {
              _getFav();
              _getCart("0");
            }
          } else {
            if (Is_APP_IN_MAINTANCE != "1") {
              _getOffFav();
              _getOffCart();
            }
          }

          // Map<String, dynamic> tempData = getdata["data"];
          //     if (tempData.containsKey(TAG)) {
          //       tagList = List<String>.from(getdata["data"][TAG]);
          //     }
          //     if (isVerion == "1") {
          //       String? verionAnd = data['current_version'];
          //       String? verionIOS = data['current_version_ios'];
          //       PackageInfo packageInfo = await PackageInfo.fromPlatform();
          //       String version = packageInfo.version;
          //       final Version currentVersion = Version.parse(version);
          //       final Version latestVersionAnd = Version.parse(verionAnd);
          //       final Version latestVersionIos = Version.parse(verionIOS);
          //       if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
          //           (Platform.isIOS && latestVersionIos > currentVersion)) {
          //         updateDailog();
          //       }
          //     }
          //------------------------------------

          log('finished global settings');
        }, onError: (error) {
          log('HomePage getSettings() getNumoSettingApi error = $error');
          setSnackbar(error.toString(), context);
        });
      } catch (e) {
        debugPrint('***********store settings error**************');
        debugPrint('$e');
      }

      // apiBaseHelper.postAPICall(getSettingApi, parameter).then((getdata) async {
      //   bool error = getdata["error"];
      //   String? msg = getdata["message"];
      //   if (!error) {
      //     var data = getdata["data"]["system_settings"][0];
      //     var dd = getdata["data"].toString();
      //     debugPrint("======= system_settings DATA ==========");
      //     // log('system data = $dd');
      //     // debugPrint("-----------------------------------");
      //     // SUPPORTED_LOCALES = data["supported_locals"];
      //     if (data.toString().contains(MAINTAINANCE_MODE)) {
      //       Is_APP_IN_MAINTANCE = data[MAINTAINANCE_MODE];
      //     }
      //     if (Is_APP_IN_MAINTANCE != "1") {
      //       getSlider();
      //       getCat();
      //       getSection();
      //       getOfferImages();
      //     }
      //     if (data.toString().contains(MAINTAINANCE_MESSAGE)) {
      //       IS_APP_MAINTENANCE_MESSAGE = data[MAINTAINANCE_MESSAGE];
      //     }
      //     cartBtnList = true; //data["cart_btn_on_list"] == "1" ? true : false;
      //     refer = data["is_refer_earn_on"] == "1" ? true : false;
      //     CUR_CURRENCY = data["currency"];
      //     RETURN_DAYS = data['max_product_return_days'];
      //     MAX_ITEMS = data[MAX_ITEMS_CART];
      //     MIN_AMT = data['min_amount'];
      //     CUR_DEL_CHR = data['delivery_charge'];
      //     String? isVerion = data['is_version_system_on'];
      //     extendImg = data["expand_product_images"] == "1" ? true : false;
      //     String? del = data["area_wise_delivery_charge"];
      //     MIN_ALLOW_CART_AMT = data[MIN_CART_AMT];
      //     IS_LOCAL_PICKUP = data[LOCAL_PICKUP];
      //     ADMIN_ADDRESS = data[ADDRESS];
      //     ADMIN_LAT = data[LATITUDE];
      //     ADMIN_LONG = data[LONGITUDE];
      //     ADMIN_MOB = data[SUPPORT_NUM];
      //     // print("local pickup****${IS_LOCAL_PICKUP}");
      //     ALLOW_ATT_MEDIA = data[ALLOW_ATTACH];
      //     if (data.toString().contains(UPLOAD_LIMIT)) {
      //       UP_MEDIA_LIMIT = data[UPLOAD_LIMIT];
      //     }
      //     if (Is_APP_IN_MAINTANCE == "1") {
      //       appMaintenanceDialog(context);
      //     }
      //     if (del == "0") {
      //       ISFLAT_DEL = true;
      //     } else {
      //       ISFLAT_DEL = false;
      //     }
      //     if (CUR_MERCHANTID != null) {
      //       // REFER_CODE = getdata['data']['user_data'][0]['referral_code'];
      //       context
      //           .read<UserProvider>()
      //           .setPincode(getdata["data"]["user_data"][0][PINCODE]);
      //       if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE!.isEmpty) {
      //         generateReferral();
      //       }
      //       context.read<UserProvider>().setCartCount(
      //           getdata["data"]["user_data"][0]["cart_total_items"].toString());
      //       context
      //           .read<UserProvider>()
      //           .setBalance(getdata["data"]["user_data"][0]["balance"]);
      //       if (Is_APP_IN_MAINTANCE != "1") {
      //         _getFav();
      //         _getCart("0");
      //       }
      //     } else {
      //       if (Is_APP_IN_MAINTANCE != "1") {
      //         _getOffFav();
      //         _getOffCart();
      //       }
      //     }
      //     Map<String, dynamic> tempData = getdata["data"];
      //     if (tempData.containsKey(TAG)) {
      //       tagList = List<String>.from(getdata["data"][TAG]);
      //     }
      //     if (isVerion == "1") {
      //       String? verionAnd = data['current_version'];
      //       String? verionIOS = data['current_version_ios'];
      //       PackageInfo packageInfo = await PackageInfo.fromPlatform();
      //       String version = packageInfo.version;
      //       final Version currentVersion = Version.parse(version);
      //       final Version latestVersionAnd = Version.parse(verionAnd);
      //       final Version latestVersionIos = Version.parse(verionIOS);
      //       if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
      //           (Platform.isIOS && latestVersionIos > currentVersion)) {
      //         updateDailog();
      //       }
      //     }
      //   } else {
      //     setSnackbar(msg!, context);
      //   }
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      // });

    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> _getOffCart() async {
    log('HomePage - _getOffCart');
    if (CUR_MERCHANTID == null || CUR_MERCHANTID == "") {
      List<String>? proIds = (await db.getCart())!;

      if (proIds.isNotEmpty) {
        _isNetworkAvail = await isNetworkAvailable();

        if (_isNetworkAvail) {
          try {
            var parameter = {"product_variant_ids": proIds.join(',')};
            apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) async {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                var data = getdata["data"];

                List<Product> tempList = (data as List).map((data) => Product.fromJson(data)).toList();
                List<SectionModel> cartSecList = [];
                for (int i = 0; i < tempList.length; i++) {
                  for (int j = 0; j < tempList[i].ProductAttributeValues!.length; j++) {
                    if (proIds.contains(tempList[i].ProductAttributeValues![j].prodAttValue_id)) {
                      String qty = (await db.checkCartItemExists(tempList[i].product_id!, tempList[i].ProductAttributeValues![j].prodAttValue_id!))!;
                      List<Product>? prList = [];
                      prList.add(tempList[i]);
                      cartSecList.add(SectionModel(
                        product_id: tempList[i].product_id,
                        prodAttValue_id: tempList[i].ProductAttributeValues![j].prodAttValue_id,
                        cartItem_qty: qty,
                        productList: prList,
                      ));
                    }
                  }
                }

                context.read<CartProvider>().setCartlist(cartSecList);
              }
              if (mounted) {
                setState(() {
                  context.read<CartProvider>().setProgress(false);
                });
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            context.read<CartProvider>().setProgress(false);
          }
        } else {
          if (mounted) {
            setState(() {
              _isNetworkAvail = false;
              context.read<CartProvider>().setProgress(false);
            });
          }
        }
      } else {
        context.read<CartProvider>().setCartlist([]);
        setState(() {
          context.read<CartProvider>().setProgress(false);
        });
      }
    }
  }

  Future<void> _getOffFav() async {
    log('HomePage - _getOffFav');
    if (CUR_MERCHANTID == null || CUR_MERCHANTID == "") {
      List<String>? proIds = (await db.getFav())!;
      if (proIds.isNotEmpty) {
        _isNetworkAvail = await isNetworkAvailable();

        if (_isNetworkAvail) {
          try {
            var parameter = {"product_ids": proIds.join(',')};
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
  }

  Future<void> _getCart(String save) async {
    try {
      log('HomePage - _getCart');

      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        if (CUR_MERCHANTID != null && CUR_MERCHANTID != "") {
          try {
            log('HomePage _getCart CUR_MERCHANTID = $CUR_MERCHANTID');
            var parameter = {MERCHANT_ID: CUR_MERCHANTID};

            // var tempUri = Uri.parse('${getNumoCartsApi.toString()}merchant_id=$CUR_MERCHANTID');
            // log('tempUri = ${tempUri.toString()}');

            apiBaseHelper.getNumoAPICall(getNumoCartsApi, parameter, null).then((getdata) {
              // bool error = getdata["error"];
              // String? msg = getdata["message"];
              // if (!error) {

              // log('HomePage - _getCart getdata = $getdata');

              // log('HomePage _getCart  getdata[0][CARTITEMS]=${getdata[0][CARTITEMS]}');
              var data = getdata[0][CARTITEMS];
              // print('HomePage - _getCart getdata = $getdata');
              print('HomePage - _getCart data.length = ${data.length}');
              if (data != null) {
                List<SectionModel> cartList = (data as List).map((data) => SectionModel.fromCart(data)).toList();
                context.read<CartProvider>().setCartlist(cartList);

                context.read<UserProvider>().setCartCount(data.length.toString());
              }
              // }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });

            // apiBaseHelper.postAPICall(getCartApi, parameter).then((getdata) {
            //   bool error = getdata["error"];
            //   String? msg = getdata["message"];
            //   if (!error) {
            //     var data = getdata["data"];
            //     List<SectionModel> cartList = (data as List).map((data) => SectionModel.fromCart(data)).toList();
            //     context.read<CartProvider>().setCartlist(cartList);
            //   }
            // }, onError: (error) {
            //   setSnackbar(error.toString(), context);
            // });

          } on TimeoutException catch (_) {}
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

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> generateReferral() async {
    try {
      log('HomePage - generateReferral');

      String refer = getRandomString(8);

      //////

      Map parameter = {
        REFERCODE: refer,
      };

      // apiBaseHelper.postAPICall(validateReferalApi, parameter).then((getdata) {
      //   bool error = getdata["error"];
      //   String? msg = getdata["message"];
      //   if (!error) {
      //     REFER_CODE = refer;
      //     Map parameter = {
      //       MERCHANT_ID: CUR_MERCHANTID,
      //       REFERCODE: refer,
      //     };
      //     apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
      //   } else {
      //     if (count < 5) generateReferral();
      //     count++;
      //   }

      context.read<HomeProvider>().setSecLoading(false);
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      //   context.read<HomeProvider>().setSecLoading(false);
      // });

    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  updateDailog() async {
    log('HomePage - updateDailog');

    await dialogAnimate(context, StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        title: Text(getTranslated(context, 'UPDATE_APP')!),
        content: Text(
          getTranslated(context, 'UPDATE_AVAIL')!,
          style: Theme.of(this.context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                getTranslated(context, 'NO')!,
                style: Theme.of(this.context)
                    .textTheme
                    .subtitle2!
                    .copyWith(color: Theme.of(context).colorScheme.lightBlack, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              }),
          TextButton(
              child: Text(
                getTranslated(context, 'YES')!,
                style:
                    Theme.of(this.context).textTheme.subtitle2!.copyWith(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop(false);

                String url = '';
                if (Platform.isAndroid) {
                  url = androidLink + packageName;
                } else if (Platform.isIOS) {
                  url = iosLink;
                }

                if (await canLaunchUrlString(url)) {
                  await launchUrlString(url);
                } else {
                  throw 'Could not launch $url';
                }
              })
        ],
      );
    }));
  }

  Widget homeShimmer() {
    log('HomePage - homeShimmer');

    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            catLoading(),
            sliderLoading(),
            sectionLoading(),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    log('HomePage - sliderLoading');

    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: height,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget _buildImagePageItem(Model slider) {
    log('HomePage - _buildImagePageItem');
    double height = deviceWidth! / 0.5;

    return InkWell(
      child: FadeInImage(
          fadeInDuration: const Duration(milliseconds: 150),
          image: NetworkImage(numoImageUrl + slider.slider_image!),
          height: height,
          width: double.maxFinite,
          fit: BoxFit.fill,
          imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                "assets/images/Placeholder_Rectangle22.png",
                fit: BoxFit.fill,
                height: height,
                width: deviceWidth! / 2,
              ),
          placeholderErrorBuilder: (context, error, stackTrace) => Image.asset(
                "assets/images/Placeholder_Rectangle22.png",
                fit: BoxFit.fill,
                height: height,
                width: deviceWidth! / 2,
              ),
          placeholder: AssetImage("${imagePath}Placeholder_Rectangle22.png")),
      onTap: () async {
        int curSlider = context.read<HomeProvider>().curSlider;

        if (homeSliderList[curSlider].type == "products") {
          log('HomePage _buildImagePageItem onTap homeSliderList[curSlider=$curSlider].type=products');
          Product item = homeSliderList[curSlider].list;

          Navigator.push(
            context,
            PageRouteBuilder(pageBuilder: (_, __, ___) => ProductDetail(model: item.Childern![0], secPos: 0, index: 0, list: true)),
          );
        } else if (homeSliderList[curSlider].type == "categories") {
          log('HomePage _buildImagePageItem onTap homeSliderList[curSlider=$curSlider].type=categories');

          Product item = homeSliderList[curSlider].list;
          if (item.Childern!.isEmpty) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ProductList(
                    category_name: item.Childern![0].category_name,
                    category_id: item.Childern![0].category_id,
                    tag: false,
                    fromSeller: false,
                  ),
                ));
          } else {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => SubCategory(
                    title: item.category_name!,
                    subList: item.Childern,
                  ),
                ));
          }
        }
      },
    );
  }

  Widget deliverLoading() {
    log('HomePage - deliverLoading');
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget catLoading() {
    log('HomePage - catLoading');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            shape: BoxShape.circle,
                          ),
                          width: 80.0, //50.0
                          height: 80.0, //50.0
                        ))
                    .toList()),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  Widget noInternet(BuildContext context) {
    log('HomePage - noInternet');

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
            context.read<HomeProvider>().setCatLoading(true);
            context.read<HomeProvider>().setSecLoading(true);
            context.read<HomeProvider>().setSliderLoading(true);
            _playAnimation();

            Future.delayed(const Duration(seconds: 2)).then((_) async {
              _isNetworkAvail = await isNetworkAvailable();
              if (_isNetworkAvail) {
                if (mounted) {
                  setState(() {
                    _isNetworkAvail = true;
                  });
                }
                callApi();
              } else {
                await buttonController.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  _deliverPincode() {
    // log('HomePage - _deliverPincode');
    // String curpin = context.read<UserProvider>().curPincode;
    return InkWell(
      onTap: _pincodeCheck,
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).colorScheme.lightWhite,
        child: ListTile(
          dense: true,
          minLeadingWidth: 10,
          leading: const Icon(
            Icons.location_pin,
          ),
          title: Selector<UserProvider, String>(
            builder: (context, data, child) {
              return Text(
                data == '' ? getTranslated(context, 'SELOC')! : getTranslated(context, 'DELIVERTO')! + data,
                style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
              );
            },
            selector: (_, provider) => provider.curPincode,
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
      ),
    );
  }

  _getSearchBar() {
    // log('HomePage - _getSearchBar');
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 38,
          child: TextField(
            enabled: false,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  borderSide: BorderSide(
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                isDense: true,
                hintText: getTranslated(context, 'searchHint'),
                hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/images/search.svg',
                    color: colors.primary,
                  ),
                ),
                fillColor: Theme.of(context).colorScheme.lightWhite,
                filled: true),
          ),
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Search(),
            ));
        if (mounted) setState(() {});
      },
    );
  }

  void _pincodeCheck() {
    log('HomePage - _pincodeCheck');
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
                    padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 40, top: 30),
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
                                  context.read<UserProvider>().setPincode(value!);
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
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(start: 20),
                                      width: deviceWidth! * 0.35,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          context.read<UserProvider>().setPincode('');

                                          context.read<HomeProvider>().setSecLoading(true);
                                          getSection();
                                          Navigator.pop(context);
                                        },
                                        child: Text(getTranslated(context, 'All')!),
                                      ),
                                    ),
                                    const Spacer(),
                                    SimBtn(
                                        width: 0.35,
                                        height: 35,
                                        title: getTranslated(context, 'APPLY'),
                                        onBtnSelected: () async {
                                          if (validateAndSave()) {
                                            // validatePin(curPin);
                                            context.read<HomeProvider>().setSecLoading(true);
                                            getSection();

                                            Navigator.pop(context);
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ))
              ]),
            );
            //});
          });
        });
  }

  bool validateAndSave() {
    log('HomePage - validateAndSave');
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<void> _playAnimation() async {
    log('HomePage - _playAnimation');
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  void getSlider() {
    try {
      log('HomePage - getSlider');
      Map<String, dynamic> map = {};

      // debugPrint('======getSlider=data==');

      apiBaseHelper.getNumoAPICall(getNumoSliderApi, map, null).then((data) {
        homeSliderList = (data as List).map((data) => Model.fromSlider(data)).toList();

        // log('homeSliderList =$homeSliderList');

        pages = homeSliderList.map((slider) {
          return _buildImagePageItem(slider);
        }).toList();

        log('pages =$pages');
        context.read<HomeProvider>().setSliderLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSliderLoading(false);
      });

      // apiBaseHelper.postAPICall(getSliderApi, map).then((getdata) {
      //   bool error = getdata["error"];
      //   String? msg = getdata["message"];
      //   if (!error) {
      //     var data = getdata["data"];
      //     homeSliderList =
      //         (data as List).map((data) => Model.fromSlider(data)).toList();
      //     pages = homeSliderList.map((slider) {
      //       return _buildImagePageItem(slider);
      //     }).toList();
      //   } else {
      //     setSnackbar(msg!, context);
      //   }
      //   context.read<HomeProvider>().setSliderLoading(false);
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      //   context.read<HomeProvider>().setSliderLoading(false);
      // });

    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  void getCat() {
    try {
      log('HomePage - getCat');
      Map<String, dynamic> parameter = {ALLPARENTS: 1.toString()};

      // apiBaseHelper.getNumoAPICall(getNumoParentCatApi, parameter).then((data) {
      apiBaseHelper.getNumoAPICall(getNumoCatApi, parameter, null).then((data) {
        // log('Categoreies data=$data');
        catList = (data as List).map((data) => Product.fromCat(data)).toList();

        // var temp = catList[0].toString();
        // log('getCat getNumoCatApi catList[0]=$temp');
        // if (getdata.containsKey("popular_categories")) {
        //   var data = getdata["popular_categories"];
        //   popularList =
        //       (data as List).map((data) => Product.fromCat(data)).toList();
        //   if (popularList.isNotEmpty) {
        //     Product pop =
        //         Product.popular("Popular", "${imagePath}popular.svg");
        //     catList.insert(0, pop);
        //     context.read<CategoryProvider>().setSubList(popularList);
        //   }
        // }
        // } else {
        //   setSnackbar('error ', context);
        // }

        context.read<HomeProvider>().setCatLoading(false);
      }, onError: (error) {
        log('HomePage getCat getNumoCatApi error = $error');
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setCatLoading(false);
      });

      // apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
      //   bool error = getdata["error"];
      //   String? msg = getdata["message"];
      //   if (!error) {
      //     var data = getdata["data"];
      //     catList =
      //         (data as List).map((data) => Product.fromCat(data)).toList();
      //     if (getdata.containsKey("popular_categories")) {
      //       var data = getdata["popular_categories"];
      //       popularList =
      //           (data as List).map((data) => Product.fromCat(data)).toList();
      //       if (popularList.isNotEmpty) {
      //         Product pop =
      //             Product.popular("Popular", "${imagePath}popular.svg");
      //         catList.insert(0, pop);
      //         context.read<CategoryProvider>().setSubList(popularList);
      //       }
      //     }
      //   } else {
      //     setSnackbar(msg!, context);
      //   }
      //   context.read<HomeProvider>().setCatLoading(false);
      // }, onError: (error) {
      //   setSnackbar(error.toString(), context);
      //   context.read<HomeProvider>().setCatLoading(false);
      // });

    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  sectionLoading() {
    log('HomePage - sectionLoading');
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 40),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)))),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                width: double.infinity,
                                height: 18.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              GridView.count(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  childAspectRatio: 1.0,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  children: List.generate(
                                    4,
                                    (index) {
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Theme.of(context).colorScheme.white,
                                      );
                                    },
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    sliderLoading()
                    //offerImages.length > index ? _getOfferImage(index) : Container(),
                  ],
                ))
            .toList());
  }

  @override
  void dispose() {
    log('HomePage - dispose');
    _scrollBottomBarController.removeListener(() {});
    //controller!.dispose();
    //  controller1!.dispose();
    // controller2!.dispose();
    super.dispose();
  }
}

void appMaintenanceDialog(BuildContext context) async {
  log('HomePage - appMaintenanceDialog');
  await dialogAnimate(context, StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        title: Text(
          getTranslated(context, 'APP_MAINTENANCE')!,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Lottie.asset('assets/animation/maintenance.json'),
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              IS_APP_MAINTENANCE_MESSAGE != '' ? IS_APP_MAINTENANCE_MESSAGE! : getTranslated(context, 'MAINTENANCE_DEFAULT_MESSAGE')!,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.normal, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }));
}
