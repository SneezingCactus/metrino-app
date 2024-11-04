import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:metrinoapp/managers/device_comm_manager.dart';
import 'package:metrinoapp/pages/choose_device_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  void _goToChooseDevicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChooseDevicePage(
                onDeviceChosen: (BluetoothDevice device) {
                  setState(() {});
                },
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.deviceManagementPage),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                "assets/device_renders/metrino_v1.png",
                width: MediaQuery.of(context).size.width / 2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.connectedTo,
                      style: const TextStyle(fontSize: 12)),
                  Text(DeviceCommManager.instance.currentDeviceInfo.name,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Icon(Icons.bluetooth),
                      Text(
                          ' ${AppLocalizations.of(context)!.deviceAddress}: ${DeviceCommManager.instance.currentDeviceInfo.address}',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.battery_full),
                      Text(
                          ' ${AppLocalizations.of(context)!.deviceBattery}: ${DeviceCommManager.instance.currentDeviceInfo.battery.toStringAsFixed(2)}V',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.motion_photos_off_outlined),
                      Text(
                          ' ${AppLocalizations.of(context)!.deviceWheelDiameter}: ${DeviceCommManager.instance.currentDeviceInfo.wheelDiameter}m',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.downloading_outlined),
                      Text(
                          ' ${AppLocalizations.of(context)!.deviceWheelSlots}: ${DeviceCommManager.instance.currentDeviceInfo.wheelSlots}',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              )
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: Text(AppLocalizations.of(context)!.modifyDeviceParameters),
            subtitle: Text(AppLocalizations.of(context)!.advancedUsersOnly),
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
