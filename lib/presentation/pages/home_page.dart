import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/assortment_page.dart';
import 'package:mobile_app_slb/presentation/pages/bulk_page.dart';
import 'package:mobile_app_slb/presentation/pages/newarrival_page.dart';
import 'package:mobile_app_slb/presentation/pages/newsale_page.dart';
import 'package:mobile_app_slb/presentation/states/bulk_state.dart';
import 'package:mobile_app_slb/presentation/states/home_state.dart';
import 'package:mobile_app_slb/presentation/widgets/app_drawer.dart';
import 'package:mobile_app_slb/presentation/widgets/home_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../states/auth_state.dart';
import '../states/network_state.dart';
import 'auth_page.dart';
import 'nonetwork_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(timeProvider).updatePeriodic(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var networkStatus = context.read<NetworkService>();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).size.shortestSide > 650
              ? const TextScaler.linear(1.1)
              : const TextScaler.linear(1.0)),
      child: ref.watch(getHomeProvider).when(
          data: (value) {
            if (value.errorModel == null && value.stockModel != null) {
              return Scaffold(
                key: scaffoldKey,
                drawer: AppDrawer(
                  isAbleToNavigate: true,
                  isAssembly: false,
                  isHomePage: true,
                  stockModel: value.stockModel!,
                ),
                body: StreamBuilder(
                    stream: networkStatus.controller.stream,
                    builder: (context, snapshot) {
                      if (snapshot.data == NetworkStatus.offline) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NoNetworkPage()),
                              (route) => false);
                        });
                      }
                      return SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 60),
                                      child: Image.asset(
                                        "assets/images/logo.png",
                                        scale: 4,
                                      ),
                                    ),
                                  ),
                                  Builder(builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 30),
                                      child: InkWell(
                                        onTap: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF3C3C3C),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: const Icon(
                                            Icons.menu,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                ],
                              ),
                            ),
                            const Divider(),
                            Expanded(
                                flex: 3,
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30,
                                        right: 30,
                                        top: 10,
                                        bottom: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ref.watch(timeProvider).spainTime,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFFCACACA)),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .currentStorehouse,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Color(0xFF909090),
                                          ),
                                        ),
                                        Text(
                                          value.stockModel!.name,
                                          style: const TextStyle(
                                              fontSize: 36,
                                              color: Color(0xFF363636),
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ))),
                            const Divider(),
                            Expanded(
                                flex: 7,
                                child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: 4,
                                    padding: const EdgeInsets.all(25),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 25,
                                            mainAxisSpacing: 25,
                                            mainAxisExtent: 138),
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return homeCard(
                                            "assets/images/boxes_icon.png",
                                            AppLocalizations.of(context)!
                                                .assortment, () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      AssortmentPage(
                                                        currentStorehouse: value
                                                            .stockModel!.name,
                                                        stockModel:
                                                            value.stockModel!,
                                                      )));
                                        });
                                      } else if (index == 1) {
                                        return Opacity(
                                          opacity:
                                              value.stockModel!.salesManaging
                                                  ? 1.0
                                                  : 0.0,
                                          child: homeCard(
                                              "assets/images/calculator_icon.png",
                                              AppLocalizations.of(context)!
                                                  .newSale,
                                              value.stockModel!.salesManaging
                                                  ? () {
                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (builder) =>
                                                                          NewSalePage(
                                                                            currentStorehouse:
                                                                                value.stockModel!.name,
                                                                            storehouseId:
                                                                                value.stockModel!.id,
                                                                            isTransaction:
                                                                                false,
                                                                            stockModel:
                                                                                value.stockModel!,
                                                                          )),
                                                              (route) => false);
                                                    }
                                                  : () {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        content: Text(
                                                            "You don't have access to this tab"),
                                                      ));
                                                    }),
                                        );
                                      } else if (index == 2) {
                                        return Opacity(
                                          opacity:
                                              value.stockModel!.salesManaging
                                                  ? 1.0
                                                  : 0.0,
                                          child: homeCard(
                                              "assets/images/bulk_icon.png",
                                              AppLocalizations.of(context)!
                                                  .bulkAssembling,
                                              value.stockModel!.salesManaging
                                                  ? () {
                                                      ref
                                                          .refresh(
                                                              getBulkProvider)
                                                          .value;
                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (builder) =>
                                                                          BulkPage(
                                                                            currentStorehouse:
                                                                                value.stockModel!.name,
                                                                            stockModel:
                                                                                value.stockModel!,
                                                                          )),
                                                              (route) => false);
                                                    }
                                                  : () {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        content: Text(
                                                            "You don't have access to this tab"),
                                                      ));
                                                    }),
                                        );
                                      } else {
                                        return Opacity(
                                          opacity:
                                              value.stockModel!.arrivalsManaging
                                                  ? 1.0
                                                  : 0.0,
                                          child: homeCard(
                                              "assets/images/monitor_icon.png",
                                              AppLocalizations.of(context)!
                                                  .newArrival,
                                              value.stockModel!.arrivalsManaging
                                                  ? () {
                                                Navigator
                                                    .pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder:
                                                            (builder) =>
                                                            NewArrivalPage(
                                                              stockModel:
                                                              value.stockModel!,
                                                            )),
                                                        (route) => false);
                                              }
                                                  : () {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        content: Text(
                                                            "You don't have access to this tab"),
                                                      ));
                                                    }),
                                        );
                                      }
                                    })),
                          ],
                        ),
                      );
                    }),
              );
            } else {
              ref.read(deleteAuthProvider).deleteAuth();
              Future.microtask(() => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                  (route) => false));

              return Scaffold(body: Container());
            }
          },
          error: (error, stacktrace) {
            return Scaffold(
              body: AlertDialog(
                title: Text(error.toString()),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context)!.ok))
                ],
              ),
            );
          },
          loading: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              )),
    );
  }
}
