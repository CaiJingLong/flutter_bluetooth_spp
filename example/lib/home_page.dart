import 'package:bluetooth_spp_example/scan_devices.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_spp/bluetooth_spp.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final spp = Spp();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: <Widget>[
            buildStateButton(),
            buildButton("去扫描设备", () => routeWidget(ScanDevicePage())),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text, Function onTap) {
    return RaisedButton(
      child: Text(text),
      onPressed: onTap,
    );
  }

  void routeWidget(Widget widget) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => widget,
        ));
  }

  Widget buildStateButton() {
    return AnimatedBuilder(
      animation: spp,
      builder: (_, __) {
        return CheckboxListTile(
          title: Text("蓝牙是否开启"),
          onChanged: (bool value) {
            if (value) {
              spp.enable();
            } else {
              spp.disable();
            }
          },
          value: spp.bluetoothEnable,
        );
      },
    );
  }
}
