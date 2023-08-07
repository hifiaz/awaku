import 'package:awaku/service/model/heart_rate_model.dart';
import 'package:awaku/service/model/profile_model.dart';
import 'package:awaku/service/provider/devices_provider.dart';
import 'package:awaku/service/provider/fasting_provider.dart';
import 'package:awaku/service/provider/health_provider.dart';
import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/service/stop_watch_service.dart';
import 'package:awaku/src/bike/bike_view.dart';
import 'package:awaku/utils/constants.dart';
import 'package:awaku/utils/extensions.dart';
import 'package:awaku/utils/validator.dart';
import 'package:awaku/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
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
    final profile = ref.watch(fetchUserProvider).valueOrNull;
    final healthData = ref.watch(healthNotifierProvider);
    final devices = ref.watch(getDevicesProvider);
    final water = ref.watch(currentHydrationProvider).valueOrNull;
    final start = ref.watch(startFastingProvider);
    final fasting = ref.watch(selectedFastingProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${profile?.name ?? ''}'),
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
          ref.invalidate(healthNotifierProvider);
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
                            _log.isEmpty ? '-' : '${_log.last.heartRate}',
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
                    GestureDetector(
                      onTap: () {
                        weight = TextEditingController(
                            text: '${profile?.weight ?? 0}');
                        _showWeightDialog(context, profile);
                      },
                      child: Row(
                        children: [
                          Text(
                            '${profile?.weight ?? '0'}',
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
                    ),
                    Row(
                      children: [
                        Text(
                          calculateBodyMassIndex(
                                  profile?.weight ?? 0, profile?.height ?? 0)
                              .toStringAsFixed(1),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            calculateBodyMassIndex(profile?.weight ?? 0,
                                        profile?.height ?? 0) >=
                                    25
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
              if (profile?.waterEnable ?? true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80.0,
                        height: 80.0,
                        child: LiquidCircularProgressIndicator(
                          value: (water ?? 0) / 100,
                          backgroundColor: Colors.blue[50],
                          valueColor: const AlwaysStoppedAnimation(Colors.blue),
                          center: Text(
                            // "${(0).round()}%",
                            "${(water ?? 0).round()}%",
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
                                'Drink minimum ${totalWater(profile?.weight).toStringAsFixed(1)} L/day',
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
              if (profile?.fastingEnable ?? true)
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.local_dining),
                        title: Text('Eating periode',
                            style: Theme.of(context).textTheme.titleLarge),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 15,
                        ),
                        onTap: () => context.push('/fasting'),
                      ),
                      if (start)
                        StreamBuilder<int>(
                          stream: stopWatchTimer.rawTime,
                          initialData: stopWatchTimer.rawTime.value,
                          builder: (context, snap) {
                            final value = snap.data!;
                            final displayTime = StopWatchTimer.getDisplayTime(
                                value,
                                hours: true);
                            return Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    displayTime,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomButton(
                          backgroundColor: Colors.blue,
                          width: double.infinity,
                          isDisabled: false,
                          title: start ? 'End fasting' : 'Start fasting',
                          onPressed: () {
                            if (fasting == null) {
                              context.push('/fasting');
                            } else {
                              if (stopWatchTimer.isRunning) {
                                _showEndDialog(context);
                              } else {
                                stopWatchTimer.clearPresetTime();
                                stopWatchTimer
                                    .setPresetHoursTime(fasting.start);
                                stopWatchTimer.onStartTimer();
                                ref
                                    .read(startFastingProvider.notifier)
                                    .set(true);
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10)
                    ],
                  ),
                )
              else
                const SizedBox(height: 20),
              ListTile(
                title: Text(AppLocalizations.of(context)!.history),
                subtitle: const Text('Recorded to Health app'),
                trailing: const Text('in 24 Hours'),
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
                        title: Text(
                            "${p.typeString}: ${double.parse(p.value.toString()).toStringAsFixed(2)}"),
                        trailing: Text(p.unitString),
                        subtitle: Text(checkTypeData(p.typeString)
                            ? formatWithTime12H.format(p.dateTo)
                            : '${formatWithTime12H.format(p.dateFrom)} - ${formatWithTime12H.format(p.dateTo)}'),
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
                    ref.invalidate(currentHydrationProvider);
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

  TextEditingController weight = TextEditingController();
  void _showWeightDialog(BuildContext context, ProfileModel? user) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Change Weight'),
        content: Column(
          children: [
            const SizedBox(height: 20),
            Material(
              child: TextFormField(
                  controller: weight,
                  validator: weightRequired,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(border: InputBorder.none)),
            )
          ],
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              ref.read(profileProvider.notifier).update(
                    uid: user!.uid!,
                    weight: double.parse(weight.text),
                  );
              await ref
                  .read(healthProvider)
                  .addWeightAndHeight(weight: double.parse(weight.text));
              ref.invalidate(healthNotifierProvider);
              ref.invalidate(fetchUserProvider);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEndDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Are you sure want to end fasting?'),
        content: const Text('Time of fasting will saved at last ended time'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              stopWatchTimer.onStopTimer();
              ref.read(startFastingProvider.notifier).set(false);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
