import 'dart:io';

import 'package:flutter/foundation.dart';

import 'device_manager.dart';
import 'device.dart';
import 'connection.dart';

class Spp with ChangeNotifier, SppDeviceManager {
  static Spp _instance;

  Spp._() {
    channel.setMethodCallHandler(this.handle);
    supportSpp().then((supportSpp) async {
      if (!supportSpp) {
        return;
      }
      bluetoothEnable = await isEnabled();
      notifyListeners();
    });
  }

  Future<String> get platformVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  factory Spp() {
    _instance ??= Spp._();
    return _instance;
  }

  Future<bool> supportSpp() async {
    if (!Platform.isAndroid) {
      return false;
    }
    return channel.invokeMethod("supportSpp");
  }

  SppDeviceManager get deviceManager => this;

  void enable() {
    channel.invokeMethod("enable");
  }

  void disable() {
    channel.invokeMethod("disable");
  }

  Future<bool> isEnabled() async {
    return (await channel.invokeMethod("isEnabled") == 1);
  }

  void scan() {
    channel.invokeMethod("scan");
  }

  void stopScan() {
    channel.invokeMethod("stop");
  }

  Future<void> refreshBondDevice() async {
    final result = await channel.invokeMethod("getBondDevices");
    List data = result["data"];
    final deviceList =
        data.map((map) => BluetoothSppDevice.fromMap(map)).toList();
    deviceManager.addBondedDevices(deviceList);
  }

  /// key 是 mac address , value 是 Connection
  Map<String, BluetoothSppConnection> connectionMap = {};

  Future<BluetoothSppConnection> connect(
    BluetoothSppDevice device, {
    bool safe = false,
  }) async {
    if (connectionMap[device.mac] != null) {
      return connectionMap[device.mac];
    }
    final connId =
        await channel.invokeMethod("conn", {"mac": device.mac, "safe": safe});
    final connection = BluetoothSppConnection(connId);
    connectionMap[device.mac] = connection;
    device.connection = connection;
    return connection;
  }
}
