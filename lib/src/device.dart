import 'dart:typed_data';

import 'package:bluetooth_spp/bluetooth_spp.dart';
import 'package:flutter/material.dart';
import 'connection.dart';
import 'value_change_notifier.dart';

class BluetoothSppDevice {
  /// mac地址
  String mac;

  /// 名字
  String name;

  /// rssi信号
  int rssi;

  /// 绑定状态
  BondState bondState;

  BluetoothSppConnection _connection;

  BluetoothSppConnection get connection => _connection;

  set connection(BluetoothSppConnection connection) {
    _connection = connection;
    connection.onGetData = this._onGetData;
  }

  Future<BluetoothSppConnection> refreshBluetoothConnection() async {
    connection = await BluetoothSpp().connect(this);
    return connection;
  }

  BluetoothSppDevice.fromMap(Map<dynamic, dynamic> map) {
    this.mac = map["mac"];
    this.name = map["name"];
    this.rssi = map["rssi"];
    this.bondState = BondState.values[map["bondState"]];
  }

  ValueChangeNotifier<Uint8List> _notifier = ValueChangeNotifier();

  void _onGetData(Uint8List value) {
    _notifier.changeValue(value);
  }

  void addListener(ValueChanged<Uint8List> listener) {
    _notifier.addObserver(listener);
  }

  void removeListener(ValueChanged<Uint8List> listener) {
    _notifier.removeObserver(listener);
  }
}

enum BondState {
  none,
  bonding,
  bonded,
}
