import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:metrinoapp/misc/odometer_device_info.dart';

class DeviceCommManager {
  static DeviceCommManager instance = DeviceCommManager();

  static const String configurationServiceUuid =
      'c22fe686-2ea0-4eb3-8389-d568284e5b10';
  static const String deviceNameChaUuid =
      "6f5e26b6-5920-4c44-ad4b-3b7893f8ef09";
  static const String batteryAmountChaUuid =
      "0efa935a-9627-4f0b-9e8f-1b86084d2477";
  static const String wheelDiameterChaUuid =
      "63a4b587-33e2-49ba-9c8b-cf0ed8989bae";
  static const String wheelDivisionsChaUuid =
      "9b04682b-7eb0-449b-bd79-419064a43463";
  static const String operationServiceUuid =
      '0331e722-6d35-4922-8c69-f80d0f9fb9e7';
  static const String measurementChaUuid =
      '8fc09712-72c2-421e-865e-fd5436896cf2';

  BluetoothDevice? currentDevice;
  OdometerDeviceInfo currentDeviceInfo = OdometerDeviceInfo();

  BluetoothService? paramService;
  BluetoothCharacteristic? deviceNameCha;
  BluetoothCharacteristic? batteryAmountCha;
  BluetoothCharacteristic? wheelDiameterCha;
  BluetoothCharacteristic? wheelSlotsCha;
  BluetoothService? operationService;
  BluetoothCharacteristic? measurementCha;

  Uint8List inputBuffer = Uint8List(1024);
  int inputBufferCursor = 0;

  bool intentionallyDisconnecting = false;

  List<void Function(double incomingMeasurement)> turnListeners = [];

  static int intFromBytes(List<int> value) {
    ByteBuffer buffer = Uint8List.fromList(value.reversed.toList()).buffer;
    ByteData byteData = ByteData.view(buffer);
    return byteData.getInt32(0);
  }

  static double doubleFromBytes(List<int> value) {
    ByteBuffer buffer = Uint8List.fromList(value.reversed.toList()).buffer;
    ByteData byteData = ByteData.view(buffer);
    return byteData.getFloat64(0);
  }

  void init() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn(timeout: 600);
    }

    subscription.cancel();
  }

  Future<bool> disconnect() async {
    await currentDevice?.disconnect();
    return true;
  }

  Future<bool> connect(BluetoothDevice device) async {
    await disconnect();
    await device.connect();

    currentDevice = device;

    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      switch (service.serviceUuid.str) {
        case configurationServiceUuid:
          paramService = service;
          break;
        case operationServiceUuid:
          operationService = service;
          break;
      }
    }

    for (BluetoothCharacteristic cha in paramService!.characteristics) {
      switch (cha.characteristicUuid.str) {
        case deviceNameChaUuid:
          deviceNameCha = cha;
          break;
        case batteryAmountChaUuid:
          batteryAmountCha = cha;
          break;
        case wheelDiameterChaUuid:
          wheelDiameterCha = cha;
          break;
        case wheelDivisionsChaUuid:
          wheelSlotsCha = cha;
          break;
      }
    }

    for (BluetoothCharacteristic cha in operationService!.characteristics) {
      switch (cha.characteristicUuid.str) {
        case measurementChaUuid:
          measurementCha = cha;
          break;
      }
    }

    if (deviceNameCha == null) return false;
    if (batteryAmountCha == null) return false;
    if (wheelDiameterCha == null) return false;
    if (wheelSlotsCha == null) return false;
    if (measurementCha == null) return false;

    final turnPulseSubscription =
        measurementCha!.onValueReceived.listen((value) {
      double incomingMeasurement = doubleFromBytes(value);
      for (void Function(double) listener in turnListeners) {
        listener(incomingMeasurement);
      }
    });

    device.cancelWhenDisconnected(turnPulseSubscription);

    await measurementCha!.setNotifyValue(true);

    currentDeviceInfo.name = String.fromCharCodes(await deviceNameCha!.read());
    currentDeviceInfo.address = device.remoteId.str;
    currentDeviceInfo.battery = doubleFromBytes(await batteryAmountCha!.read());
    currentDeviceInfo.wheelDiameter =
        doubleFromBytes(await wheelDiameterCha!.read());
    currentDeviceInfo.wheelSlots = intFromBytes(await wheelSlotsCha!.read());

    return true;
  }
}
