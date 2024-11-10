class OdometerDeviceInfo {
  String name = "<no device>";
  String address = "<no device>";
  double battery = 0;
  double wheelDiameter = 0.1;
  int wheelSlots = 20;

  OdometerDeviceInfo clone() {
    return OdometerDeviceInfo()
      ..name = name
      ..address = address
      ..battery = battery
      ..wheelDiameter = wheelDiameter
      ..wheelSlots = wheelSlots;
  }
}
