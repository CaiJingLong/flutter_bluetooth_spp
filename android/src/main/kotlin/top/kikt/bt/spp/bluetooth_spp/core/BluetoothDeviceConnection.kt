package top.kikt.bt.spp.bluetooth_spp.core

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import android.util.SparseArray
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import top.kikt.bt.spp.bluetooth_spp.DeviceWrapper
import top.kikt.bt.spp.bluetooth_spp.ReplyHandler
import top.kikt.bt.spp.bluetooth_spp.runOnMainThread
import java.io.PrintWriter
import java.io.StringWriter
import java.util.*
import java.util.concurrent.Executors
import java.util.concurrent.locks.ReentrantLock
import kotlin.collections.HashMap
import kotlin.concurrent.withLock

/// create 2019-11-27 by cai
class BluetoothDeviceConnection private constructor(registry: PluginRegistry.Registrar, val index: Int, private val device: DeviceWrapper, private val safeMethod: Boolean = false) : MethodChannel.MethodCallHandler {
  
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
    
    fun buildBluetoothDeviceConnection(registry: PluginRegistry.Registrar, device: DeviceWrapper, safe: Boolean): BluetoothDeviceConnection {
      val index = makeIndex()
      val bluetoothDeviceConnection = BluetoothDeviceConnection(registry, index, device, safe)
      deviceArray.append(index, bluetoothDeviceConnection)
      return bluetoothDeviceConnection
    }
    
    fun findConnect(i: Int): BluetoothDeviceConnection? {
      return deviceArray[i]
    }
    
    fun findConnect(device: DeviceWrapper): BluetoothDeviceConnection? {
      return macMap[device.mac]
    }
    
    fun findConnect(mac: String): BluetoothDeviceConnection? {
      return macMap[mac]
    }
    
    private val macMap = HashMap<String, BluetoothDeviceConnection>()
    
    private val deviceArray = SparseArray<BluetoothDeviceConnection>()
    
    private val threadPool = Executors.newFixedThreadPool(100)
  }
  
  private val channel = MethodChannel(registry.messenger(), "top.kikt/spp/$index")
  
  init {
    channel.setMethodCallHandler(this)
  }
  
  private var socket: BluetoothSocket? = null
  
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val replyHandler = ReplyHandler(call, result)
    when (call.method) {
      "connect" -> {
        connect(replyHandler)
        replyHandler.success(1)
      }
      "disconnect" -> {
        disconnect()
        replyHandler.success(1)
      }
      "dispose" -> {
        dispose()
        replyHandler.success(1)
      }
      "sendData" -> {
        val byteArray = call.arguments<ByteArray>()
        try {
          socket?.outputStream?.write(byteArray)
          replyHandler.success(1)
        } catch (e: Exception) {
          replyHandler.error("发生连接错误")
          throwError(e)
        }
      }
      "isConnected" -> {
        replyHandler.success(isConnected())
      }
    }
  }
  
  private fun disconnect() {
    if (socket?.isConnected == true) {
      socket?.close()
    }
  }
  
  private fun connect(replyHandler: ReplyHandler) {
    val uuid = UUID.fromString(uuidString)
    val bluetoothDevice = device.device
    socket = if (safeMethod) {
      bluetoothDevice.createRfcommSocketToServiceRecord(uuid)
    } else {
      bluetoothDevice.createInsecureRfcommSocketToServiceRecord(uuid)
    }
    
    // 按照connect方法的说明, 连接前应始终停止发现过程, 无论这个发现是否是应用创建的, 这里不判断是否在发现中, 强行停止即可
    BluetoothAdapter.getDefaultAdapter().cancelDiscovery()
    
    try {
      socket?.connect()
    } catch (e: Exception) {
      replyHandler.success(1)
      return
    }
    threadPool.execute {
      val `is` = socket?.inputStream ?: return@execute
      notifyConnectionState()
      while (true) {
        try {
          val bytes = `is`.readBytes()
          notifyBytes(bytes)
        } catch (e: Exception) {
          throwError(e)
          break
        }
      }
    }
  }
  
  private fun isConnected(): Boolean {
    return socket?.isConnected == true
  }
  
  private fun notifyConnectionState() {
    runOnMainThread {
      channel.invokeMethod("state_changed", isConnected())
    }
  }
  
  private fun notifyBytes(bytes: ByteArray) {
    runOnMainThread {
      channel.invokeMethod("rec", bytes)
    }
  }
  
  private fun throwError(e: Exception) {
    runOnMainThread {
      socket = null
      val stringWriter = StringWriter()
      e.printStackTrace(PrintWriter(stringWriter))
      channel.invokeMethod("error", stringWriter.toString())
      notifyConnectionState()
    }
  }
  
  private fun dispose() {
    disconnect()
    deviceArray.remove(index)
    macMap.remove(device.mac)
  }
  
}