import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:metrinoapp/managers/device_comm_manager.dart';
import 'package:metrinoapp/misc/odometer_device_info.dart';

class DeviceConfigPage extends StatefulWidget {
  const DeviceConfigPage({super.key});

  @override
  State<DeviceConfigPage> createState() => _DeviceConfigPageState();
}

class _DeviceConfigPageState extends State<DeviceConfigPage> {
  final OdometerDeviceInfo unsavedInfo =
      DeviceCommManager.instance.currentDeviceInfo.clone();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openDeviceNameDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController controller = TextEditingController();
          controller.text = unsavedInfo.name;
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.deviceName),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: Text(AppLocalizations.of(context)!.cancelDialogButton),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    unsavedInfo.name = controller.text;
                    DeviceCommManager.instance
                        .writeDeviceName(unsavedInfo.name);
                  });
                  Navigator.pop(context, 'Ok');
                },
                child: Text(AppLocalizations.of(context)!.okDialogButton),
              ),
            ],
          );
        });
  }

  void _openWheelDiameterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController controller = TextEditingController();
          controller.text = unsavedInfo.wheelDiameter.toString();
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.deviceWheelDiameter),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: Text(AppLocalizations.of(context)!.cancelDialogButton),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    controller.text =
                        controller.text.replaceAll(RegExp(r'[^0-9\.]'), '');
                    unsavedInfo.wheelDiameter = double.parse(controller.text);
                    DeviceCommManager.instance
                        .writeWheelDiameter(unsavedInfo.wheelDiameter);
                  });
                  Navigator.pop(context, 'Ok');
                },
                child: Text(AppLocalizations.of(context)!.okDialogButton),
              ),
            ],
          );
        });
  }

  void _openWheelSlotsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController controller = TextEditingController();
          controller.text = unsavedInfo.wheelSlots.toString();
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.deviceWheelSlots),
            content: TextField(
                controller: controller, keyboardType: TextInputType.number),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: Text(AppLocalizations.of(context)!.cancelDialogButton),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    controller.text =
                        controller.text.replaceAll(RegExp(r'[^0-9]'), '');
                    unsavedInfo.wheelSlots = int.parse(controller.text);
                    DeviceCommManager.instance
                        .writeWheelSlots(unsavedInfo.wheelSlots);
                  });
                  Navigator.pop(context, 'Ok');
                },
                child: Text(AppLocalizations.of(context)!.okDialogButton),
              ),
            ],
          );
        });
  }

  void _applyParams() {
    DeviceCommManager.instance.applyParams();
    Navigator.pop(context, 'Params applied');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.changesApplied),
            content: Text(AppLocalizations.of(context)!.changesAppliedNote),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                },
                child: Text(AppLocalizations.of(context)!.notYet),
              ),
              TextButton(
                onPressed: () {
                  DeviceCommManager.instance.restart();
                  Navigator.pop(context, 'Ok');
                },
                child: Text(AppLocalizations.of(context)!.restartNow),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.modifyDeviceParameters),
      ),
      body: Column(children: [
        Card.filled(
            child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.warning_amber_outlined)),
            Expanded(
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 20, bottom: 20, right: 20),
                    child: Text(
                      AppLocalizations.of(context)!.advancedUsersOnlyWarning,
                      softWrap: true,
                    ))),
          ],
        )),
        Expanded(
          child: ListView(children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text(AppLocalizations.of(context)!.deviceName),
              subtitle: Text(unsavedInfo.name),
              onTap: _openDeviceNameDialog,
            ),
            ListTile(
              leading: const Icon(Icons.motion_photos_off_outlined),
              title: Text(AppLocalizations.of(context)!.deviceWheelDiameter),
              subtitle: Text('${unsavedInfo.wheelDiameter}m'),
              onTap: _openWheelDiameterDialog,
            ),
            ListTile(
              leading: const Icon(Icons.downloading_outlined),
              title: Text(AppLocalizations.of(context)!.deviceWheelSlots),
              subtitle: Text('${unsavedInfo.wheelSlots}'),
              onTap: _openWheelSlotsDialog,
            ),
          ]),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: Text(AppLocalizations.of(context)!.applyDialogButton),
        onPressed: _applyParams,
      ),
    );
  }
}
