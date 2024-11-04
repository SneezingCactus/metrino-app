import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  void loadPrefs() async {
    final prefsInstance = await SharedPreferences.getInstance();
    setState(() {
      prefs = prefsInstance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          SwitchListTile(
              title: Text(AppLocalizations.of(context)!.leftHandedMode),
              subtitle:
                  Text(AppLocalizations.of(context)!.leftHandedModeDescription),
              value: prefs?.getBool('leftHandedMode') ?? false,
              onChanged: (bool value) {
                setState(() {
                  prefs?.setBool('leftHandedMode', value);
                });
              }),
          const Divider(height: 0),
        ],
      ),
    );
  }
}
