import 'package:flutter/services.dart';

import 'device_manager.dart';
import 'device.dart';
import 'connection.dart';

class BluetoothSpp {
  static BluetoothSpp _instance;

  BluetoothSpp._() {
    deviceManager = SppDeviceManager.getInstance();
    _channel.setMethodCallHandler(deviceManager.handle);
  }

  static const MethodChannel _channel =
      const MethodChannel('top.kikt/bluetooth_spp');

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  factory BluetoothSpp() {
    _instance ??= BluetoothSpp._();
    return _instance;
  }

  SppDeviceManager deviceManager;

  void enable() {
    _channel.invokeMethod("enable");
  }

  void disable() {
    _channel.invokeMethod("disable");
  }

  static Future<bool> isEnabled() async {
    return (await _channel.invokeMethod("isEnabled") == 1);
  }

  void scan() {
    _channel.invokeMethod("scan");
  }

  void stopScan() {
    _channel.invokeMethod("stop");
  }

  Future<void> refreshBondDevice() async {
    final result = await _channel.invokeMethod("getBondDevices");
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
        await _channel.invokeMethod("conn", {"mac": device.mac, "safe": safe});
    final connection = BluetoothSppConnection(connId);
    connectionMap[device.mac] = connection;
    device.connection = connection;
    return connection;
  }
}
