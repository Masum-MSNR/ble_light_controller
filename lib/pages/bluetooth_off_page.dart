import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

//this page will be called when Bluetooth is off
class BluetoothOffPage extends StatelessWidget {
  const BluetoothOffPage({Key? key, this.state}) : super(key: key);

  final BluetoothAdapterState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(22) : 'not available'}.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                FlutterBluePlus.turnOn();
              },
              child: const Text('Turn On Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }
}
