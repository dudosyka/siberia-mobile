import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/models/assortment_model.dart';
import 'package:mobile_app_slb/data/models/category_model.dart';
import 'package:mobile_app_slb/data/models/productinfo_model.dart';
import 'package:mobile_app_slb/data/models/stock_model.dart';
import 'package:mobile_app_slb/domain/usecases/filters_usecase.dart';
import 'package:mobile_app_slb/presentation/pages/assembling_page.dart';
import 'package:mobile_app_slb/presentation/pages/auth_page.dart';
import 'package:mobile_app_slb/presentation/pages/home_page.dart';
import 'package:mobile_app_slb/presentation/pages/productinfo_page.dart';
import 'package:mobile_app_slb/presentation/states/auth_state.dart';
import 'package:mobile_app_slb/presentation/states/newsale_state.dart';
import 'package:mobile_app_slb/presentation/widgets/app_drawer.dart';
import 'package:mobile_app_slb/presentation/widgets/app_drawer_qr.dart';
import 'package:mobile_app_slb/presentation/widgets/backButton.dart';
import 'package:mobile_app_slb/presentation/widgets/exit_dialog.dart';
import 'package:mobile_app_slb/presentation/widgets/gray_button.dart';
import 'package:mobile_app_slb/presentation/widgets/outlined_gray_button.dart';
import 'package:mobile_app_slb/utils/constants.dart' as constants;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/models/cart_model.dart';
import '../states/assortment_state.dart';
import '../widgets/round_button.dart';
import 'dart:io' show Platform;

class NewSalePage extends ConsumerStatefulWidget {
  const NewSalePage(
      {super.key,
      required this.currentStorehouse,
      required this.storehouseId,
      required this.isTransaction,
      required this.stockModel});

  final String currentStorehouse;
  final int storehouseId;
  final bool isTransaction;
  final StockModel stockModel;

