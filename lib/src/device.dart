class BluetoothSppDevice {
  /// mac地址
  String mac;

  /// 名字
  String name;

  /// rssi信号
  int rssi;

  /// 绑定状态
  BondState bondState;

  BluetoothSppDevice.fromMap(Map<dynamic, dynamic> map) {
    this.mac = map["mac"];
    this.name = map["name"];
    this.rssi = map["rssi"];
    this.bondState = BondState.values[map["bondState"]];
  }
}

enum BondState {
  none,
  bonding,
  bonded,
}
