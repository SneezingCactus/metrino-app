import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeasurementUnit {
  final String symbol;
  final double meterRatio;

  MeasurementUnit({
    required this.symbol,
    required this.meterRatio,
  });

  static List<MeasurementUnit> all = [
    MeasurementUnit(symbol: 'km', meterRatio: 1000),
    MeasurementUnit(symbol: 'm', meterRatio: 1),
    MeasurementUnit(symbol: 'cm', meterRatio: 0.01),
    MeasurementUnit(symbol: 'mi', meterRatio: 1609.344),
    MeasurementUnit(symbol: 'yd', meterRatio: 0.9144),
    MeasurementUnit(symbol: 'ft', meterRatio: 0.3048),
    MeasurementUnit(symbol: 'in', meterRatio: 0.0254),
  ];

  static String getUnitFullName(BuildContext context, MeasurementUnit unit) {
    switch (unit.symbol) {
      case 'km':
        return AppLocalizations.of(context)!.unitKilometers;
      case 'm':
        return AppLocalizations.of(context)!.unitMeters;
      case 'cm':
        return AppLocalizations.of(context)!.unitCentimeters;
      case 'mi':
        return AppLocalizations.of(context)!.unitMiles;
      case 'yd':
        return AppLocalizations.of(context)!.unitYards;
      case 'ft':
        return AppLocalizations.of(context)!.unitFeet;
      case 'in':
        return AppLocalizations.of(context)!.unitInches;
      default:
        return AppLocalizations.of(context)!.unitUnknown;
    }
  }
}
