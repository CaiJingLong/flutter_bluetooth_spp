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
          _buildSendUint8ListButton(),
          _buildSendBar(),
        ],
      ),
    );
  }

  Widget _buildHeaders() {
    if (connection == null) {
      return Center(
        child: Container(
          height: 40,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return AnimatedBuilder(
      builder: (_, __) => Column(
        children: <Widget>[
          ListTile(
            title: Text(device.name),
            subtitle: Text(device.mac),
            trailing: _buildStateButton(),
          ),
          if (connection.bondState == BondState.bonded)
            Text("绑定成功")
          else
            RaisedButton(
              child: Text("绑定"),
              onPressed: () async {
                await connection.bond("0000");
                print("绑定按钮点击完毕");
              },
            ),
        ],
      ),
      animation: connection,
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
          onPressed: bindAndconnect,
        );
      },
    );
  }

  void bindAndconnect() async {
    if (await connection.getBondStateAsync() != BondState.bonded) {
      // 未绑定, 先进行绑定操作
      await connection.bond("0000");
      if (await connection.getBondStateAsync() != BondState.bonded) {
        print("绑定失败,请重新尝试");
        return;
      }
    }
    if (!connection.isConnected) {
      connection.connect();
    } else {
      connection.disconnect();
    }
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
    // print("获取到信息 :$value");
    final text = gbk.decode(value);
    print("获取到信息:");
    print("$text");
  }

  _buildSendUint8ListButton() {
    return RaisedButton(
      child: Text("发送测试数据"),
      onPressed: () async {
        final data = Uint8List.fromList([0x1D, 0x67, 0x34]);
        await connection.sendData(data);
      },
    );
  }
}