  @override
  ConsumerState<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends ConsumerState<NewSalePage>
    with WidgetsBindingObserver {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchCont = TextEditingController();
  final TextEditingController colorCont = TextEditingController();
  List selectedBrands = [];
  List selectedCollections = [];
  List selectedCategories = [];
  bool isGrid = false;
  int? sortColumnIndex;
  bool isAscendingName = true;
  bool isAscendingVendor = true;
  bool isTappedName = false;
  bool isTappedVendor = false;
  Map<String, dynamic> filters = {
    "name": "",
    "availability": true,
    "color": "",
    "brand": null,
    "collection": null,
    "category": null
  };
  String baseUrl = constants.baseUrl;
  FiltersUseCase? filtersUseCase;

  @override
  void initState() {
    super.initState();
    ref.read(cartDataProvider).getCurrentStock();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      showDialog(
          context: context,
          builder: (context) {
            return exitDialog(
                context, AppLocalizations.of(context)!.areYouSure);
          }).then((returned) {
        if (returned) {
          ref.read(cartDataProvider).deleteOutcome();
          if (widget.isTransaction) {
            ref.read(deleteAuthProvider).deleteAuth();
            Future.microtask(() => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
                (route) => false));
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          final navigator = Navigator.of(context);

          showDialog(
              context: context,
              builder: (context) {
                return exitDialog(
                    context, AppLocalizations.of(context)!.areYouSure);
              }).then((returned) {
            if (returned) {
              ref.read(cartDataProvider).deleteOutcome();
              navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false);
            }
          });
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context).size.shortestSide > 650
                  ? const TextScaler.linear(1.1)
                  : const TextScaler.linear(1.0)),
          child: Scaffold(
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            drawer: widget.isTransaction
                ? AppDrawerQr(stockModel: widget.stockModel)
                : AppDrawer(
                    isAbleToNavigate: false,
                    isAssembly: false,
                    isHomePage: false,
                    stockModel: widget.stockModel,
                  ),
            bottomNavigationBar: SafeArea(
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xFFD9D9D9), width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) =>
                                  filtersBottomSheet(context, width));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/assortment_filter_icon.png",
                              scale: 4,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.filters,
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: SizedBox(
                          width: 65,
                          height: 65,
                          child: Stack(
                            children: [
                              roundButton(
                                  const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  60, () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return cartBottomSheet(width);
                                    });
                              }, true),
                              ref.watch(cartDataProvider).cartData.isEmpty
                                  ? Container()
                                  : Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                color: Colors.black, width: 2)),
                                        child: Center(
                                          child: Text(
                                            ref
                                                .watch(cartDataProvider)
                                                .cartData
                                                .length
                                                .toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(getAvailabilityProvider)
                              .changeSearchingState();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/assortment_search_icon.png",
                              scale: 4,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.search,
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            body: SafeArea(
                child: ref.watch(getFiltersProvider).when(
                    data: (value2) {
                      if (value2.errorModel != null) {
                        ref.read(deleteAuthProvider).deleteAuth();
                        Future.microtask(() => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuthPage()),
                            (route) => false));

                        return Container();
                      }
                      filtersUseCase = value2;
                      return GestureDetector(
                        onTap: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 40, right: 40, left: 40, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        backButton(() {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return exitDialog(
                                                    context,
                                                    AppLocalizations.of(
                                                            context)!
                                                        .areYouSure);
                                              }).then((returned) {
                                            if (returned) {
                                              ref
                                                  .read(cartDataProvider)
                                                  .deleteOutcome();
                                              if (widget.isTransaction) {
                                                ref
                                                    .read(deleteAuthProvider)
                                                    .deleteAuth();
                                                Future.microtask(() => Navigator
                                                    .pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AuthPage()),
                                                        (route) => false));
                                              } else {
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const HomePage()),
                                                    (route) => false);
                                              }
                                            }
                                          });
                                        },
                                            AppLocalizations.of(context)!
                                                .cancelCaps,
                                            false),
                                        Builder(builder: (context) {
                                          return InkWell(
                                            onTap: () {
                                              scaffoldKey.currentState
                                                  ?.openDrawer();
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF3C3C3C),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: const Icon(
                                                Icons.menu,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .newSaleCaps,
                                        style: const TextStyle(
                                            fontSize: 24,
                                            color: Color(0xFF909090),
                                            height: 0.5),
                                      ),
                                    ),
                                    Text(
                                      widget.currentStorehouse,
                                      style: const TextStyle(
                                          fontSize: 36,
                                          color: Color(0xFF363636),
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              flex: 8,
                              child: Column(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(seconds: 1),
                                    child: ref
                                            .watch(getAvailabilityProvider)
                                            .isSearching
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 40, right: 40),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: TextFormField(
                                                      controller: searchCont,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      cursorColor: Colors.black,
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        fillColor: const Color(
                                                            0xFFFCFCFC),
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Color(
                                                                        0xFFCFCFCF)),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        prefixIcon: const Icon(
                                                          Icons.search,
                                                          color:
                                                              Color(0xFF5F5F5F),
                                                        ),
                                                        hintText:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .search,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                          setState(() {
                                                            filters["name"] =
                                                                searchCont.text;
                                                          });
                                                          ref
                                                              .refresh(
                                                                  getAssortmentProvider(
                                                                      filters))
                                                              .value;
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            elevation: 0,
                                                            backgroundColor:
                                                                Colors.black,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10))),
                                                        child: const Icon(
                                                          Icons.search,
                                                          color: Colors.white,
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            height: 40,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .viewCaps,
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Color(0xFFAAAAAA)),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isGrid = false;
                                                    });
                                                  },
                                                  child: Image.asset(
                                                      "assets/images/assortment_text_icon.png",
                                                      scale: 4,
                                                      color: Colors.black
                                                          .withOpacity(isGrid
                                                              ? 0.3
                                                              : 1)),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isGrid = true;
                                                    });
                                                  },
                                                  child: Image.asset(
                                                      "assets/images/assortment_grid_icon.png",
                                                      scale: 4,
                                                      color: Colors.black
                                                          .withOpacity(!isGrid
                                                              ? 0.3
                                                              : 1)),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(
                                    height: 1,
                                  ),
                                  ref
                                      .watch(getAssortmentProvider(filters))
                                      .when(
                                          data: (value) {
                                            if (value.assortmentModel != null &&
                                                value.errorModel == null) {
                                              ThemeData theme =
                                                  Theme.of(context);

                                              if (isGrid) {
                                                return getProductGridWidget(
                                                    value.assortmentModel!,
                                                    width);
                                              } else {
                                                return getProductListWidget(
                                                    theme,
                                                    value.assortmentModel!,
                                                    width);
                                              }
                                            }
                                            if (value.errorModel!.statusCode ==
                                                401) {
                                              ref
                                                  .read(deleteAuthProvider)
                                                  .deleteAuth();
                                              Future.microtask(() =>
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AuthPage()),
                                                      (route) => false));

                                              return Container();
                                            }
                                            return AlertDialog(
                                              title: Text(
                                                  value.errorModel!.statusText),
                                              actions: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("Ok"))
                                              ],
                                            );
                                          },
                                          error: (error, stacktrace) {
                                            if (Platform.isAndroid) {
                                              return AlertDialog(
                                                title: Text(error.toString()),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        //Navigator.pop(context);
                                                        SystemChannels.platform
                                                            .invokeMethod(
                                                                'SystemNavigator.pop');
                                                      },
                                                      child: const Text("Ok"))
                                                ],
                                              );
                                            } else {
                                              return AlertDialog(
                                                title: Text(
                                                  AppLocalizations.of(context)!.smtWentWrongReload,
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            }
                                          },
                                          loading: () => const Expanded(
                                                flex: 5,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CircularProgressIndicator(
                                                      color: Colors.black,
                                                    ),
                                                  ],
                                                ),
                                              ))
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    error: (error, stacktrace) {
                      if (Platform.isAndroid) {
                        return AlertDialog(
                          title: Text(error.toString()),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  //Navigator.pop(context);
                                  SystemChannels.platform
                                      .invokeMethod('SystemNavigator.pop');
                                },
                                child: const Text("Ok"))
                          ],
                        );
                      } else {
                        return AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.smtWentWrongReload,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                    },
                    loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ))),
          ),
        ));
  }

  Widget getProductListWidget(
      ThemeData theme, List<AssortmentModel> data, double width) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 56,
            decoration: const BoxDecoration(color: Color(0xFF272727)),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isTappedName = true;
                        data.sort((prod1, prod2) => compareString(
                            isAscendingName, prod1.name, prod2.name));
                        isAscendingName = !isAscendingName;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.nameCaps,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 20),
                        ),
                        isTappedName
                            ? isAscendingName
                                ? const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 16,
                                  )
                            : Container()
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(
                  color: Color(0xFFD9D9D9),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isTappedVendor = true;
                        data.sort((prod1, prod2) => compareString(
                            isAscendingVendor,
                            prod1.vendorCode,
                            prod2.vendorCode));
                        isAscendingVendor = !isAscendingVendor;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.skuCaps,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 20),
                        ),
                        isTappedVendor
                            ? isAscendingVendor
                                ? const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 16,
                                  )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              flex: 5,
              child: ListView(
                children: data.mapIndexed((index, e) {
                  return InkWell(
                    onTap: () async {
                      final availability = await ref
                          .read(getAvailabilityProvider)
                          .getAvailability(e.id);
                      if (availability.errorModel == null) {
                        if (mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductInfoPage(
                                      productId: data[index].id,
                                      name: data[index].name,
                                      photos: data[index].fileNames,
                                      sku: data[index].vendorCode,
                                      ean: data[index].eanCode,
                                      count: data[index].quantity ?? 0.0,
                                      availabilityModel:
                                          availability.availabilityModel!,
                                      stockModel: widget.stockModel,
                                      isQr: widget.isTransaction)));
                        } else {
                          ref.read(deleteAuthProvider).deleteAuth();
                          Future.microtask(() => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthPage()),
                              (route) => false));
                        }
                      }
                    },
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? const Color(0xFFF9F9F9)
                              : Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 11,
                                        height: 11,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: const Color(0xFFDFDFDF)),
                                      ),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: e.quantity == null
                                                ? const Color(0xFFFF5F5F)
                                                : const Color(0xFF5FFF95)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  SizedBox(
                                    width: width / 2 - 20 - 31,
                                    child: Text(
                                      e.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF222222)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: width / 2 - 18 - 3 * 18,
                                    child: Text(
                                      e.vendorCode,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF222222)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  e.quantity != null
                                      ? InkWell(
                                          onTap: () async {
                                            final product = await ref
                                                .read(cartDataProvider)
                                                .getProductInfo(data[index].id);
                                            if (product.errorModel != null) {
                                              ref
                                                  .read(deleteAuthProvider)
                                                  .deleteAuth();
                                              Future.microtask(() =>
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AuthPage()),
                                                      (route) => false));
                                            }
                                            if (mounted) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return addToCartModal(
                                                        data[index],
                                                        product.productModel!);
                                                  }).then((value) {
                                                if (value) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    content: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .addedToCart),
                                                  ));
                                                }
                                              });
                                            }
                                          },
                                          child: const Row(
                                            children: [
                                              SizedBox(
                                                width: 18,
                                              ),
                                              Icon(
                                                Icons.add,
                                                color: Color(0xFF303030),
                                                size: 18,
                                              ),
                                              Icon(
                                                Icons.shopping_cart,
                                                color: Color(0xFF303030),
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget getProductGridWidget(List<AssortmentModel> data, double width) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 20),
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isTappedName = true;
                      data.sort((prod1, prod2) => compareString(
                          isAscendingName, prod1.name, prod2.name));
                      isAscendingName = !isAscendingName;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.nameCaps,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFAAAAAA),
                        fontSize: 16),
                  ),
                ),
                isTappedName
                    ? isAscendingName
                        ? const Icon(
                            Icons.arrow_downward,
                            color: Color(0xFFAAAAAA),
                            size: 14,
                          )
                        : const Icon(
                            Icons.arrow_upward,
                            color: Color(0xFFAAAAAA),
                            size: 14,
                          )
                    : Container(),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isTappedVendor = true;
                      data.sort((prod1, prod2) => compareString(
                          isAscendingVendor,
                          prod1.vendorCode,
                          prod2.vendorCode));
                      isAscendingVendor = !isAscendingVendor;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.skuCaps,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFAAAAAA),
                        fontSize: 16),
                  ),
                ),
                isTappedVendor
                    ? isAscendingVendor
                        ? const Icon(
                            Icons.arrow_downward,
                            color: Color(0xFFAAAAAA),
                            size: 14,
                          )
                        : const Icon(
                            Icons.arrow_upward,
                            color: Color(0xFFAAAAAA),
                            size: 14,
                          )
                    : Container()
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
                itemCount: data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.shortestSide > 550 ? 4 : 2,
                    childAspectRatio: 159 / 270,
                    crossAxisSpacing: 30,
                    mainAxisExtent: 270,
                    mainAxisSpacing: 20),
                itemBuilder: (context, index) {
                  final element = data[index];
                  return InkWell(
                    onTap: () async {
                      final availability = await ref
                          .read(getAvailabilityProvider)
                          .getAvailability(element.id);
                      if (availability.errorModel == null) {
                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductInfoPage(
                                      productId: data[index].id,
                                      name: data[index].name,
                                      photos: data[index].fileNames,
                                      sku: data[index].vendorCode,
                                      ean: data[index].eanCode,
                                      count: data[index].quantity ?? 0.0,
                                      availabilityModel:
                                          availability.availabilityModel!,
                                      stockModel: widget.stockModel,
                                      isQr: widget.isTransaction)));
                        } else {
                          ref.read(deleteAuthProvider).deleteAuth();
                          Future.microtask(() => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthPage()),
                              (route) => false));
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        topLeft: Radius.circular(16))),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: CarouselSlider(
                                          items: data[index].fileNames != null
                                              ? data[index].fileNames!.map((e) {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    14),
                                                            topRight:
                                                                Radius.circular(
                                                                    14)),
                                                    child: Image.network(
                                                      "${baseUrl}file/stream/$e",
                                                      width: double.infinity,
                                                      errorBuilder: (context,
                                                          obj, stacktrace) {
                                                        return const Icon(
                                                          Icons.camera_alt,
                                                          color:
                                                              Color(0xFF909090),
                                                        );
                                                      },
                                                      loadingBuilder: (context,
                                                          widget, event) {
                                                        if (event == null) {
                                                          return widget;
                                                        }
                                                        return Center(
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .loading,
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xFF909090)),
                                                          ),
                                                        );
                                                      },
                                                      fit: BoxFit.contain,
                                                    ),
                                                  );
                                                }).toList()
                                              : [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    14),
                                                            topRight:
                                                                Radius.circular(
                                                                    14)),
                                                    child: Image.network(
                                                      "",
                                                      errorBuilder: (context,
                                                              obj,
                                                              stacktrace) =>
                                                          const Icon(
                                                        Icons.camera_alt,
                                                        color:
                                                            Color(0xFF909090),
                                                      ),
                                                      loadingBuilder: (context,
                                                          widget, event) {
                                                        if (event == null) {
                                                          return widget;
                                                        }
                                                        return Center(
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .loading,
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xFF909090)),
                                                          ),
                                                        );
                                                      },
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                ],
                                          options: CarouselOptions(
                                            viewportFraction: 1,
                                            aspectRatio: 1,
                                            onPageChanged: (newIndex, reason) {
                                              setState(() {
                                                data[index].currentIndex =
                                                    newIndex;
                                              });
                                            },
                                          )),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: DotsIndicator(
                                        dotsCount: data[index].fileNames != null
                                            ? data[index].fileNames!.length
                                            : 1,
                                        position: data[index].currentIndex,
                                        decorator: DotsDecorator(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          activeShape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          size: const Size(6, 6),
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 8, bottom: 8, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      element.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      element.vendorCode,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF909090)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  element.quantity == null
                                      ? Text(
                                          AppLocalizations.of(context)!
                                              .notAvailable,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF909090)),
                                        )
                                      : Text(
                                          AppLocalizations.of(context)!
                                              .available,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF058E6E)),
                                        ),
                                  const SizedBox(height: 10),
                                  element.quantity != null
                                      ? InkWell(
                                          onTap: () async {
                                            final product = await ref
                                                .read(cartDataProvider)
                                                .getProductInfo(data[index].id);
                                            if (product.errorModel != null) {
                                              ref
                                                  .read(deleteAuthProvider)
                                                  .deleteAuth();
                                              Future.microtask(() =>
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AuthPage()),
                                                      (route) => false));
                                            }
                                            if (context.mounted) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return addToCartModal(
                                                        data[index],
                                                        product.productModel!);
                                                  }).then((value) {
                                                if (value) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    content: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .addedToCart),
                                                  ));
                                                }
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 20,
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                const Icon(
                                                  Icons.shopping_cart,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 6),
                                                SizedBox(
                                                  width: 90,
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .addToCartCaps,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    ));
  }

  Widget filtersBottomSheet(BuildContext context, double width) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 28, right: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.filtersCaps,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            outlinedGrayButton(() {
                              colorCont.clear();
                              setState(() {
                                filters = {
                                  "name": "",
                                  "availability": true,
                                  "color": "",
                                  "brand": null,
                                  "collection": null,
                                  "category": null
                                };
                              });
                              ref.refresh(getFiltersProvider).value;
                            }, AppLocalizations.of(context)!.clearAllCaps),
                            const SizedBox(
                              width: 18,
                            ),
                            grayButton(() {
                              setState(() {
                                filters["color"] = colorCont.text;
                              });
                              ref.refresh(getAssortmentProvider(filters)).value;
                              Navigator.pop(context);
                            }, AppLocalizations.of(context)!.applyCaps),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFFF6F6F6)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 26, right: 26, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.availability} (${widget.currentStorehouse})",
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF3A3A3A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 223,
                            height: 40,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.1))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 27,
                                  width: 100,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          filters["availability"] = true;
                                        });
                                      },
                                      style: filters["availability"] == true
                                          ? ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              elevation: 0,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              side: BorderSide(
                                                  color: Colors.black
                                                      .withOpacity(0.1)))
                                          : ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              padding: EdgeInsets.zero,
                                            ),
                                      child: Text(
                                        AppLocalizations.of(context)!.available,
                                        style: filters["availability"] == true
                                            ? const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black)
                                            : TextStyle(
                                                fontSize: 16,
                                                color: Colors.black
                                                    .withOpacity(0.3)),
                                      )),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                SizedBox(
                                  height: 27,
                                  width: 100,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          filters["availability"] = false;
                                        });
                                      },
                                      style: filters["availability"] == false
                                          ? ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              elevation: 0,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              side: BorderSide(
                                                  color: Colors.black
                                                      .withOpacity(0.1)))
                                          : ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              padding: EdgeInsets.zero,
                                            ),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .notAvailable,
                                        style: filters["availability"] == false
                                            ? const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black)
                                            : TextStyle(
                                                fontSize: 16,
                                                color: Colors.black
                                                    .withOpacity(0.3)),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 26, right: 26, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.color,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF3A3A3A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              cursorColor: Colors.black,
                              controller: colorCont,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 16),
                                fillColor: const Color(0xFFFBFBFB),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(5)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(5)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(5)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5)),
                                hintText: '',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFFF6F6F6)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 26, right: 26, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.brand,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF3A3A3A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              final TextEditingController brandCont =
                                  TextEditingController();
                              List filteredList = filtersUseCase!.brandModels!;

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return selectFiltersModal(
                                        context,
                                        filteredList,
                                        brandCont,
                                        AppLocalizations.of(context)!.brand,
                                        filtersUseCase!.brandModels!,
                                        width);
                                  }).then((value) => setState(() {
                                    selectedBrands = [];
                                    for (var element
                                        in filtersUseCase!.brandModels!) {
                                      if (element.isSelected) {
                                        selectedBrands.add(element);
                                      }
                                    }
                                    if (selectedBrands
                                        .map((e) => e.id)
                                        .toList()
                                        .isEmpty) {
                                      filters["brand"] = null;
                                    } else {
                                      filters["brand"] = selectedBrands
                                          .map((e) => e.id)
                                          .toList();
                                    }
                                  }));
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFBFBFB),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.1))),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        filters["brand"] == null
                                            ? AppLocalizations.of(context)!
                                                .selectABrand
                                            : selectedBrands
                                                .map((e) => e.name)
                                                .toString()
                                                .substring(
                                                    1,
                                                    selectedBrands
                                                            .map((e) => e.name)
                                                            .toString()
                                                            .length -
                                                        1),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            color: Color(0xFF909090)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 26, right: 26, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.collection,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF3A3A3A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              final TextEditingController collectionCont =
                                  TextEditingController();
                              List filteredList =
                                  filtersUseCase!.collectionModels!;

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return selectFiltersModal(
                                        context,
                                        filteredList,
                                        collectionCont,
                                        AppLocalizations.of(context)!
                                            .collection,
                                        filtersUseCase!.collectionModels!,
                                        width);
                                  }).then((value) => setState(() {
                                    selectedCollections = [];
                                    for (var element
                                        in filtersUseCase!.collectionModels!) {
                                      if (element.isSelected) {
                                        selectedCollections.add(element);
                                      }
                                    }
                                    if (selectedCollections
                                        .map((e) => e.id)
                                        .toList()
                                        .isEmpty) {
                                      filters["collection"] = null;
                                    } else {
                                      filters["collection"] =
                                          selectedCollections
                                              .map((e) => e.id)
                                              .toList();
                                    }
                                  }));
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFBFBFB),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.1))),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        filters["collection"] == null
                                            ? AppLocalizations.of(context)!
                                                .selectACollection
                                            : selectedCollections
                                                .map((e) => e.name)
                                                .toString()
                                                .substring(
                                                    1,
                                                    selectedCollections
                                                            .map((e) => e.name)
                                                            .toString()
                                                            .length -
                                                        1),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            color: Color(0xFF909090)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFFF6F6F6)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 26, right: 26, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.category,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF3A3A3A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              final TextEditingController categoryCont =
                                  TextEditingController();
                              List filteredList =
                                  filtersUseCase!.categoryModels!;

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return selectCategoriesModal(
                                        context,
                                        filteredList,
                                        categoryCont,
                                        AppLocalizations.of(context)!.category,
                                        filtersUseCase!.categoryModels!,
                                        width);
                                  }).then((value) => setState(() {
                                    selectedCategories = [];
                                    for (var element
                                        in filtersUseCase!.categoryModels!) {
                                      if (isSelectedIfChildrenEmpty(element)) {
                                        selectedCategories.add(element);
                                      }
                                      getSelectedChildren(element)
                                          .forEach((element) {
                                        selectedCategories.add(element);
                                      });
                                    }
                                    if (selectedCategories
                                        .map((e) => e.id)
                                        .toList()
                                        .isEmpty) {
                                      filters["category"] = null;
                                    } else {
                                      filters["category"] = selectedCategories
                                          .map((e) => e.id)
                                          .toList();
                                    }
                                  }));
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFBFBFB),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.1))),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        filters["category"] == null
                                            ? AppLocalizations.of(context)!
                                                .selectACategory
                                            : selectedCategories
                                                .map((e) => e.name)
                                                .toString()
                                                .substring(
                                                    1,
                                                    selectedCategories
                                                            .map((e) => e.name)
                                                            .toString()
                                                            .length -
                                                        1),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            color: Color(0xFF909090)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget selectFiltersModal(BuildContext context, List filteredList,
      TextEditingController cont, String title, List models, double width) {
    return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 40,
                          child: TextFormField(
                            controller: cont,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 16),
                              fillColor: const Color(0xFFFBFBFB),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.1)),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3))),
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.1)),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.1)),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3))),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3))),
                              hintText:
                                  AppLocalizations.of(context)!.itemToSearch,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              filteredList = models
                                  .where((model) => model.name
                                      .toLowerCase()
                                      .contains(cont.text.toLowerCase()))
                                  .toList();
                            });
                          },
                          child: Container(
                              height: 40,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF292929),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8))),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 4, bottom: 4),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.searchCaps,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.maxFinite,
                    height: 400,
                    child: ListView(
                      shrinkWrap: true,
                      children: filteredList.mapIndexed((index, element) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              filteredList[index].isSelected =
                                  !models[index].isSelected;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  height: 40,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? const Color(0xFFF6F6F6)
                                          : Colors.white),
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: width - 16 - 36 - 110,
                                            child: Text(
                                              element.name,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          filteredList[index].isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 18,
                                                )
                                              : Container()
                                        ],
                                      ))),
                              const Divider(
                                height: 1,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF3C3C3C),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                        child: Text(
                          AppLocalizations.of(context)!.applyCaps,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white),
                        )),
                  )
                ],
              ),
            ),
          );
        }));
  }

  Widget selectCategoriesModal(BuildContext context, List filteredList,
      TextEditingController cont, String title, List models, double width) {
    return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 40,
                          child: TextFormField(
                            controller: cont,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 16),
                              fillColor: const Color(0xFFFBFBFB),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.1)),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3))),
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.1)),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.1)),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3))),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3))),
                              hintText:
                                  AppLocalizations.of(context)!.itemToSearch,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (cont.text == "") {
                                filteredList = models;
                              } else {
                                filteredList = searchInChildren(
                                    models, cont.text.toLowerCase());
                              }
                            });
                          },
                          child: Container(
                              height: 40,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF292929),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8))),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 4, bottom: 4),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.searchCaps,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                      width: double.maxFinite,
                      height: 400,
                      child: listOfCategories(
                          filteredList, -3, true, null, width)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF3C3C3C),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                        child: Text(
                          AppLocalizations.of(context)!.applyCaps,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white),
                        )),
                  )
                ],
              ),
            ),
          );
        }));
  }

  Widget listOfCategories(List filteredList, double padding, bool isFirst,
      Color? prevColor, double width) {
    padding = padding + 11;
    return StatefulBuilder(builder: (context, setState) {
      return ListView(
        shrinkWrap: true,
        children: filteredList.mapIndexed((index, element) {
          bool isChildren = filteredList[index].children.isNotEmpty;
          bool isOpened = filteredList[index].isOpened;

          return InkWell(
            onTap: () {
              filteredList[index].isSelected = !filteredList[index].isSelected;
              updateCategorySelection(filteredList[index]);
              setState(() {});
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 40,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: isFirst
                            ? index % 2 == 0
                                ? const Color(0xFFF6F6F6)
                                : Colors.white
                            : prevColor),
                    child: Padding(
                        padding: EdgeInsets.only(left: padding, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            isChildren
                                ? InkWell(
                                    onTap: () {
                                      filteredList[index].isOpened =
                                          !filteredList[index].isOpened;
                                      setState(() {});
                                    },
                                    child: Icon(
                                      filteredList[index].isOpened
                                          ? Icons.arrow_drop_down
                                          : Icons.arrow_right,
                                      size: 18,
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              width: width - padding - 44 - 18 - 110,
                              child: Text(
                                element.name,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            filteredList[index].isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 18,
                                  )
                                : Container()
                          ],
                        ))),
                isChildren
                    ? isOpened
                        ? listOfCategories(
                            filteredList[index].children,
                            padding + 11,
                            false,
                            isChildren
                                ? isFirst
                                    ? index % 2 == 0
                                        ? const Color(0xFFF6F6F6)
                                        : Colors.white
                                    : prevColor
                                : prevColor,
                            width)
                        : Container()
                    : Container(),
                isFirst
                    ? const Divider(
                        height: 1,
                      )
                    : Container(),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  bool isSelectedIfChildrenEmpty(CategoryModel category) {
    if (category.children.isEmpty) {
      return category.isSelected;
    }

    bool allChildrenSelected =
        category.children.every(isSelectedIfChildrenEmpty);

    category.isSelected = allChildrenSelected;

    return allChildrenSelected;
  }

  List<CategoryModel> getSelectedChildren(CategoryModel category) {
    List<CategoryModel> selectedChildren = [];

    void traverse(CategoryModel category) {
      if (category.isSelected) {
        selectedChildren.add(category);
      }

      for (var child in category.children) {
        traverse(child);
      }
    }

    traverse(category);

    return selectedChildren;
  }

  void updateCategorySelection(CategoryModel category) {
    if (category.children.isNotEmpty && category.isSelected) {
      for (var child in category.children) {
        child.isSelected = true;
        updateCategorySelection(child);
      }
    }

    if (category.children.isNotEmpty && !category.isSelected) {
      for (var child in category.children) {
        child.isSelected = false;
        updateCategorySelection(child);
      }
    }
  }

  List<CategoryModel> searchInChildren(List categories, String searchText) {
    List<CategoryModel> results = [];

    void searchInChildCategories(CategoryModel category) {
      for (var child in category.children) {
        if (child.name.toLowerCase().contains(searchText.toLowerCase())) {
          results.add(child);
        }
        searchInChildCategories(child);
      }
    }

    for (var category in categories) {
      searchInChildCategories(category);
    }

    return results;
  }

  void resetSelection(List<CategoryModel> categories) {
    void resetChildrenSelection(CategoryModel category) {
      category.isSelected = false;
      category.isOpened = false;
      for (var child in category.children) {
        resetChildrenSelection(child);
      }
    }

    for (var category in categories) {
      resetChildrenSelection(category);
    }
  }

  int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  Widget cartBottomSheet(double width) {
    List<CartModel> data = ref.watch(cartDataProvider).cartData;
    double sum = ref.watch(cartDataProvider).sum;

    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 28, right: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.cartCaps,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          outlinedGrayButton(() {
                            Navigator.pop(context);
                          }, AppLocalizations.of(context)!.backCaps),
                          const SizedBox(
                            width: 18,
                          ),
                          grayButton(() {
                            if (ref.watch(cartDataProvider).transactionId !=
                                    null &&
                                ref
                                    .watch(cartDataProvider)
                                    .cartData
                                    .isNotEmpty) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return exitDialog(
                                        context,
                                        AppLocalizations.of(context)!
                                            .areYouSureCart);
                                  }).then((returned) {
                                if (returned) {
                                  ref.read(cartDataProvider).startAssembly();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AssemblingPage(
                                                transactionId: ref
                                                    .watch(cartDataProvider)
                                                    .transactionId!,
                                                cartData: ref
                                                    .watch(cartDataProvider)
                                                    .cartData,
                                                isTransaction:
                                                    widget.isTransaction,
                                                stockModel: widget.stockModel,
                                              )));
                                }
                              });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.transparent,
                                      title: Text(AppLocalizations.of(context)!
                                          .youHaventCart),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text(
                                              "Ok",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ))
                                      ],
                                    );
                                  });
                            }
                          }, AppLocalizations.of(context)!.startAssemblyCaps),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 30,
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.nameCaps,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.quantityCaps,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          AppLocalizations.of(context)!.priceCaps,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  height: 220,
                  child: ListView(
                    shrinkWrap: true,
                    children: data.mapIndexed((index, element) {
                      final TextEditingController quantityCont =
                          TextEditingController(
                              text: data[index].quantity.toString());

                      quantityCont.selection = TextSelection.fromPosition(
                          TextPosition(offset: quantityCont.text.length));

                      return InkWell(
                        onTap: () async {
                          final product = await ref
                              .read(cartDataProvider)
                              .getProductInfo(data[index].model.id);
                          if (product.errorModel != null) {
                            ref.read(deleteAuthProvider).deleteAuth();
                            Future.microtask(() => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AuthPage()),
                                (route) => false));
                          }
                          if (context.mounted) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return editCartModal(
                                      data[index], product.productModel!);
                                }).then((value) {
                              ref.read(cartDataProvider).getSum();
                              setState(() {
                                sum = ref.watch(cartDataProvider).sum;
                              });
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: index % 2 == 0
                                  ? const Color(0xFFF6F6F6)
                                  : Colors.white),
                          width: double.maxFinite,
                          height: 74,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    data[index].model.name,
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFF3A3A3A)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      data[index].quantity.toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF3A3A3A)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      (data[index].curPrice).toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF3A3A3A)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "${AppLocalizations.of(context)!.total} ${sum.toString()}",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget addToCartModal(AssortmentModel data, ProductInfoModel productInfo) {
    final TextEditingController quantityCont = TextEditingController();
    final pricesData = {
      "Distribution": productInfo.distributionPrice,
      "Professional": productInfo.professionalPrice,
      "Oferta": productInfo.offertaPrice
    };
    String curPrice = "Distribution";

    return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)!.cartItemEditCaps,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.product} \"${data.name}\"",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222)),
                ),
                const Divider(),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.quantityCaps,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF3A3A3A)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (quantityCont.text != "" &&
                                  int.parse(quantityCont.text) > 1) {
                                quantityCont.text =
                                    (int.parse(quantityCont.text) - 1)
                                        .toString();
                              }
                              setState(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF3C3C3C),
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Center(
                                  child: Text(
                                "-",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    height: 1,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: TextFormField(
                              controller: quantityCont,
                              cursorColor: Colors.black,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                fillColor: const Color(0xFFFCFCFC),
                                border: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                disabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                hintText:
                                    AppLocalizations.of(context)!.countCaps,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () {
                              if (quantityCont.text == "") {
                                quantityCont.text = "1";
                              } else {
                                if (int.parse(quantityCont.text) <
                                    data.quantity!) {
                                  quantityCont.text =
                                      (int.parse(quantityCont.text) + 1)
                                          .toString();
                                }
                              }
                              setState(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF3C3C3C),
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Center(
                                  child: Text(
                                "+",
                                style: TextStyle(
                                    color: Colors.white,
                                    height: 1,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.priceCaps,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF3A3A3A)),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton(
                        value: curPrice,
                        items: [
                          const DropdownMenuItem(
                            value: "Distribution",
                            child: Text("Distribution"),
                          ),
                          const DropdownMenuItem(
                            value: "Professional",
                            child: Text("Professional"),
                          ),
                          DropdownMenuItem(
                            value: "Oferta",
                            enabled: productInfo.offertaPrice != 0.0,
                            child: Text("Oferta",
                                style: TextStyle(
                                  color: productInfo.offertaPrice != 0.0
                                      ? Colors.black
                                      : const Color(0xFF969696),
                                )),
                          ),
                        ],
                        onChanged: (Object? value) {
                          setState(() {
                            curPrice = value.toString();
                          });
                        },
                      ),
                      Container(
                        width: 195,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFCFCFC),
                            border: Border.all(color: const Color(0xFFC8C8C8)),
                            borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: Text(
                              quantityCont.text == ""
                                  ? pricesData[curPrice].toString()
                                  : (pricesData[curPrice]! *
                                          int.parse(quantityCont.text))
                                      .toString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          outlinedGrayButton(() {
                            Navigator.pop(context, false);
                          }, AppLocalizations.of(context)!.cancelCaps),
                          const SizedBox(
                            width: 18,
                          ),
                          grayButton(() {
                            if (int.parse(quantityCont.text) > data.quantity!) {
                              ref.read(cartDataProvider).addToCart(
                                  CartModel(
                                      data,
                                      data.quantity!.toInt(),
                                      {curPrice: pricesData[curPrice]!},
                                      pricesData[curPrice]! *
                                          int.parse(quantityCont.text)),
                                  widget.storehouseId);

                              Navigator.pop(context, true);
                            } else {
                              ref.read(cartDataProvider).addToCart(
                                  CartModel(
                                      data,
                                      int.parse(quantityCont.text),
                                      {curPrice: pricesData[curPrice]!},
                                      pricesData[curPrice]! *
                                          int.parse(quantityCont.text)),
                                  widget.storehouseId);
                              ref.read(cartDataProvider).getSum();
                              Navigator.pop(context, true);
                            }
                          }, AppLocalizations.of(context)!.saveCaps),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }));
  }

  Widget editCartModal(CartModel data, ProductInfoModel productInfo) {
    final TextEditingController quantityCont =
        TextEditingController(text: data.quantity.toString());

    final pricesData = {
      "Distribution": productInfo.distributionPrice,
      "Professional": productInfo.professionalPrice,
      "Oferta": productInfo.offertaPrice
    };
    String curPrice = data.priceType.keys.first.toString();

    return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(6),
        title: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.shortestSide > 650 ? 400 : 200,
              child: Text(
                AppLocalizations.of(context)!.cartItemEditCaps,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 18,
            ),
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          title: Text(
                            AppLocalizations.of(context)!.deletionCaps,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF151515)),
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data.model.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Divider(),
                              Text(
                                "${AppLocalizations.of(context)!.sureDelete} ${data.model.name}?",
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF3A3A3A)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  outlinedGrayButton(() {
                                    Navigator.pop(context, false);
                                  }, AppLocalizations.of(context)!.cancelCaps),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      ref.read(cartDataProvider).deleteFromCart(
                                          data, widget.storehouseId);
                                      ref.read(cartDataProvider).getSum();
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFFF5F5F),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 4,
                                              bottom: 4),
                                          child: Center(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .deleteCaps,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        )),
                                  )
                                ],
                              )
                            ],
                          ),
                        )).then((value) {
                  Navigator.pop(context);
                  setState(() {});
                });
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF5F5F),
                      borderRadius: BorderRadius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 4, bottom: 4),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.deleteCaps,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            )
          ],
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.product} \"${data.model.name}\"",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222)),
                ),
                const Divider(),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.quantityCaps,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF3A3A3A)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (quantityCont.text != "" &&
                                  int.parse(quantityCont.text) > 1) {
                                quantityCont.text =
                                    (int.parse(quantityCont.text) - 1)
                                        .toString();
                              }
                              setState(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF3C3C3C),
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Center(
                                  child: Text(
                                "-",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    height: 1,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: TextFormField(
                              controller: quantityCont,
                              cursorColor: Colors.black,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                fillColor: const Color(0xFFFCFCFC),
                                border: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                disabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                hintText:
                                    AppLocalizations.of(context)!.countCaps,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () {
                              if (quantityCont.text == "") {
                                quantityCont.text = "1";
                              } else {
                                if (int.parse(quantityCont.text) <
                                    data.model.quantity!) {
                                  quantityCont.text =
                                      (int.parse(quantityCont.text) + 1)
                                          .toString();
                                }
                              }
                              setState(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF3C3C3C),
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Center(
                                  child: Text(
                                "+",
                                style: TextStyle(
                                    color: Colors.white,
                                    height: 1,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.priceCaps,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF3A3A3A)),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton(
                        value: curPrice,
                        items: [
                          const DropdownMenuItem(
                            value: "Distribution",
                            child: Text("Distribution"),
                          ),
                          const DropdownMenuItem(
                            value: "Professional",
                            child: Text("Professional"),
                          ),
                          DropdownMenuItem(
                            value: "Oferta",
                            enabled: productInfo.offertaPrice != 0.0,
                            child: Text(
                              "Oferta",
                              style: TextStyle(
                                  color: productInfo.offertaPrice != 0.0
                                      ? Colors.black
                                      : const Color(0xFF969696)),
                            ),
                          ),
                        ],
                        onChanged: (Object? value) {
                          setState(() {
                            curPrice = value.toString();
                          });
                        },
                      ),
                      Container(
                        width: 195,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFCFCFC),
                            border: Border.all(color: const Color(0xFFC8C8C8)),
                            borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: Text(
                              quantityCont.text == ""
                                  ? pricesData[curPrice].toString()
                                  : (pricesData[curPrice]! *
                                          int.parse(quantityCont.text))
                                      .toString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          outlinedGrayButton(() {
                            Navigator.pop(context, false);
                          }, AppLocalizations.of(context)!.cancelCaps),
                          const SizedBox(
                            width: 18,
                          ),
                          grayButton(() {
                            data.priceType = {curPrice: pricesData[curPrice]};
                            data.curPrice = pricesData[curPrice]! *
                                int.parse(quantityCont.text);
                            if (int.parse(quantityCont.text) >
                                data.model.quantity!) {
                              ref.read(cartDataProvider).updateCartModel(
                                  data,
                                  false,
                                  data.model.quantity!.toInt(),
                                  widget.storehouseId);
                              Navigator.pop(context, true);
                            } else {
                              ref.read(cartDataProvider).updateCartModel(
                                  data,
                                  false,
                                  int.parse(quantityCont.text),
                                  widget.storehouseId);
                              ref.read(cartDataProvider).getSum();
                              Navigator.pop(context, true);
                            }
                          }, AppLocalizations.of(context)!.saveCaps),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }));
  }
}
