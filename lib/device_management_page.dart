import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:metrinoapp/choose_device_page.dart';
import 'package:metrinoapp/odometer_device_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key, required this.deviceInfo});

  final OdometerDeviceInfo deviceInfo;

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  void _goToChooseDevicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChooseDevicePage(
                onDeviceChosen: (BluetoothDevice device) {},
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage device"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.abc),
            title: Text(AppLocalizations.of(context)!.deviceName),
            subtitle: Text(widget.deviceInfo.name),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(AppLocalizations.of(context)!.deviceAddress),
            subtitle: Text(widget.deviceInfo.address),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.battery_full),
            title: Text(AppLocalizations.of(context)!.deviceBattery),
            subtitle: Text("${widget.deviceInfo.battery.toString()}%"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.motion_photos_off_outlined),
            title: Text(AppLocalizations.of(context)!.deviceWheelDiameter),
            subtitle: Text("${widget.deviceInfo.battery.toString()}m"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.link),
        label: Text(AppLocalizations.of(context)!.chooseDevicePage),
        onPressed: _goToChooseDevicePage,
      ),
    );
  }
}
