import 'package:flutter/material.dart';
import '../misc/measurement_units.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChooseUnitDialog extends StatefulWidget {
  const ChooseUnitDialog(
      {super.key, required this.initialValue, required this.onChanged});

  final MeasurementUnit initialValue;
  final void Function(MeasurementUnit newUnit) onChanged;

  @override
  State<ChooseUnitDialog> createState() => _ChooseUnitDialogState();
}

class _ChooseUnitDialogState extends State<ChooseUnitDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> unitList = [];

    for (MeasurementUnit unit in MeasurementUnit.all.values) {
      unitList.add(ListTile(
        title: Text(
            '${MeasurementUnit.getUnitFullName(context, unit)} (${unit.symbol})'),
        trailing: widget.initialValue == unit ? const Icon(Icons.check) : null,
        enableFeedback: true,
        onTap: () {
          Navigator.pop(context, 'OK');
          widget.onChanged(unit);
        },
      ));
    }

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.changeMeasurementUnit),
      contentPadding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      content: Column(
        children: [
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: unitList),
            ),
          ),
          const Divider()
        ],
      ),
    );
  }
}
