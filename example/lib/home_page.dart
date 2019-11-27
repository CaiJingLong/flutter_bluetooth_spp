import 'package:bluetooth_spp_example/scan_devices.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_spp/bluetooth_spp.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final spp = BluetoothSpp();

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
            buildButton("打开", spp.enable),
            buildButton("关闭", spp.disable),
            buildButton("去扫描设备", () => routeWidget(ScanDevicePage())),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text, Function onTap) {
    return FlatButton(
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
}
