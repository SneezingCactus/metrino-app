import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeasurementUnit {
  final String symbol;
  final double meterRatio;

  MeasurementUnit({
    required this.symbol,
    required this.meterRatio,
  });

  static Map<String, MeasurementUnit> all = {
    'm': MeasurementUnit(symbol: 'm', meterRatio: 1),
    'cm': MeasurementUnit(symbol: 'cm', meterRatio: 0.01),
    'km': MeasurementUnit(symbol: 'km', meterRatio: 1000),
    'in': MeasurementUnit(symbol: 'in', meterRatio: 0.0254),
    'ft': MeasurementUnit(symbol: 'ft', meterRatio: 0.3048),
    'yd': MeasurementUnit(symbol: 'yd', meterRatio: 0.9144),
    'mi': MeasurementUnit(symbol: 'mi', meterRatio: 1609.344),
  };

  static String getUnitFullName(BuildContext context, MeasurementUnit unit) {
    switch (unit.symbol) {
      case 'm':
        return AppLocalizations.of(context)!.unitMeters;
      case 'cm':
        return AppLocalizations.of(context)!.unitCentimeters;
      case 'km':
        return AppLocalizations.of(context)!.unitKilometers;
      case 'in':
        return AppLocalizations.of(context)!.unitInches;
      case 'ft':
        return AppLocalizations.of(context)!.unitFeet;
      case 'yd':
        return AppLocalizations.of(context)!.unitYards;
      case 'mi':
        return AppLocalizations.of(context)!.unitMiles;
      default:
        return AppLocalizations.of(context)!.unitUnknown;
    }
  }

  static String stringifyMeasurement(double measurement, MeasurementUnit unit) {
    return '${(measurement / unit.meterRatio).toStringAsFixed(2)}${unit.symbol}';
  }
}
