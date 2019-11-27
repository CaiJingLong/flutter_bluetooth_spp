package top.kikt.bt.spp.bluetooth_spp.core

import android.util.SparseArray
import top.kikt.bt.spp.bluetooth_spp.DeviceWrapper
import java.util.*
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

/// create 2019-11-27 by cai


class BluetoothDeviceConnection private constructor(private val index: Int, private val device: DeviceWrapper, private val safeMethod: Boolean = false) {
  
  init {
    connect()
  }
  
  companion object {
    const val uuidString = "00001101-0000-1000-8000-00805F9B34FB"
    
    private val lock = ReentrantLock()
    private var index = 0
    
    private fun makeIndex(): Int {
      lock.withLock {
        val index = this.index
        this.index++
        return index
      }
    }
    
    fun buildBluetoothDeviceConnection(device: DeviceWrapper): BluetoothDeviceConnection {
      val index = makeIndex()
      val bluetoothDeviceConnection = BluetoothDeviceConnection(index, device)
      deviceArray.append(index, bluetoothDeviceConnection)
      return bluetoothDeviceConnection
    }
    
    private val deviceArray = SparseArray<BluetoothDeviceConnection>()
  }
  
  private fun connect() {
    val uuid = UUID.fromString(uuidString)
    val bluetoothDevice = device.device
    val socket = if (safeMethod) {
      bluetoothDevice.createRfcommSocketToServiceRecord(uuid)
    } else {
      bluetoothDevice.createInsecureRfcommSocketToServiceRecord(uuid)
    }
    
    socket.connect()
  }
  
  fun dispose() {
    deviceArray.remove(index)
  }
  
}