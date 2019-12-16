package top.kikt.bt.spp.bluetooth_spp.core

import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.plugin.common.PluginRegistry
import top.kikt.bt.spp.bluetooth_spp.DeviceWrapper
import top.kikt.bt.spp.bluetooth_spp.logger

/// create 2019-11-27 by cai
class BluetoothSpp(val registrar: PluginRegistry.Registrar) {
  
  private val adapter = BluetoothAdapter.getDefaultAdapter()
  
  fun enable() {
    logger.info("bluetooth enable: ${adapter.isEnabled}")
    if (!adapter.isEnabled) {
      adapter.enable()
    }
  }
  
  fun disable() {
    logger.info("bluetooth enable: ${adapter.isEnabled}")
    if (adapter.isEnabled) {
      adapter.disable()
    }
  }
  
  fun startScan() {
    if (!adapter.isDiscovering) {
      adapter.startDiscovery()
    } else {
      adapter.cancelDiscovery()
      adapter.startDiscovery()
    }
  }
  
  fun stopScan() {
    if (adapter.isDiscovering) {
      adapter.cancelDiscovery()
    }
  }
  
  fun getBondDevice(): List<DeviceWrapper> {
    val bondedDevices = BluetoothAdapter.getDefaultAdapter().bondedDevices
    return bondedDevices.map {
      DeviceWrapper(it, it.name, 255)
    }
  }
  
  fun getBondDevicesList(): Map<String, Any> {
    val resultList = getBondDevice().map {
      it.toMap()
    }
    return mapOf(
      "data" to resultList
    )
  }
  
  fun isEnabled(): Int {
    return if (adapter?.isEnabled == true) 1 else 0
  }
  
  fun supportSpp(context: Context): Boolean {
    val pm = context.packageManager
    return pm.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) || BluetoothAdapter.getDefaultAdapter() == null
  }
}