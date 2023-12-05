import 'dart:async';
import 'dart:convert' show utf8;

import 'package:app_settings/app_settings.dart';
import 'package:ble_light_controller/utils/listener.dart' as l;
import 'package:ble_light_controller/utils/service_uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class HomePageController extends GetxController {
  BluetoothDevice? currentDevice;
  BluetoothCharacteristic? comCharacteristic;
  StreamSubscription<List<int>>? comSubscription;

  var isConnected = false.obs;
  var isConnecting = false.obs;
  var isScanning = true.obs;
  var isOn = false.obs;
  var deviceName = 'BT05';

  @override
  void onInit() {
    super.onInit();
    listen();
    findPreviousConnection();
  }

  listen() {
    FlutterBluePlus.isScanning.listen((event) {
      isScanning.value = event;
    });
    FlutterBluePlus.scanResults.listen((event) async {
      for (var i in event) {
        if (i.device.advName == deviceName) {
          isConnecting.value = true;
          stopScan();
          currentDevice = i.device;
          await currentDevice?.connect(timeout: const Duration(seconds: 5));
          currentDevice?.connectionState.listen((event) async {
            if (event == BluetoothConnectionState.connected) {
              var services = await currentDevice?.discoverServices();
              for (var service in services!) {
                debugPrint(service.uuid.str);
                if (serviceUuid[service.uuid.str] == null) {
                  var characteristics = service.characteristics;
                  for (var characteristic in characteristics) {
                    debugPrint(characteristic.uuid.str);
                    characteristic.setNotifyValue(true);
                    l.Listener(characteristic, this);
                    try {
                      await characteristic.write(utf8.encode('2'));
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  }
                }
              }
            }
          });
        }
      }
    });
  }

  startScan() async {
    if (!await Location().serviceEnabled()) {
      AppSettings.openAppSettings(type: AppSettingsType.location);
      return;
    }

    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
    );
  }

  stopScan() {
    FlutterBluePlus.stopScan();
  }

  initiateCommunication(BluetoothCharacteristic characteristic) async {
    comCharacteristic = characteristic;
    comCharacteristic?.setNotifyValue(true);
    isConnected.value = true;
    isConnecting.value = false;
    if (comSubscription != null) comSubscription!.cancel();
    comSubscription = comCharacteristic!.lastValueStream.listen((event) {
      var response = utf8.decode(event);
      if (response == '49') {
        isOn.value = true;
      } else if (response == '48') {
        isOn.value = false;
      }
      debugPrint(response);
    });
  }

  write(String data) async {
    if (comCharacteristic != null) {
      await comCharacteristic!.write(utf8.encode(data));
    }
  }

  findPreviousConnection() async {
    var devices = FlutterBluePlus.connectedDevices;
    for (var device in devices) {
      if (device.advName == deviceName) {
        isConnecting.value = true;
        currentDevice = device;
        await currentDevice?.connect(timeout: const Duration(seconds: 5));
        currentDevice?.connectionState.listen((event) async {
          if (event == BluetoothConnectionState.connected) {
            var services = await currentDevice?.discoverServices();
            for (var service in services!) {
              debugPrint(service.uuid.str);
              if (serviceUuid[service.uuid.str] == null) {
                var characteristics = service.characteristics;
                for (var characteristic in characteristics) {
                  debugPrint(characteristic.uuid.str);
                  characteristic.setNotifyValue(true);
                  l.Listener(characteristic, this);
                  try {
                    await characteristic.write(utf8.encode('2'));
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                }
              }
            }
          }
        });
      }
    }
    if (currentDevice == null) startScan();
  }
}
