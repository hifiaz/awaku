import 'package:awaku/src/bike/bike_view.dart';
import 'package:awaku/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

import 'home_item.dart';

class HomeItemListView extends ConsumerStatefulWidget {
  const HomeItemListView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  ConsumerState<HomeItemListView> createState() => _HomeItemListViewState();
}

class _HomeItemListViewState extends ConsumerState<HomeItemListView> {
  final _watch = WatchConnectivity();

  var _paired = false;
  final _log = <HeartRateModel>[];

  @override
  void initState() {
    super.initState();

    _watch.contextStream
        .listen((e) => setState(() => _log.add(HeartRateModel.fromJson(e))));

    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello'),
        // title: Text(AppLocalizations.of(context)!.appTitle),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              context.push('/setting');
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const AppleWatch()),
              // );
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_paired)
                    Row(
                      children: [
                        Text(
                          _log.isEmpty ? '' : '${_log.last.heartRate}',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.favorite,
                                size: 20, color: Colors.pink),
                            Text(
                              'BPM',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ],
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Text(
                        '56',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.monitor_weight_outlined,
                              size: 20, color: Colors.green),
                          Text(
                            'KG',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        calculateBodyMassIndex(78, 168).toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          calculateBodyMassIndex(78, 168) >= 25
                              ? const Icon(Icons.arrow_outward,
                                  size: 20, color: Colors.red)
                              : const Icon(Icons.arrow_forward,
                                  size: 20, color: Colors.green),
                          Text(
                            'BMI',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () => context.push('/setting/add-device'),
                      icon: const Icon(Icons.add)),
                ],
              ),
            ),
            FutureBuilder(
              future: FTMS.listDevices(),
              builder: (c, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (c, index) {
                      BluetoothDevice b = snapshot.data![index];
                      return FutureBuilder<bool>(
                        future: FTMS.isBluetoothDeviceFTMSDevice(b),
                        builder: (context, snapshot) => (snapshot.data ?? false)
                            ? ListTile(
                                title: Text(b.localName),
                                trailing: const Icon(Icons.arrow_right),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BikeView(ftmsDevice: b),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
            ListTile(
              title: const Text('History'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'HomeItemListView',
              itemCount: widget.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = widget.items[index];

                return ListTile(
                    title: Text('SampleItem ${item.id}'),
                    leading: const CircleAvatar(
                      // Display the Flutter Logo image asset.
                      foregroundImage:
                          AssetImage('assets/images/flutter_logo.png'),
                    ),
                    onTap: () => context.push('/detail'));
              },
            ),
          ],
        ),
      ),
    );
  }

  void initPlatformState() async {
    _paired = await _watch.isPaired;
    setState(() {});
  }
}
