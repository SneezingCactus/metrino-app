import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:metrinoapp/odometer_device_info.dart';

enum TurnDirection {
  left,
  right,
}

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
  static const String turnPulseChaUuid = '8fc09712-72c2-421e-865e-fd5436896cf2';

  BluetoothDevice? currentDevice;
  OdometerDeviceInfo currentDeviceInfo = OdometerDeviceInfo();

  BluetoothService? configurationService;
  BluetoothCharacteristic? deviceNameCha;
  BluetoothCharacteristic? batteryAmountCha;
  BluetoothCharacteristic? wheelDiameterCha;
  BluetoothCharacteristic? wheelDivisionsCha;
  BluetoothService? operationService;
  BluetoothCharacteristic? turnPulseCha;

  Uint8List inputBuffer = Uint8List(1024);
  int inputBufferCursor = 0;

  List<void Function(OdometerDeviceInfo info)> connectionListeners = [];
  List<void Function(TurnDirection direction)> turnListeners = [];

  void init() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    subscription.cancel();
  }

  Future<bool> connect(BluetoothDevice device) async {
    await currentDevice?.disconnect();
    await device.connect();

    currentDevice = device;

    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      switch (service.serviceUuid.str) {
        case configurationServiceUuid:
          configurationService = service;
          break;
        case operationServiceUuid:
          operationService = service;
          break;
      }
    }

    for (BluetoothCharacteristic cha in configurationService!.characteristics) {
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
          wheelDivisionsCha = cha;
          break;
      }
    }

    for (BluetoothCharacteristic cha in operationService!.characteristics) {
      switch (cha.characteristicUuid.str) {
        case turnPulseChaUuid:
          turnPulseCha = cha;
          break;
      }
    }

    if (deviceNameCha == null) return false;
    if (batteryAmountCha == null) return false;
    if (wheelDiameterCha == null) return false;
    if (wheelDivisionsCha == null) return false;
    if (turnPulseCha == null) return false;

    final turnPulseSubscription = turnPulseCha!.onValueReceived.listen((value) {
      print(value);
      for (void Function(TurnDirection) listener in turnListeners) {
        listener(TurnDirection.values[value[0]]);
      }
    });

    device.cancelWhenDisconnected(turnPulseSubscription);

    await turnPulseCha!.setNotifyValue(true);

    currentDeviceInfo.name = (await deviceNameCha!.read()).toString();
    // currentDeviceInfo.pulsesPerSpin = (await wheelDivisionsCha!.read());

    /*
    if (!connection.isConnected) return false;

    currentConnection = connection;
    connection.input?.listen(inputListener);
    */

    // connection.output.add(data)

    return true;
  }

  void inputListener(Uint8List data) {
    for (int byte in data) {
      if (byte == 240) {
        inputBufferCursor = 0;

        switch (inputBuffer[0]) {
          case 1:
            for (var element in turnListeners) {
              element(inputBuffer[1] == 1
                  ? TurnDirection.right
                  : TurnDirection.left);
            }
            break;
        }

        continue;
      }

      inputBuffer[inputBufferCursor] = byte;
      inputBufferCursor++;
    }
  }
}
