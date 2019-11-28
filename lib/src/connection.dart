import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BluetoothSppConnection extends ChangeNotifier {
  final int index;
  final MethodChannel channel;

  var isConnected = false;

  ValueChanged<Uint8List> onGetData;

  BluetoothSppConnection(this.index)
      : channel = MethodChannel("top.kikt/spp/$index") {
    channel.setMethodCallHandler(handle);
  }

  Future<void> connect() async {
    channel.invokeMethod("connect");
  }

  Future<void> disconnect() async {
    channel.invokeMethod("disconnect");
  }

  Future<void> dispose() async {
    super.dispose();
    channel.invokeMethod("dispose");
  }

  Future<void> bond(String pin) async {
    await channel.invokeMethod("bond", {"pin": pin});
  }

  Future<void> sendData(Uint8List data) async {
    if (!await isConnectedAsync()) {
      print("发送失败, 因为没连接");
      return;
    }
    channel.invokeMethod("sendData", data);
  }

  Future<void> sendListData(List<int> data) async {
    await sendData(Uint8List.fromList(data));
  }

  Future<bool> isConnectedAsync() async {
    return channel.invokeMethod("isConnected");
  }

  Future<dynamic> handle(MethodCall call) async {
    switch (call.method) {
      case "rec":
        Uint8List data = call.arguments;
        onGetData?.call(data);
        break;
      case "error":
        print(call.arguments);
        break;
      case "state_changed":
        onStateChange(call.arguments);
        break;
    }
  }

  void onStateChange(arguments) {
    isConnected = arguments;
    print("连接状态改变: $arguments");
    notifyListeners();
  }
}
