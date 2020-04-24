import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluetooth_spp/bluetooth_spp.dart';

void main() {
  const MethodChannel channel = MethodChannel('bluetooth_spp');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {});
}
