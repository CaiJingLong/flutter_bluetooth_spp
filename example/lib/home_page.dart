
import 'package:bluetooth_spp/bluetooth_spp.dart';
import 'package:bluetooth_spp_example/scan_devices.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

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
            buildButton("去扫描设备", routeToScan),
          ],
        ),
      ),
    );
  }

  routeToScan() async {
    if (!await spp.supportSpp()) {
      showToast("不支持spp蓝牙协议");
      return;
    }
    routeWidget(ScanDevicePage());
  }

  Widget buildButton(String text, VoidCallback onTap) {
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
    return FutureBuilder<bool>(
      future: spp.supportSpp(),
      builder: (_, snapshot) {
        if (snapshot.data == true) {
          return AnimatedBuilder(
            animation: spp,
            builder: (_, __) {
              return CheckboxListTile(
                title: Text("蓝牙是否开启"),
                onChanged: (bool? value) {
                  if (value != true) {
                    spp.enable();
                  } else {
                    spp.disable();
                  }
                },
                value: spp.bluetoothEnable,
              );
            },
          );
        } else {
          return Text("该设备不支持 spp");
        }
      },
    );
  }
}
