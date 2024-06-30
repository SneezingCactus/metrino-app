import 'package:flutter/material.dart';
import 'measurement_units.dart';
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
  MeasurementUnit chosenOption = MeasurementUnit.all[0];

  @override
  void initState() {
    super.initState();

    chosenOption = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> unitList = [];

    // chosenOption = widget.initialValue;

    for (MeasurementUnit unit in MeasurementUnit.all) {
      unitList.add(RadioListTile<MeasurementUnit>(
        title: Text(
            '${MeasurementUnit.getUnitFullName(context, unit)} (${unit.symbol})'),
        groupValue: chosenOption,
        value: unit,
        onChanged: (MeasurementUnit? value) {
          setState(() {
            chosenOption = value!;
          });
        },
      ));
    }

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.changeMeasurementUnit),
      content: SingleChildScrollView(
        child: Column(children: unitList),
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
            widget.onChanged(chosenOption);
          },
        )
      ],
    );
  }
}
