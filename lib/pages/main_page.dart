import 'package:flutter/material.dart';
import 'package:metrinoapp/pages/choose_unit_dialog.dart';
import 'package:metrinoapp/managers/device_comm_manager.dart';
import 'package:metrinoapp/pages/device_management_page.dart';
import 'package:metrinoapp/misc/measurement_units.dart';
import 'package:metrinoapp/pages/saved_measurements_page.dart';
import 'package:metrinoapp/managers/storage_manager.dart';
import 'package:metrinoapp/misc/wheel_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MeasurementUnit _currentUnit = MeasurementUnit.all.values.first;
  double _currentMeasurement = 0;

  @override
  void initState() {
    super.initState();

    DeviceCommManager.instance.turnListeners.add(_turnListener);
  }

  @override
  void dispose() {
    super.dispose();

    DeviceCommManager.instance.turnListeners.remove(_turnListener);
  }

  void _turnListener(double incomingMeasurement) {
    setState(() {
      _currentMeasurement = incomingMeasurement;
    });
  }

  void _resetMeasurement() {
    setState(() {
      DeviceCommManager.instance.measurementCha
          ?.write([0, 0, 0, 0, 0, 0, 0, 0]);
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
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const DeviceManagementPage()));
  }

  /*
  void _goToSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }*/

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
      body: Stack(children: [
        Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _goToDeviceManagementPage,
                      tooltip:
                          AppLocalizations.of(context)!.deviceManagementPage,
                      icon: const Icon(Icons.bluetooth),
                      padding: const EdgeInsets.all(10.0),
                    ),
                    /*
                    IconButton.filledTonal(
                      onPressed: _goToSettingsPage,
                      tooltip: AppLocalizations.of(context)!.settings,
                      icon: const Icon(Icons.settings),
                      padding: const EdgeInsets.all(10.0),
                    ),*/
                  ]),
            ),
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
          ],
        ),
        Center(
          child: CustomPaint(
              painter: WheelWidget(
                borderThickness: 10,
                emptyZoneColor: theme.colorScheme.primaryContainer,
                filledZoneColor: theme.colorScheme.inversePrimary,
                progress: MeasurementUnit.convertMeasurement(
                        _currentMeasurement,
                        MeasurementUnit.nextUnit[_currentUnit.symbol]!) *
                    360,
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
        ),
      ]),
    );
  }
}
