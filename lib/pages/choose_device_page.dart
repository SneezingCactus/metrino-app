import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:metrinoapp/managers/device_comm_manager.dart';

class ChooseDevicePage extends StatefulWidget {
  const ChooseDevicePage({super.key, required this.onDeviceChosen});

  final void Function(BluetoothDevice device) onDeviceChosen;

  @override
  State<ChooseDevicePage> createState() => _ChooseDevicePageState();
}

class _ChooseDevicePageState extends State<ChooseDevicePage> {
  List<BluetoothDevice> bondedDevices = [];

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  void fetchDevices() async {
    bondedDevices = [];

    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
    //  `scanResults` if you want live scan results *or* the results from a previous scan.
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          setState(() {
            bondedDevices.add(r.device);
          });
        }
      },
      onError: (e) => print(e),
    );

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    // Wait for Bluetooth enabled & permission granted
    // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    // Start scanning w/ timeout
    // Optional: use `stopScan()` as an alternative to timeout

    await FlutterBluePlus.startScan(
        withServices: [Guid(DeviceCommManager.configurationServiceUuid)],
        timeout: const Duration(seconds: 15));
    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.chooseDevicePage),
        ),
        body: Column(children: [
          Card.filled(
              child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(Icons.lightbulb_outline)),
              Expanded(
                  child: Padding(
                      padding:
                          const EdgeInsets.only(top: 20, bottom: 20, right: 20),
                      child: Text(
                        AppLocalizations.of(context)!.deviceNotHereTip,
                        softWrap: true,
                      ))),
            ],
          )),
          Expanded(
              child: ListView.builder(
                  itemCount: bondedDevices.length,
                  itemBuilder: (BuildContext context, index) => ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(bondedDevices[index].platformName),
                        subtitle: Text(bondedDevices[index].remoteId.str),
                        onTap: () {
                          DeviceCommManager.instance
                              .connect(bondedDevices[index]);
                          Navigator.pop(context, 'Device chosen');
                        },
                      )))
        ]));
  }
}
