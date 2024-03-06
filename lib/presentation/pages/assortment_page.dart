import 'package:collection/collection.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/models/assortment_model.dart';
import 'package:mobile_app_slb/presentation/pages/auth_page.dart';
import 'package:mobile_app_slb/presentation/states/auth_state.dart';
import 'package:mobile_app_slb/presentation/widgets/app_drawer.dart';
import 'package:mobile_app_slb/presentation/widgets/backButton.dart';
import 'package:mobile_app_slb/utils/constants.dart' as constants;

import '../states/assortment_state.dart';

class AssortmentPage extends ConsumerStatefulWidget {
  const AssortmentPage({super.key});

  @override
  ConsumerState<AssortmentPage> createState() => _AssortmentPageState();
}

class _AssortmentPageState extends ConsumerState<AssortmentPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchCont = TextEditingController();
  bool isGrid = false;
  int? sortColumnIndex;
  bool isAscending = false;
  Map<String, dynamic> filters = {"name": ""};
  String baseUrl = constants.baseUrl;

  Future<bool> delay() async {
    await Future.delayed(const Duration(milliseconds: 500))
        .then((value) => true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: const AppDrawer(),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: Color(0xFFD9D9D9), width: 1))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/assortment_filter_icon.png",
                    scale: 4,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              InkWell(
                onTap: () {
                  ref.read(getAvailabilityProvider).changeSearchingState();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/assortment_search_icon.png",
                      scale: 4,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Search",
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: delay(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              }
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 40, right: 40, left: 40, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                backButton(() => Navigator.pop(context)),
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
                            const Spacer(),
                            const Text(
                              "ASSORTMENT",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFF909090),
                                  height: 0.5),
                            ),
                            const Text(
                              "Storehouse name",
                              style: TextStyle(
                                  fontSize: 36,
                                  color: Color(0xFF363636),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          ref.watch(getAvailabilityProvider).isSearching
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
                                            cursorColor: Colors.black,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              fillColor:
                                                  const Color(0xFFFCFCFC),
                                              border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFFCFCFCF)),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              prefixIcon: const Icon(
                                                Icons.search,
                                                color: Color(0xFF5F5F5F),
                                              ),
                                              hintText: 'Search',
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
                                                FocusManager
                                                    .instance.primaryFocus
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
                                                  padding: EdgeInsets.zero,
                                                  elevation: 0,
                                                  backgroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "VIEW",
                                      style: TextStyle(
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
                                              .withOpacity(isGrid ? 0.3 : 1)),
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
                                              .withOpacity(!isGrid ? 0.3 : 1)),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 8),
                          const Divider(
                            height: 1,
                          ),
                          ref.watch(getAssortmentProvider(filters)).when(
                              data: (value) {
                                if (value.assortmentModel != null &&
                                    value.errorModel == null) {
                                  ThemeData theme = Theme.of(context);
                                  final items = value.assortmentModel!;

                                  int compareString(bool ascending,
                                          String value1, String value2) =>
                                      ascending
                                          ? value1.compareTo(value2)
                                          : value2.compareTo(value1);

                                  void onSort(int columnIndex, bool ascending) {
                                    if (columnIndex == 0) {
                                      items.sort((prod1, prod2) =>
                                          compareString(ascending, prod1.name,
                                              prod2.name));
                                    } else if (columnIndex == 1) {
                                      items.sort((prod1, prod2) =>
                                          compareString(
                                              ascending,
                                              prod1.vendorCode,
                                              prod2.vendorCode));
                                    }

                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      isAscending = ascending;
                                    });
                                  }

                                  if (isGrid) {
                                    return getProductGridWidget(
                                        value.assortmentModel!);
                                  } else {
                                    return getProductListWidget(
                                        theme, onSort, value.assortmentModel!);
                                  }
                                }
                                if (value.errorModel!.statusCode == 401) {
                                  ref
                                      .read(deleteAuthProvider)
                                      .deleteAuth()
                                      .then((value) {
                                    Future.microtask(() =>
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AuthPage()),
                                            (route) => false));
                                  });

                                  return Container();
                                }
                                return AlertDialog(
                                  title: Text(value.errorModel!.statusText),
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
            }),
      ),
    );
  }

  Future<void> getAvailability(AssortmentModel e, BuildContext context) async {
    final data = await ref.read(getAvailabilityProvider).getAvailability(e.id);
    if (data.availabilityModel != null && data.errorModel == null) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                title: const Text(
                  "IN STOCK",
                  style: TextStyle(fontSize: 24),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6F6F6F),
                        ),
                        children: <TextSpan>[
                          TextSpan(text: e.name),
                          const TextSpan(
                              text: ' is in stock in this storehouses',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: data.availabilityModel!
                                  .mapIndexed((index, e) => Column(
                                        children: [
                                          const Divider(
                                            height: 1,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 6),
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.name,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      e.address,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Color(
                                                              0xFF969696)),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          index ==
                                                  data.availabilityModel!
                                                          .length -
                                                      1
                                              ? const Divider(
                                                  height: 1,
                                                )
                                              : Container()
                                        ],
                                      ))
                                  .toList(),
                            ),
                          ),
                          const Spacer(),
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
                                        borderRadius:
                                            BorderRadius.circular(4))),
                                child: const Text(
                                  "BACK",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.white),
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            });
      }
    } else {
      if (data.errorModel!.statusCode == 401) {
        ref.read(deleteAuthProvider).deleteAuth().then((value) {
          Future.microtask(() => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthPage()),
              (route) => false));
        });
      } else {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(data.errorModel!.statusText),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Ok"))
                    ],
                  ));
        }
      }
    }
  }

  Widget getProductListWidget(ThemeData theme, void Function(int, bool) onSort,
      List<AssortmentModel> data) {
    return Expanded(
      child: Theme(
        data: theme.copyWith(
            iconTheme: theme.iconTheme.copyWith(color: Colors.white)),
        child: DataTable2(
            sortAscending: isAscending,
            sortColumnIndex: sortColumnIndex,
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => const Color(0xFF272727)),
            border: const TableBorder(
                verticalInside: BorderSide(
                    width: 2,
                    style: BorderStyle.solid,
                    color: Color(0xFFD9D9D9))),
            columns: [
              DataColumn2(
                  label: const Center(
                    child: Text(
                      "NAME",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ),
                  onSort: onSort),
              DataColumn2(
                  label: const Center(
                    child: Text(
                      "SKU",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ),
                  onSort: onSort)
            ],
            rows: data.mapIndexed((index, e) {
              return DataRow(
                  color: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (index % 2 == 0) {
                      return const Color(0xFFF9F9F9);
                    }
                    return Colors.white;
                  }),
                  cells: [
                    DataCell(
                        onTap: e.quantity == null
                            ? () async {
                                await getAvailability(e, context);
                              }
                            : null,
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: const Color(0xFFDFDFDF)),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: e.quantity == null
                                          ? const Color(0xFFFF5F5F)
                                          : const Color(0xFF5FFF95)),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Text(
                              e.name,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF222222)),
                            )
                          ],
                        )),
                    DataCell(
                        onTap: e.quantity == null
                            ? () async {
                                await getAvailability(e, context);
                              }
                            : null,
                        Text(e.vendorCode,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF222222)))),
                  ]);
            }).toList()),
      ),
    );
  }

  Widget getProductGridWidget(List<AssortmentModel> data) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
      child: GridView.builder(
          itemCount: data.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 159 / 240,
              crossAxisSpacing: 36,
              mainAxisSpacing: 20),
          itemBuilder: (context, index) {
            final element = data[index];
            return InkWell(
              onTap: element.quantity == null
                  ? () async {
                      await getAvailability(element, context);
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14)),
                          child: Image.network(
                            "$baseUrl/file/stream/${element.fileName}",
                            errorBuilder: (context, obj, stacktrace) =>
                                const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF909090),
                            ),
                            loadingBuilder: (context, widget, event) {
                              if (event == null) return widget;
                               return const Center(
                              child: Text(
                                "Loading...",
                                style: TextStyle(color: Color(0xFF909090)),
                              ),
                            );},
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              element.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              element.vendorCode,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF909090)),
                            ),
                            element.quantity == null
                                ? const Text(
                                    "Not available",
                                    style: TextStyle(
                                        fontSize: 13, color: Color(0xFF909090)),
                                  )
                                : const Text(
                                    "Available",
                                    style: TextStyle(
                                        fontSize: 13, color: Color(0xFF058E6E)),
                                  )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    ));
  }
}
