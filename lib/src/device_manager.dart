import 'package:bluetooth_spp/src/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'device.dart';

class SppDeviceManager extends ChangeNotifier {
  static SppDeviceManager _instance;

  SppDeviceManager._();

  factory SppDeviceManager.getInstance() {
    _instance ??= SppDeviceManager._();
    return _instance;
  }

  Map<String, BluetoothSppDevice> deviceMap = {};

  Future<dynamic> handle(MethodCall call) async {
    if (call.method == "scan_started") {
      notifyListeners();
    } else if (call.method == "scan_finish") {
      notifyListeners();
    } else if (call.method == "found_device") {
      final device = BluetoothSppDevice.fromMap(call.arguments);
      print("找到一台新蓝牙设备 : ${device.mac}, name : ${device.name}");
      deviceMap[device.mac] = device;
      notifyListeners();
    }
  }

  void addBondedDevices(List<BluetoothSppDevice> deviceList) {
    deviceList.forEach((device) {
      deviceMap[device.mac] = device;
    });
    notifyListeners();
  }

  List<BluetoothSppDevice> devices() {
    return deviceMap.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }
}
