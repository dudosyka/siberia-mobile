import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/states/assortment_state.dart';

import '../../utils/constants.dart';
import '../states/auth_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import 'auth_page.dart';

class ProductInfoPage extends ConsumerStatefulWidget {
  const ProductInfoPage(
      {super.key,
      required this.productId,
      required this.name,
      required this.photos,
      required this.sku,
      required this.ean,
      required this.count});

  final int productId;
  final String name;
  final List<dynamic>? photos;
  final String sku;
  final String ean;
  final double count;

  @override
  ConsumerState<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends ConsumerState<ProductInfoPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: const AppDrawer(
        isAbleToNavigate: true,
        isAssembly: false,
        isHomePage: false,
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
                        backButton(() => Navigator.pop(context), "BACK", true),
                        InkWell(
                          onTap: () {
                            scaffoldKey.currentState?.openDrawer();
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: const Color(0xFF3C3C3C),
                                borderRadius: BorderRadius.circular(5)),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "SINGLE PRODUCT",
                          style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFF909090),
                              height: 0.5),
                        ),
                        Text(
                          widget.name,
                          style: const TextStyle(
                              fontSize: 36,
                              color: Color(0xFF363636),
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
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
              child: ref.watch(getProductInfoProvider(widget.productId)).when(
                  data: (value) {
                    if (value.errorModel != null) {
                      ref.read(deleteAuthProvider).deleteAuth();
                      Future.microtask(() => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthPage()),
                          (route) => false));

                      return Container();
                    }

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
                                  height: 170,
                                  child: CarouselSlider(
                                      items: widget.photos != null
                                          ? widget.photos!.map((e) {
                                              return Image.network(
                                                "${baseUrl}file/stream/$e",
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
                                                  return const Center(
                                                    child: Text(
                                                      "Loading...",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF909090)),
                                                    ),
                                                  );
                                                },
                                                fit: BoxFit.cover,
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
                                                  return const Center(
                                                    child: Text(
                                                      "Loading...",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF909090)),
                                                    ),
                                                  );
                                                },
                                                fit: BoxFit.cover,
                                              )
                                            ],
                                      options:
                                          CarouselOptions(viewportFraction: 1)),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "QUANTITY",
                                      style: TextStyle(
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
                                    ),
                                    const Text(
                                      "SKU",
                                      style: TextStyle(
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
                                    ),
                                    const Text(
                                      "EAN",
                                      style: TextStyle(
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
                                    const Text(
                                      "BRAND",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF909090)),
                                    ),
                                    Text(
                                      value.productModel!.brand,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF363636)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "COLLECTION",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF909090)),
                                    ),
                                    Text(
                                      value.productModel!.collection,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF363636)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "COLOR",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF909090)),
                                    ),
                                    Text(
                                      value.productModel!.color,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF363636)),
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
                                const Text(
                                  "DESCRIPTION",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF909090)),
                                ),
                                Text(
                                  value.productModel!.description,
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
                                    const Text(
                                      "DEFAULT PRICE",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF909090)),
                                    ),
                                    Text(
                                      value.productModel!.commonPrice.toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF363636)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "DISTRIBUTION PRICE",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF909090)),
                                    ),
                                    Text(
                                      value.productModel!.distributionPrice
                                          .toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF363636)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "PROFESSIONAL PRICE",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF909090)),
                                    ),
                                    Text(
                                      value.productModel!.professionalPrice
                                          .toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF363636)),
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
                                const Text(
                                  "OFERTA PRICE",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF909090)),
                                ),
                                Text(
                                  value.productModel!.offertaPrice
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF363636)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                  error: (error, stacktrace) {
                    return AlertDialog(
                      title: Text(error.toString()),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Ok"))
                      ],
                    );
                  },
                  loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )),
            )
          ],
        ),
      ),
    );
  }
}
