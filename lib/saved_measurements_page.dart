import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:metrinoapp/measurement_units.dart';
import 'package:metrinoapp/storage_manager.dart';

class SavedMeasurementsPage extends StatefulWidget {
  const SavedMeasurementsPage({super.key});

  @override
  State<SavedMeasurementsPage> createState() => _SavedMeasurementsPageState();
}

class _SavedMeasurementsPageState extends State<SavedMeasurementsPage> {
  List<SavedMeasurement> savedMeasurements = [];

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
        title: Text(AppLocalizations.of(context)!.placeholder),
      ),
      body: ListView.separated(
        itemCount: savedMeasurements.length,
        itemBuilder: (BuildContext context, index) => ListTile(
          title: Text(MeasurementUnit.stringifyMeasurement(
              savedMeasurements[index].value, savedMeasurements[index].unit)),
          subtitle: Text(savedMeasurements[index].label),
          onTap: () {
            Navigator.pop(context, 'Device chosen');
          },
        ),
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
    );
  }
}
