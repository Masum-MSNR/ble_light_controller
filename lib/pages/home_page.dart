import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_page_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (_controller.isScanning.value) {
                return Column(
                  children: [
                    Text(
                      'Searching for BT05',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ],
                );
              } else if (_controller.isConnecting.value) {
                return Column(
                  children: [
                    Text(
                      'Connecting to BT05',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ],
                );
              } else {
                if (_controller.isConnected.value) {
                  if (_controller.isOn.value) {
                    return InkWell(
                      onTap: () {
                        _controller.write('0');
                      },
                      child: Image.asset('assets/images/light_on.png'),
                    );
                  } else {
                    return InkWell(
                      onTap: () {
                        _controller.write('1');
                      },
                      child: Image.asset('assets/images/light_off.png'),
                    );
                  }
                } else {
                  return TextButton(
                    onPressed: () {},
                    child: Text('Retry'),
                  );
                }
              }
            }),
          ],
        ),
      ),
    );
  }
}
