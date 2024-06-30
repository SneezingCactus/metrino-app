import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _goToRecalibrationPage() {}

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
              value: false,
              onChanged: (bool value) => {}),
          const Divider(height: 0),
          ListTile(
            title: const Text('Recalibrar'),
            enableFeedback: true,
            onTap: _goToRecalibrationPage,
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }
}
