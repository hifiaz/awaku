import 'package:awaku/service/ftms_service.dart';
import 'package:awaku/service/provider/health_provider.dart';
import 'package:awaku/utils/responsive.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ftms/flutter_ftms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class BikeView extends ConsumerStatefulWidget {
  final BluetoothDevice ftmsDevice;

  const BikeView({super.key, required this.ftmsDevice});

  @override
  ConsumerState<BikeView> createState() => _BikeViewState();
}

class _BikeViewState extends ConsumerState<BikeView> {
  DateTime start = DateTime.now();
  DeviceDataParameterValue? totalDistance;
  DeviceDataParameterValue? cal;
  List<double> data = [0.0];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(context.responsiveSpacing(8)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(12)),
          ),
          child: IconButton(
            onPressed: () => showAlertDialog(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface,
              size: context.responsiveIconSize(20),
            ),
          ),
        ),
        title: Text(
          'Cycling Session',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20 * context.fontSizeMultiplier,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DeviceData?>(
        stream: ftmsService.ftmsDeviceDataControllerStream,
        builder: (c, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.surface,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: context.responsiveSpacing(120),
                      height: context.responsiveSpacing(120),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_bike_rounded,
                        size: context.responsiveIconSize(60),
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(32)),
                    Text(
                      'Ready to Start',
                      style: TextStyle(
                        fontSize: 24 * context.fontSizeMultiplier,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(8)),
                    Text(
                      'Connect your bike to begin tracking',
                      style: TextStyle(
                        fontSize: 16 * context.fontSizeMultiplier,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(32)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(16)),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FTMS.useDeviceDataCharacteristic(widget.ftmsDevice,
                              (DeviceData data) {
                            ftmsService.ftmsDeviceDataControllerSink.add(data);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveSpacing(32),
                            vertical: context.responsiveSpacing(16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(16)),
                          ),
                        ),
                        child: Text(
                          'Start Session',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 16 * context.fontSizeMultiplier,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final power = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere(
                  (element) => element.flag?.name == 'Instantaneous Power');
          final speed = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere((element) => element.flag?.name == 'More Data');
          final instan = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere(
                  (element) => element.flag?.name == 'Instantaneous Cadence');
          final time = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere((element) => element.flag?.name == 'Elapsed Time');
          final distance = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere((element) => element.flag?.name == 'Total Distance');
          final energy = snapshot.data!
              .getDeviceDataParameterValues()
              .firstWhere((element) => element.flag?.name == 'Expended Energy');
          totalDistance = distance;
          cal = energy;
          data.add(power.value.toDouble());
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withOpacity(0.05),
                  colorScheme.surface,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsiveSpacing(20)),
              child: Column(
                children: [
                  // Power Display Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.responsiveSpacing(24)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(context.responsiveBorderRadius(20)),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          color: colorScheme.onPrimary,
                          size: context.responsiveIconSize(32),
                        ),
                        SizedBox(height: context.responsiveSpacing(8)),
                        Text(
                          '${power.value}',
                          style: TextStyle(
                            fontSize: 48 * context.fontSizeMultiplier,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'WATTS',
                          style: TextStyle(
                            fontSize: 14 * context.fontSizeMultiplier,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onPrimary.withOpacity(0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: context.responsiveSpacing(24)),
                  
                  // Chart Card
                  Container(
                    height: context.responsiveSpacing(200),
                    padding: EdgeInsets.all(context.responsiveSpacing(20)),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(context.responsiveBorderRadius(16)),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Power Output',
                          style: TextStyle(
                            fontSize: 16 * context.fontSizeMultiplier,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Sparkline(
                            data: data,
                            lineColor: colorScheme.primary,
                            lineWidth: 3,
                            fillMode: FillMode.below,
                            fillGradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colorScheme.primary.withOpacity(0.3),
                                colorScheme.primary.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: context.responsiveSpacing(24)),
                  
                  // Metrics Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: context.gridColumns,
                    crossAxisSpacing: context.responsiveSpacing(16),
                    mainAxisSpacing: context.responsiveSpacing(16),
                    childAspectRatio: 1.2,
                    children: [
                      _buildMetricCard(
                        icon: Icons.speed_rounded,
                        title: 'Speed',
                        value: '${(speed.value / 100).toStringAsFixed(1)}',
                        unit: speed.unit,
                        colorScheme: colorScheme,
                      ),
                      _buildMetricCard(
                        icon: Icons.timer_rounded,
                        title: 'Time',
                        value: '${time.value}',
                        unit: time.unit,
                        colorScheme: colorScheme,
                      ),
                      _buildMetricCard(
                        icon: Icons.straighten_rounded,
                        title: 'Distance',
                        value: '${distance.value}',
                        unit: distance.unit,
                        colorScheme: colorScheme,
                      ),
                      _buildMetricCard(
                        icon: Icons.local_fire_department_rounded,
                        title: 'Calories',
                        value: '${energy.value}',
                        unit: energy.unit,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: context.responsiveSpacing(24)),
                  
                  // Cadence Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.responsiveSpacing(20)),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(context.responsiveBorderRadius(16)),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: context.responsiveSpacing(48),
                          height: context.responsiveSpacing(48),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(12)),
                          ),
                          child: Icon(
                            Icons.rotate_right_rounded,
                            color: colorScheme.primary,
                            size: context.responsiveIconSize(24),
                          ),
                        ),
                        SizedBox(width: context.responsiveSpacing(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cadence',
                                style: TextStyle(
                                  fontSize: 14 * context.fontSizeMultiplier,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: context.responsiveSpacing(4)),
                              Text(
                                '${(instan.value / 60).toStringAsFixed(1)} ${instan.unit}',
                                style: TextStyle(
                                  fontSize: 20 * context.fontSizeMultiplier,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Device Type
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      FTMS.convertDeviceDataTypeToString(snapshot.data!.deviceDataType),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(16)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: context.responsiveSpacing(40),
            height: context.responsiveSpacing(40),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(10)),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: context.responsiveIconSize(20),
            ),
          ),
          SizedBox(height: context.responsiveSpacing(12)),
          Text(
            title,
            style: TextStyle(
              fontSize: 12 * context.fontSizeMultiplier,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.responsiveSpacing(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: 18 * context.fontSizeMultiplier,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10 * context.fontSizeMultiplier,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    final colorScheme = Theme.of(context).colorScheme;
    
    Widget cancelButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
      child: const Text("Cancel"),
      onPressed: () {
        context.pop();
      },
    );

    Widget exitButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.error,
      ),
      child: const Text("Exit"),
      onPressed: () {
        context.pop();
        context.pop();
      },
    );
    
    Widget continueButton = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: const Text("Exit & Save"),
        onPressed: () async {
          Logger().d(
              'start $start end ${DateTime.now()} cal $cal distance $totalDistance');
          await ref.read(healthProvider).addBike(
              start: start,
              end: DateTime.now(),
              calories: cal!.value,
              distance: totalDistance!.value);
          if (context.mounted) {
            context.pop();
            context.pop();
          }
        },
      ),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        "Exit Session",
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        "Are you sure you want to exit from this cycling session?",
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        cancelButton,
        exitButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
