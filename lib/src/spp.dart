import 'package:flutter/services.dart';

import 'device_manager.dart';
import 'device.dart';
import 'connection.dart';

class BluetoothSpp {
  static BluetoothSpp _instance;

  BluetoothSpp._() {
    deviceService = SppDeviceManager.getInstance();
    _channel.setMethodCallHandler(deviceService.handle);
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

  SppDeviceManager deviceService;

  void enable() {
    _channel.invokeMethod("enable");
  }

  void disable() {
    _channel.invokeMethod("disable");
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
    deviceService.addBondedDevices(deviceList);
  }

  Map<String, BluetoothSppConnection> connMap = {};

  Future<BluetoothSppConnection> connect(
    BluetoothSppDevice device, {
    bool safe = false,
  }) async {
    if (connMap[device.mac] != null) {
      return connMap[device.mac];
    }
    final connId =
        await _channel.invokeMethod("conn", {"mac": device.mac, "safe": safe});
    final channel = BluetoothSppConnection(connId);
    connMap[device.mac] = channel;
    device.connectChannel = channel;
    return channel;
  }
}
