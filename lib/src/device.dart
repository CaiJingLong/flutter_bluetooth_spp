import 'dart:typed_data';

import 'package:bluetooth_spp/bluetooth_spp.dart';
import 'package:flutter/material.dart';
import 'value_change_notifier.dart';

class BluetoothSppDevice {
  /// mac地址
  late String mac;

  /// 名字
  late String name;

  /// rssi信号
  late int rssi;

  /// 绑定状态
  late BondState bondState;

  BluetoothSppConnection? _connection;

  BluetoothSppConnection? get connection => _connection;

  set connection(BluetoothSppConnection? connection) {
    if (_connection == connection) {
      return;
    }
    _connection = connection;
    connection?.device = this;
    connection?.onGetData = this._onGetData;
    connection?.bondState = this.bondState;
  }

  Future<BluetoothSppConnection?> refreshBluetoothConnectionState() async {
    connection = await Spp().connect(this);
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

  void addListener(ValueChanged<Uint8List?> listener) {
    _notifier.addObserver(listener);
  }

  void removeListener(ValueChanged<Uint8List?> listener) {
    _notifier.removeObserver(listener);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothSppDevice &&
          runtimeType == other.runtimeType &&
          mac == other.mac;

  @override
  int get hashCode => mac.hashCode;
}

enum BondState {
  none,
  bonding,
  bonded,
}
