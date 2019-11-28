import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bluetooth_spp/bluetooth_spp.dart';
// import 'package:gbk_codec/gbk_codec.dart';
import 'package:fast_gbk/fast_gbk.dart';

class DeviceDetailPage extends StatefulWidget {
  final BluetoothSppDevice device;

  const DeviceDetailPage({
    Key key,
    @required this.device,
  }) : super(key: key);

  @override
  DeviceDetailPageState createState() => DeviceDetailPageState();
}

class DeviceDetailPageState extends State<DeviceDetailPage> {
  BluetoothSppDevice get device => widget.device;
  BluetoothSppConnection get connection => device.connection;

  final ctl = TextEditingController();

  final textList = ValueNotifier(<String>[]);

  void addText(String text) {
    textList.value.add(text);
    textList.notifyListeners();
  }

  @override
  void initState() {
    super.initState();
    device.refreshBluetoothConnectionState().then((_) {
      setState(() {});
    });
    ctl.text = "hello";

    device.addListener(_onGetData);
  }

  @override
  void dispose() {
    device.removeListener(_onGetData);
    ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Column(
        children: <Widget>[
          _buildHeaders(),
          Container(
            height: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: _buildBody(),
          ),
          _buildSendBar(),
        ],
      ),
    );
  }

  Widget _buildHeaders() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(device.name),
          subtitle: Text(device.mac),
          trailing: _buildStateButton(),
        ),
        RaisedButton(
          child: Text("绑定"),
          onPressed: () async {
            await connection.bond("0000");
            print("绑定按钮点击完毕");
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: textList,
      builder: (ctx, list, __) => ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          final text = list[index];
          return ListTile(
            title: Text(text),
          );
        },
      ),
    );
  }

  Widget _buildStateButton() {
    if (connection == null) {
      return null;
    }
    return AnimatedBuilder(
      animation: connection,
      builder: (BuildContext context, Widget child) {
        String stateText = connection.isConnected ? "断开" : "连接";
        return FlatButton(
          child: Text(stateText),
          onPressed: () {
            if (!connection.isConnected) {
              connection.connect();
            } else {
              connection.disconnect();
            }
          },
        );
      },
    );
  }

  Widget _buildSendBar() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        maxLines: 1,
        controller: ctl,
        decoration: InputDecoration(
          fillColor: Colors.black12,
          filled: true,
          contentPadding: EdgeInsets.all(10),
        ),
        onEditingComplete: () async {
          final data = gbk.encode(ctl.text + "\n");
          await connection.sendListData(data);
          addText(ctl.text);
        },
      ),
    );
  }

  void _onGetData(Uint8List value) {
    print("获取到信息 :$value");
  }
}
