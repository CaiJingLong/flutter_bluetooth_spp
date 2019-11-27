import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class ConnectChannel {
  final int index;
  final MethodChannel channel;
  ConnectChannel(this.index) : channel = MethodChannel("top.kikt/spp/$index") {
    channel.setMethodCallHandler(handle);
  }

  Future<void> connect() async {
    channel.invokeMethod("connect");
  }

  Future<void> disconnect() async {
    channel.invokeMethod("disconnect");
  }

  Future<void> dispose() async {
    channel.invokeMethod("dispose");
  }

  Future<void> sendData(Uint8List data) async {
    channel.invokeMethod("sendData", data);
  }

  Future<bool> isConnected() async {
    return channel.invokeMethod("isConnected");
  }

  Future<dynamic> handle(MethodCall call) async {
    switch (call.method) {
      case "rec":
        Uint8List data = call.arguments;
        onGetData(data);
        break;
      case "error":
        print(call.arguments);
        break;
    }
  }

  void onGetData(Uint8List data) {
    print("接受到消息: $data");
  }
}
