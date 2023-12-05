import 'dart:io';

import 'package:ble_light_controller/pages/home_page.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var androidInfo = await DeviceInfoPlugin().androidInfo;
  if (androidInfo.version.sdkInt <= 30) {
    [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(const MyApp());
    });
  } else if (Platform.isAndroid && androidInfo.version.sdkInt >= 31) {
    [Permission.bluetoothConnect, Permission.bluetoothScan, Permission.location]
        .request()
        .then((status) {
      runApp(const MyApp());
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ble Light Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
