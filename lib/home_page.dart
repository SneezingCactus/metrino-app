import 'dart:math';

import 'package:flutter/material.dart';
import 'package:metrinoapp/choose_unit_dialog.dart';
import 'package:metrinoapp/device_comm_manager.dart';
import 'package:metrinoapp/device_management_page.dart';
import 'package:metrinoapp/measurement_units.dart';
import 'package:metrinoapp/odometer_device_info.dart';
import 'package:metrinoapp/saved_measurements_page.dart';
import 'package:metrinoapp/settings_page.dart';
import 'package:metrinoapp/storage_manager.dart';
import 'package:metrinoapp/wheel_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

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
  }

  void _resetMeasurement() {
    setState(() {
      _currentMeasurement = 0;
    });
  }

  void _saveMeasurement() {
    TextEditingController controller = TextEditingController();

    showDialog(
        context: context,
        builder: ((BuildContext context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.placeholder),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.placeholder,
                ),
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancelDialogButton),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  },
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.okDialogButton),
                  onPressed: () {
                    Navigator.pop(context, 'OK');
                    StorageManager.instance.saveMeasurement(
                        _currentMeasurement, _currentUnit, controller.text);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Fuck')));
                  },
                )
              ],
            )));
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    ThemeData theme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      body: Center(
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              //mainAxisAlignment: MainAxisAlignment.center,
              //margin: const EdgeInsets.all(100),
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
              //mainAxisAlignment: MainAxisAlignment.center,
              //margin: const EdgeInsets.all(100),
              padding: const EdgeInsets.all(40),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _goToDeviceManagementPage,
                      tooltip: 'Increment',
                      icon: const Icon(Icons.bluetooth),
                    ),
                    IconButton(
                      onPressed: _goToSettingsPage,
                      tooltip: 'Increment',
                      icon: const Icon(Icons.settings),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
