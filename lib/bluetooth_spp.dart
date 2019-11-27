import 'dart:async';

import 'package:bluetooth_spp/src/device.dart';
import 'package:flutter/services.dart';

import 'src/device_conn.dart';
import 'src/device_service.dart';

export 'src/device_service.dart';
export 'src/device.dart';
export 'src/device_conn.dart';

class BluetoothSpp {
  static BluetoothSpp _instance;

  BluetoothSpp._() {
    deviceService = SppDeviceService.getInstance();
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

  SppDeviceService deviceService;

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

  Future<DeviceConn> connect(BluetoothSppDevice device) async {
    final connId = await _channel.invokeMethod("conn", device.mac);
    return DeviceConn(connId);
  }
}
