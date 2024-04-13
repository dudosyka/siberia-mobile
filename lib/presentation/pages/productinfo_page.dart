import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:mobile_app_slb/data/models/availability_model.dart';
import 'package:mobile_app_slb/data/models/productinfo_model.dart';
import 'package:mobile_app_slb/presentation/states/assortment_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_app_slb/presentation/widgets/app_drawer_qr.dart';
import '../../data/models/stock_model.dart';
import '../../utils/constants.dart';
import '../states/auth_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import 'auth_page.dart';
import 'dart:io' show Platform;

class ProductInfoPage extends ConsumerStatefulWidget {
  const ProductInfoPage(
      {super.key,
      required this.productId,
      required this.name,
      required this.photos,
      required this.sku,
      required this.ean,
      required this.count,
      required this.availabilityModel,
      required this.stockModel,
      required this.isQr});

  final int productId;
  final String name;
  final List<dynamic>? photos;
  final String sku;
  final String ean;
  final double count;
  final List<AvailabilityModel> availabilityModel;
  final StockModel stockModel;
  final bool isQr;

  @override
  ConsumerState<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends ConsumerState<ProductInfoPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).size.shortestSide > 650
                ? const TextScaler.linear(1.1)
                : const TextScaler.linear(1.0)),
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: widget.isQr
              ? AppDrawerQr(stockModel: widget.stockModel)
              : AppDrawer(
                  isAbleToNavigate: true,
                  isAssembly: false,
                  isHomePage: false,
                  stockModel: widget.stockModel,
                ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 40, right: 40, left: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            backButton(() => Navigator.pop(context),
                                AppLocalizations.of(context)!.backCaps, true),
                            Builder(builder: (context) {
                              return InkWell(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3C3C3C),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.singleProductCaps,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF909090),
                                height: 0.5,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: Marquee(
                                text: widget.name,
                                style: const TextStyle(
                                  fontSize: 36,
                                  color: Color(0xFF363636),
                                  fontWeight: FontWeight.bold,
                                ),
                                blankSpace: width - 80,
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                velocity: 45.0,
                                pauseAfterRound: const Duration(seconds: 3),
                                fadingEdgeEndFraction: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: ref
                      .watch(getProductInfoProvider(widget.productId))
                      .when(
                        data: (value) {
                          if (value.errorModel != null) {
                            ref.read(deleteAuthProvider).deleteAuth();
                            Future.microtask(
                              () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AuthPage()),
                                (route) => false,
                              ),
                            );

                            return Container();
                          }

                          return productInfoWidget(value.productModel!, width);
                        },
                        error: (error, stacktrace) {
                          if (Platform.isAndroid) {
                            return AlertDialog(
                              title: Text(error.toString()),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    SystemChannels.platform
                                        .invokeMethod('SystemNavigator.pop');
                                  },
                                  child: const Text("Ok"),
                                ),
                              ],
                            );
                          } else {
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!
                                    .smtWentWrongReload,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget productInfoWidget(ProductInfoModel productInfoModel, double width) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: 170,
                  height: 190,
                  child: Stack(
                    children: [
                      CarouselSlider(
                          items: widget.photos != null
                              ? widget.photos!.isNotEmpty
                                  ? widget.photos!.map((e) {
                                      return Image.network(
                                        "${baseUrl}file/stream/$e",
                                        width: 160,
                                        height: 160,
                                        errorBuilder:
                                            (context, obj, stacktrace) {
                                          return const Icon(
                                            Icons.camera_alt,
                                            color: Color(0xFF909090),
                                          );
                                        },
                                        loadingBuilder:
                                            (context, widget, event) {
                                          if (event == null) {
                                            return widget;
                                          }
                                          return Center(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .loading,
                                              style: const TextStyle(
                                                  color: Color(0xFF909090)),
                                            ),
                                          );
                                        },
                                        fit: BoxFit.contain,
                                      );
                                    }).toList()
                                  : [
                                      Image.network(
                                        "",
                                        errorBuilder:
                                            (context, obj, stacktrace) =>
                                                const Icon(
                                          Icons.camera_alt,
                                          color: Color(0xFF909090),
                                        ),
                                        loadingBuilder:
                                            (context, widget, event) {
                                          if (event == null) {
                                            return widget;
                                          }
                                          return Center(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .loading,
                                              style: const TextStyle(
                                                  color: Color(0xFF909090)),
                                            ),
                                          );
                                        },
                                        fit: BoxFit.cover,
                                      )
                                    ]
                              : [
                                  Image.network(
                                    "",
                                    errorBuilder: (context, obj, stacktrace) =>
                                        const Icon(
                                      Icons.camera_alt,
                                      color: Color(0xFF909090),
                                    ),
                                    loadingBuilder: (context, widget, event) {
                                      if (event == null) {
                                        return widget;
                                      }
                                      return Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.loading,
                                          style: const TextStyle(
                                              color: Color(0xFF909090)),
                                        ),
                                      );
                                    },
                                    fit: BoxFit.cover,
                                  )
                                ],
                          options: CarouselOptions(
                            viewportFraction: 1,
                            height: 170,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                          )),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: DotsIndicator(
                          dotsCount: widget.photos != null
                              ? widget.photos!.isNotEmpty
                                  ? widget.photos!.length
                                  : 1
                              : 1,
                          position: currentIndex,
                          decorator: DotsDecorator(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            size: const Size(6, 6),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.quantityCaps,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    Text(
                      widget.count.toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF363636)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppLocalizations.of(context)!.skuCaps,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    Text(
                      widget.sku,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF363636)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppLocalizations.of(context)!.eanCaps,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    Text(
                      widget.ean,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF363636)),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.brandCaps,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    SizedBox(
                      width: width / 3 - 12,
                      child: Text(
                        productInfoModel.brand,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363636)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.collectionCaps,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    SizedBox(
                      width: width / 3 - 12,
                      child: Text(
                        productInfoModel.collection,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363636)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.colorCaps,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    SizedBox(
                      width: width / 3 - 12,
                      child: Text(
                        productInfoModel.color,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363636)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.descriptionCaps,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF909090)),
                ),
                Text(
                  productInfoModel.description,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF363636)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.defaultPriceCaps,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    SizedBox(
                      width: width / 3 - 12,
                      child: Text(
                        productInfoModel.commonPrice.toString(),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363636)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.distributionPriceCaps,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    SizedBox(
                      width: width / 3 - 12,
                      child: Text(
                        productInfoModel.distributionPrice.toString(),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363636)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.professionalPriceCaps,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF909090)),
                    ),
                    SizedBox(
                      width: width / 3 - 12,
                      child: Text(
                        productInfoModel.professionalPrice.toString(),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363636)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.ofertaPriceCaps,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF909090)),
                ),
                Text(
                  productInfoModel.offertaPrice.toString(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF363636)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.inStockCaps,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF909090)),
                ),
                getAvailability(width)
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget getAvailability(double width) {
    return SizedBox(
      height: widget.availabilityModel.length * 75,
      child: ListView(
        children: widget.availabilityModel
            .mapIndexed((index, e) => Column(
                  children: [
                    index == 0
                        ? Container()
                        : const Divider(
                            height: 1,
                          ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.place,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: width - 10 - 16 - 44,
                                child: Text(
                                  e.name,
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: width - 10 - 16 - 44,
                                child: Text(
                                  e.address,
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF969696)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    index == widget.availabilityModel.length - 1
                        ? const Divider(
                            height: 1,
                          )
                        : Container()
                  ],
                ))
            .toList(),
      ),
    );
  }
}
