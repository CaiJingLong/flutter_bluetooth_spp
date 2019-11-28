import 'package:bluetooth_spp/bluetooth_spp.dart';
import 'package:bluetooth_spp/src/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'device.dart';

mixin SppDeviceManager on ChangeNotifier {
  MethodChannel channel = const MethodChannel('top.kikt/bluetooth_spp');

  Map<String, BluetoothSppDevice> deviceMap = {};

  bool _bluetoothEnable = false;

  bool get bluetoothEnable => _bluetoothEnable;

  set bluetoothEnable(bool bluetoothEnable) {
    _bluetoothEnable = bluetoothEnable;
    if (!bluetoothEnable) {
      deviceMap.clear();
      return;
    }
  }

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
    } else if (call.method == "state_change") {
      print("蓝牙状态改变: ${call.arguments}");
      bluetoothEnable = call.arguments == 1;
      // bluetoothEnable = await BluetoothSpp().isEnabled();
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
