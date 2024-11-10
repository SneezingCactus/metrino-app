import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:metrinoapp/misc/measurement_units.dart';
import 'package:metrinoapp/managers/storage_manager.dart';
import 'package:flutter/services.dart';
import 'package:metrinoapp/pages/choose_unit_dialog.dart';

class SavedMeasurementsPage extends StatefulWidget {
  const SavedMeasurementsPage({super.key});

  @override
  State<SavedMeasurementsPage> createState() => _SavedMeasurementsPageState();
}

class _SavedMeasurementsPageState extends State<SavedMeasurementsPage> {
  List<SavedMeasurement> savedMeasurements = [];
  Set<int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    fetchSavedMeasurements();
  }

  void fetchSavedMeasurements() async {
    List<SavedMeasurement> fetchedMeasurements =
        await StorageManager.instance.getSavedMeasurements();
    setState(() {
      savedMeasurements = fetchedMeasurements;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: selectedItems.isEmpty
            ? null
            : IconButton(
                onPressed: () => setState(() => selectedItems.clear()),
                icon: const Icon(Icons.close)),
        title: selectedItems.isEmpty
            ? Text(AppLocalizations.of(context)!.savedMeasurementsPage)
            : Text(AppLocalizations.of(context)!
                .countSelected(selectedItems.length)),
        actions: selectedItems.isEmpty
            ? []
            : [
                IconButton(
                    onPressed: () async {
                      for (int index in selectedItems) {
                        await StorageManager.instance.deleteMeasurement(
                            savedMeasurements[index].timestamp);
                      }
                      selectedItems.clear();
                      fetchSavedMeasurements();
                    },
                    icon: const Icon(Icons.delete_outlined)),
              ],
      ),
      body: ListView.builder(
        itemCount: savedMeasurements.length,
        itemBuilder: (BuildContext context, index) {
          SavedMeasurement measurement = savedMeasurements[index];
          DateTime time =
              DateTime.fromMillisecondsSinceEpoch(measurement.timestamp);
          String stringifiedMeasurement = MeasurementUnit.stringifyMeasurement(
              measurement.value, measurement.unit);

          return ListTile(
            title: Text(stringifiedMeasurement),
            subtitle: Text(
                AppLocalizations.of(context)!.savedMeasurementOn(time, time)),
            selected: selectedItems.contains(index),
            selectedTileColor: Theme.of(context).focusColor,
            trailing: selectedItems.isEmpty
                ? MenuAnchor(
                    alignmentOffset: const Offset(-125, 0),
                    menuChildren: <Widget>[
                      MenuItemButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: stringifiedMeasurement));
                        },
                        leadingIcon: const Icon(Icons.copy_outlined),
                        child: const Text('Copy to clipboard'),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ChooseUnitDialog(
                                  initialValue: measurement.unit,
                                  onChanged: (newUnit) {
                                    setState(() {
                                      StorageManager.instance
                                          .changeMeasurementUnit(
                                              measurement.timestamp, newUnit);
                                      fetchSavedMeasurements();
                                    });
                                  },
                                );
                              });
                        },
                        leadingIcon: const Icon(Icons.straighten),
                        child: const Text('Change unit'),
                      ),
                      MenuItemButton(
                        onPressed: () async {
                          await StorageManager.instance
                              .deleteMeasurement(measurement.timestamp);
                          fetchSavedMeasurements();
                        },
                        leadingIcon: const Icon(Icons.delete_outlined),
                        child: const Text('Delete'),
                      ),
                    ],
                    builder: (_, MenuController controller, Widget? child) {
                      return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(Icons.more_vert),
                      );
                    },
                  )
                : null,
            onLongPress: () async {
              setState(() {
                if (selectedItems.contains(index)) {
                  selectedItems.remove(index);
                } else {
                  selectedItems.add(index);
                }
              });
            },
            onTap: () async {
              setState(() {
                if (selectedItems.contains(index)) {
                  selectedItems.remove(index);
                } else {
                  selectedItems.add(index);
                }
              });
            },
          );
        },
      ),
    );
  }
}
