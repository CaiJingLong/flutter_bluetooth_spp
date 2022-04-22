package top.kikt.bt.spp.bluetooth_spp.core

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import top.kikt.bt.spp.bluetooth_spp.DeviceWrapper

/// create 2019-11-27 by cai

class BluetoothBroadcastReceiver(var channel: MethodChannel?) : BroadcastReceiver() {

    private val devicesMap = HashMap<String, DeviceWrapper>()

    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                notify("scan_finish")
            }
            BluetoothAdapter.ACTION_DISCOVERY_STARTED -> {
                notify("scan_started")
                devicesMap.clear()
                refreshBondDevice()
            }
            BluetoothAdapter.ACTION_STATE_CHANGED -> {
                onStateChange(intent)
            }
            BluetoothDevice.ACTION_FOUND -> {
                onFoundDevice(intent)
            }
            BluetoothDevice.ACTION_NAME_CHANGED -> {
                onFoundDevice(intent)
            }
        }
    }

    private fun onStateChange(intent: Intent) {
        val value = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1)
        if (value == -1) {
            return
        }
        if (value == BluetoothAdapter.STATE_OFF) {
            notify("state_change", 2)
        } else if (value == BluetoothAdapter.STATE_ON) {
            notify("state_change", 1)
        }
    }

    private fun refreshBondDevice() {
        val devices = BluetoothAdapter.getDefaultAdapter().bondedDevices
        devices.forEach {
            val deviceWrapper = DeviceWrapper(it, it.name, 255)
            devicesMap[it.address] = deviceWrapper
            notifyFoundDevice(deviceWrapper)
        }
    }

    private fun onFoundDevice(intent: Intent?) {
        if (intent == null) {
            return
        }

        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
        val name: String? = intent.getStringExtra(BluetoothDevice.EXTRA_NAME)
        val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, 255)

        val deviceWrapper = DeviceWrapper(device, name, rssi)
        devicesMap[deviceWrapper.mac] = deviceWrapper
        notifyFoundDevice(deviceWrapper)
    }

    private fun notifyFoundDevice(deviceWrapper: DeviceWrapper) {
        notify("found_device", deviceWrapper.toMap())
    }

    private fun notify(methodName: String, params: Any? = emptyMap()) {
        channel?.invokeMethod(methodName, params)
    }

    private fun emptyMap(): Map<String, Any> {
        return kotlin.collections.emptyMap()
    }

    fun findDevice(mac: String): DeviceWrapper? {
        return devicesMap[mac]
    }
}