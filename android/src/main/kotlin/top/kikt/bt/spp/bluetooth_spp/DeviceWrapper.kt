package top.kikt.bt.spp.bluetooth_spp

import android.bluetooth.BluetoothDevice

/// create 2019-11-27 by cai


data class DeviceWrapper(val device: BluetoothDevice, val name: String?, val rssi: Short) {
  
  fun toMap(): Map<String, Any> {
    return mapOf(
      "mac" to device.address,
      "name" to (device.name ?: name ?: ""),
      "rssi" to rssi,
      "bondState" to bondStateInt()
    )
  }
  
  private fun bondStateInt(): Int {
    return when (device.bondState) {
      BluetoothDevice.BOND_BONDED -> 2
      BluetoothDevice.BOND_NONE -> 0
      BluetoothDevice.BOND_BONDING -> 1
      else -> -1
    }
  }
  
  val mac: String
    get() = device.address
}