import 'dart:async';
import 'dart:convert' show utf8;

import 'package:ble_light_controller/controllers/home_page_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Listener {
  BluetoothCharacteristic characteristic;
  HomePageController deviceController;
  late StreamSubscription<List<int>> subscription;

  Listener(this.characteristic, this.deviceController) {
    subscription = characteristic.lastValueStream.listen((event) {
      var res = utf8.decode(event);
      debugPrint('response $res');
      if (res == '49' || res == '48') {
        deviceController.initiateCommunication(characteristic);
        cancel();
      }
    });
  }

  cancel() {
    subscription.cancel();
  }
}
