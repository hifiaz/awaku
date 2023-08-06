import 'package:awaku/service/model/heart_rate_model.dart';
import 'package:awaku/service/provider/devices_provider.dart';
import 'package:awaku/service/provider/health_provider.dart';
import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/src/bike/bike_view.dart';
import 'package:awaku/utils/constants.dart';
import 'package:awaku/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  static const routeName = '/';

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
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
    final profile = ref.watch(fetchUserProvider);
    final healthData = ref.watch(healthNotifierProvider);
    final devices = ref.watch(getDevicesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${profile.value?.name ?? ''}'),
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => context.push('/setting')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(getDevicesProvider);
          return ref.read(fetchUserProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          '${profile.value?.weight ?? '0'}',
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
                          calculateBodyMassIndex(profile.value?.weight ?? 0,
                                  profile.value?.height ?? 0)
                              .toStringAsFixed(1),
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
              devices.when(
                data: (data) {
                  if (data.isEmpty) return const SizedBox();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (c, index) {
                      BluetoothDevice b = data[index];
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
                },
                error: (error, stackTrace) => Text('$stackTrace'),
                loading: () => const Center(
                  child: Text('Loading...'),
                ),
              ),
              if (profile.value?.waterEnable ?? true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80.0,
                        height: 80.0,
                        child: LiquidCircularProgressIndicator(
                          value: 20 / 100,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation(Colors.blue),
                          center: Text(
                            "${(20).round()}%",
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ListTile(
                          title: const Text('Dehidration Rate'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Drink minimum ${(20).toStringAsFixed(1)} L/day',
                              ),
                              Text(
                                'Tap to add Water',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.blue),
                              )
                            ],
                          ),
                          onTap: addWater,
                        ),
                      )
                    ],
                  ),
                ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.history),
              ),
              healthData.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    restorationId: 'HomeView',
                    itemCount: data.length,
                    itemBuilder: (_, index) {
                      HealthDataPoint p = data[index];
                      return ListTile(
                        title: Text("${p.typeString}: ${p.value}"),
                        trailing: Text(p.unitString),
                        subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
                      );
                    },
                  );
                },
                error: (e, __) => Center(child: Text('Something Wrong $__')),
                loading: () => const Center(
                  child: Text('Loading...'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initPlatformState() async {
    _paired = await _watch.isPaired;
    setState(() {});
  }

  int _selectedWater = 0;
  void addWater() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await ref
                        .read(healthProvider)
                        .addDataHealth(water: waterParser(_selectedWater));
                    // ref.invalidate(waterNotifierProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Successfully updated water!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ));
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
              SizedBox(
                height: 150,
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  // This sets the initial item.
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedWater,
                  ),
                  // This is called when selected item is changed.
                  onSelectedItemChanged: (int selectedItem) {
                    setState(() {
                      _selectedWater = selectedItem;
                    });
                  },
                  children:
                      List<Widget>.generate(waterNames.length, (int index) {
                    return Center(child: Text(waterNames[index]));
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
