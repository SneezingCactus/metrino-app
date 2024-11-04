import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:metrinoapp/managers/device_comm_manager.dart';
import 'package:metrinoapp/managers/storage_manager.dart';
import 'package:metrinoapp/pages/choose_device_page.dart';
import 'package:metrinoapp/pages/main_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _goToMainPage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainPage()));
  }

  void _goToChooseDevicePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChooseDevicePage(
                onDeviceChosen: (BluetoothDevice device) {
                  _goToMainPage(context);
                },
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    StorageManager.instance.init();
    DeviceCommManager.instance.init();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
      if (event.connectionState == BluetoothConnectionState.disconnected &&
          !DeviceCommManager.instance.intentionallyDisconnecting) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });

    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/logo.png",
            width: 400,
            color: Theme.of(context).textTheme.titleMedium!.color,
          ),
          Text(
            AppLocalizations.of(context)!.pleaseConnect,
            style: const TextStyle(fontSize: 16),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 50)),
          FloatingActionButton.extended(
            icon: const Icon(Icons.link),
            label: Text(AppLocalizations.of(context)!.chooseDevicePage),
            onPressed: () => _goToChooseDevicePage(context),
          )
        ],
      ),
    ));
  }
}
