import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device_manager.dart';
import 'device.dart';
import 'connection.dart';

class Spp with ChangeNotifier, SppDeviceManager {
  static Spp? _instance;

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
    return _instance!;
  }

  Future<void> requestPermission() async {
    assert(Platform.isAndroid, 'Only Android supported');
    // 其实就是申请权限
    if (!Platform.isAndroid) {
      return;
    }
    // 申请几个权限，蓝牙，位置，蓝牙 Admin
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.location,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    // 没有就直接报错
    statuses.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        throw Exception('Permission ${permission.toString()} not granted');
      }
    });
  }

  Future<bool> supportSpp() async {
    if (!Platform.isAndroid) {
      return false;
    }
    final result = await channel.invokeMethod("supportSpp");
    return result;
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

  /// 增强扫描模式
  ///
  /// 有些设备在正常情况下无法扫描到, 需要先关闭,并开启蓝牙开关才可搜索到
  void enhanceScan() {
    StreamSubscription? sub;
    sub = this.switchStream.listen((_) {
      if (bluetoothEnable) {
        scan();
        sub?.cancel();
      } else {
        enable();
      }
    });
    disable();
  }

  void scan() {
    deviceMap.clear();
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

  Future<BluetoothSppConnection?> connect(
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
