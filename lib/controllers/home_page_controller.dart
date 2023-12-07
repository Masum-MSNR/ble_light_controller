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
  var deviceName = 'microBio';

  @override
  void onInit() {
    super.onInit();
    listen();
    findPreviousConnection();
  }

  listen() {
    FlutterBluePlus.isScanning.listen((event) {
      isScanning.value = event;
      if (!event && !isConnected.value) startScan();
    });
    FlutterBluePlus.scanResults.listen((event) async {
      for (var i in event) {
        debugPrint(i.device.platformName);
        if (i.device.platformName == deviceName) {
          isConnecting.value = true;
          stopScan();
          currentDevice = i.device;
          await currentDevice?.connect();
          await currentDevice?.discoverServices();
          for (var service in currentDevice!.servicesList) {
            debugPrint(service.uuid.str);
            if (serviceUuid[service.uuid.str] == null) {
              var characteristics = service.characteristics;
              for (var characteristic in characteristics) {
                debugPrint(characteristic.uuid.str);
                await Future.delayed(const Duration(milliseconds: 500));
                characteristic.setNotifyValue(true);
                await Future.delayed(const Duration(milliseconds: 500));
                l.Listener(characteristic, this);
                try {
                  await characteristic.write(
                    utf8.encode('2'),
                    withoutResponse:
                        characteristic.properties.writeWithoutResponse,
                  );
                } catch (e) {
                  debugPrint(e.toString());
                }
              }
            }
          }
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
    write('1');

    currentDevice?.connectionState.listen((event) {
      if (event == BluetoothConnectionState.disconnected) {
        isConnected.value = false;
        isConnecting.value = false;
        isScanning.value = true;
        isOn.value = false;
        currentDevice = null;
        comCharacteristic = null;
        comSubscription = null;
        startScan();
      }
    });
  }

  write(String data) async {
    if (comCharacteristic != null) {
      await comCharacteristic!.write(
        utf8.encode(data),
        withoutResponse: comCharacteristic!.properties.writeWithoutResponse,
      );
    }
  }

  findPreviousConnection() async {
    var devices = FlutterBluePlus.connectedDevices;
    for (var device in devices) {
      if (device.platformName == deviceName) {
        isConnecting.value = true;
        currentDevice = device;
        await currentDevice?.connect();
        await currentDevice?.discoverServices();
        for (var service in currentDevice!.servicesList) {
          debugPrint(service.uuid.str);
          if (serviceUuid[service.uuid.str] == null) {
            var characteristics = service.characteristics;
            for (var characteristic in characteristics) {
              debugPrint(characteristic.uuid.str);
              await Future.delayed(const Duration(milliseconds: 500));
              characteristic.setNotifyValue(true);
              await Future.delayed(const Duration(milliseconds: 500));
              l.Listener(characteristic, this);
              try {
                await characteristic.write(
                  utf8.encode('2'),
                  withoutResponse:
                      characteristic.properties.writeWithoutResponse,
                );
              } catch (e) {
                debugPrint(e.toString());
              }
            }
          }
        }
      }
    }
    if (currentDevice == null) startScan();
  }

  @override
  void onClose() {
    comSubscription?.cancel();
    super.onClose();
  }
}
