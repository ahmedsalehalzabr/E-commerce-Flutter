import 'package:collection/src/iterable_extensions.dart';
import 'package:numo/Helper/Color.dart';
import 'package:numo/Helper/String.dart';
import 'package:numo/Model/Section_Model.dart';
import 'package:numo/Provider/ProductDetailProvider.dart';
import 'package:numo/Screen/Product_Detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/src/provider.dart';

import '../Helper/Session.dart';

class ListItemCom extends StatefulWidget {
  final Product? productList;
  final ValueChanged<bool>? isSelected;
  final int? secPos;
  final int? len, index;

  const ListItemCom({
    Key? key,
    this.productList,
    this.isSelected,
    this.secPos,
    this.len,
    this.index,
  }) : super(key: key);

  @override
  _ListItemNotiState createState() => _ListItemNotiState();
}

class _ListItemNotiState extends State<ListItemCom> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return productItem();
  }

  Widget productItem() {
    List<Product> compareList = context.read<ProductDetailProvider>().compareList;

    String? offPer;
    double price = double.parse(widget.productList!.ProductAttributeValues![0].old_price!);
    if (price == 0) {
      price = double.parse(widget.productList!.ProductAttributeValues![0].price1!);
    } else {
      double off = double.parse(widget.productList!.ProductAttributeValues![0].price1!) - price;
      offPer = ((off * 100) / double.parse(widget.productList!.ProductAttributeValues![0].price1!)).toStringAsFixed(0);
    }

    double width = deviceWidth! * 0.45;
    var extPro = compareList.firstWhereOrNull((cp) => cp.product_id == widget.productList!.product_id);

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
                Container(
                  alignment: Alignment.topRight,
                  padding: const EdgeInsetsDirectional.only(end: 5.0, top: 5.0),
                  child: InkWell(
                    child: extPro != null
                        ? const Icon(
                            Icons.check_circle,
                            color: colors.primary,
                            size: 22,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            color: colors.primary,
                            size: 22,
                          ),
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                        widget.isSelected!(isSelected);
                      });
                    },
                  ),
                ),
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
                              tag: "${widget.productList!.product_id}",
                              child: FadeInImage(
                                image: NetworkImage(widget.productList!.product_image!),
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
                                decoration: const BoxDecoration(
                                  color: colors.red,
                                ),
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
                        rating: double.parse(widget.productList!.rating!),
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
                        " (${widget.productList!.noOfRating!})",
                        style: Theme.of(context).textTheme.overline,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5.0, top: 5, bottom: 5),
                  child: Text(
                    widget.productList!.product_name!,
                    style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Text('${getPriceFormat(context, price)!} ',
                        style: TextStyle(color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold)),
                    Text(
                      double.parse(widget.productList!.ProductAttributeValues![0].old_price!) != 0
                          ? getPriceFormat(context, double.parse(widget.productList!.ProductAttributeValues![0].price1!))!
                          : "",
                      style: Theme.of(context).textTheme.overline!.copyWith(decoration: TextDecoration.lineThrough, letterSpacing: 0),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Product model = widget.productList!;

              Navigator.push(
                context,
                PageRouteBuilder(pageBuilder: (_, __, ___) => ProductDetail(model: model, secPos: widget.secPos, index: widget.index, list: true)),
              );
            },
          ),
        ));
  }
}
