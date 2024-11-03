import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metrinoapp/pages/choose_unit_dialog.dart';
import 'package:metrinoapp/managers/device_comm_manager.dart';
import 'package:metrinoapp/pages/device_management_page.dart';
import 'package:metrinoapp/misc/measurement_units.dart';
import 'package:metrinoapp/misc/odometer_device_info.dart';
import 'package:metrinoapp/pages/saved_measurements_page.dart';
import 'package:metrinoapp/pages/settings_page.dart';
import 'package:metrinoapp/managers/storage_manager.dart';
import 'package:metrinoapp/misc/wheel_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MeasurementUnit _currentUnit = MeasurementUnit.all.values.first;
  double _currentMeasurement = 0;

  @override
  void initState() {
    super.initState();

    StorageManager.instance.init();

    DeviceCommManager.instance.init();
    DeviceCommManager.instance.turnListeners.add((TurnDirection direction) {
      setState(() {
        OdometerDeviceInfo deviceInfo =
            DeviceCommManager.instance.currentDeviceInfo;
        double pulseLength =
            pi * deviceInfo.wheelDiameter / deviceInfo.wheelDivisions;

        if (direction == TurnDirection.right) {
          _currentMeasurement += pulseLength;
        } else {
          _currentMeasurement -= pulseLength;
        }
      });
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _resetMeasurement() {
    setState(() {
      _currentMeasurement = 0;
    });
  }

  void _saveMeasurement() {
    StorageManager.instance.saveMeasurement(_currentMeasurement, _currentUnit);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.measurementSaved),
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1500),
      width: 280.0, // Width of the SnackBar.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
  }

  void _goToDeviceManagementPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DeviceManagementPage(
                deviceInfo: DeviceCommManager.instance.currentDeviceInfo,
              )),
    );
  }

  void _goToSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _goToSavedMeasurementsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedMeasurementsPage()),
    );
  }

  void _chooseMeasurementUnit() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChooseUnitDialog(
            initialValue: _currentUnit,
            onChanged: (newUnit) {
              setState(() {
                _currentUnit = newUnit;
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      body: Center(
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FloatingActionButton(
                      heroTag: 'resetMeasurementButton',
                      onPressed: _resetMeasurement,
                      tooltip: AppLocalizations.of(context)!.resetMeasurement,
                      elevation: 1,
                      child: const Icon(Icons.restart_alt),
                    ),
                    FloatingActionButton(
                      heroTag: 'saveMeasurementButton',
                      onPressed: _saveMeasurement,
                      tooltip: AppLocalizations.of(context)!.saveMeasurement,
                      elevation: 1,
                      child: const Icon(Icons.bookmark_add_outlined),
                    ),
                    FloatingActionButton(
                      heroTag: 'changeUnitButton',
                      onPressed: _chooseMeasurementUnit,
                      tooltip:
                          AppLocalizations.of(context)!.changeMeasurementUnit,
                      elevation: 1,
                      child: const Icon(Icons.straighten),
                    ),
                  ]),
            ),
            CustomPaint(
                painter: WheelWidget(
                  borderThickness: 10,
                  emptyZoneColor: theme.colorScheme.primaryContainer,
                  filledZoneColor: theme.colorScheme.inversePrimary,
                  progress: _currentMeasurement * 360,
                ),
                child: InkWell(
                  onTap: _goToSavedMeasurementsPage,
                  customBorder: const CircleBorder(),
                  child: Container(
                      padding: const EdgeInsets.all(25),
                      width: 300,
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                MeasurementUnit.stringifyMeasurement(
                                    _currentMeasurement, _currentUnit),
                                style: theme.textTheme.displayLarge,
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!
                                  .seeSavedMeasurements),
                              const Icon(Icons.keyboard_arrow_down_rounded)
                            ],
                          )
                        ],
                      )),
                )),
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _goToDeviceManagementPage,
                      tooltip: 'Increment',
                      icon: const Icon(Icons.bluetooth),
                      padding: const EdgeInsets.all(20.0),
                    ),
                    IconButton(
                      onPressed: _goToSettingsPage,
                      tooltip: 'Increment',
                      icon: const Icon(Icons.settings),
                      padding: const EdgeInsets.all(20.0),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
