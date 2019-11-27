import 'package:flutter/material.dart';
import 'package:bluetooth_spp/bluetooth_spp.dart';

class ScanDevicePage extends StatefulWidget {
  @override
  _ScanDevicePageState createState() => _ScanDevicePageState();
}

class _ScanDevicePageState extends State<ScanDevicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("扫描"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: _stopScan,
          ),
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: _scan,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: SppDeviceService.getInstance(),
        builder: (ctx, w) => _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    final devices = SppDeviceService.getInstance().devices();
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (BuildContext context, int index) {
        final device = devices[index];
        return ListTile(
          title: Text(device.name),
          subtitle: Text(device.mac),
          trailing: Text("rssi:${device.rssi.toString()}"),
          leading: SizedBox.fromSize(
            size: Size.square(30),
            child: _buildState(device.bondState),
          ),
        );
      },
    );
  }

  Widget _buildState(BondState bondState) {
    IconData data = Icons.radio_button_unchecked;
    if (bondState == BondState.bonding) {
      return Center(
        child: Container(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (bondState == BondState.bonded) {
      data = Icons.radio_button_checked;
    }
    return Icon(data);
  }

  void _scan() async {
    await BluetoothSpp().refreshBondDevice();
    BluetoothSpp().scan();
  }

  void _stopScan() {
    BluetoothSpp().stopScan();
  }
}
