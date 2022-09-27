package top.kikt.bt.spp.bluetooth_spp

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.IntentFilter
import android.os.Build
import androidx.fragment.app.FragmentActivity
import com.tbruyelle.rxpermissions3.RxPermissions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothBroadcastReceiver
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothDeviceConnection
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothSpp

class BluetoothSppPlugin(private val registrar: Registrar, channel: MethodChannel) :
    MethodCallHandler {

    private val sppPlugin: BluetoothSpp = BluetoothSpp(registrar)
    private val permissions = RxPermissions(registrar.activity() as FragmentActivity)

    private val bluetoothBroadcastReceiver = BluetoothBroadcastReceiver(registrar, channel)

    init {
        registrar.activity().registerReceiver(bluetoothBroadcastReceiver, IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothDevice.ACTION_NAME_CHANGED)
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        })
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "top.kikt/bluetooth_spp")
            channel.setMethodCallHandler(BluetoothSppPlugin(registrar, channel))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val replyHandler = ReplyHandler(call, result)
        when (call.method) {
            "enable" -> {
                checkPermission(replyHandler) {
                    sppPlugin.enable()
                }
            }
            "supportSpp" -> {
                val supportSpp = sppPlugin.supportSpp(registrar.context())
                replyHandler.success(supportSpp)
            }
            "disable" -> {
                checkPermission(replyHandler) {
                    sppPlugin.disable()
                }
            }
            "scan" -> {
                checkPermission(replyHandler) {
                    sppPlugin.startScan()
                }
            }
            "stop" -> {
                checkPermission(replyHandler) {
                    sppPlugin.stopScan()
                }
            }
            "getBondDevices" -> {
                checkPermission(replyHandler) {
                    replyHandler.success(sppPlugin.getBondDevicesList())
                }
            }
            "isEnabled" -> {
                checkPermission(replyHandler) {
                    replyHandler.success(sppPlugin.isEnabled())
                }
            }
            "conn" -> {
                checkPermission(replyHandler) {
                    val mac = call.argument<String>("mac")!!

                    val connect = BluetoothDeviceConnection.findConnect(mac)
                    if (connect != null) {
                        replyHandler.success(connect.index)
                        return@checkPermission
                    }

                    val safe = call.argument<Boolean>("safe") ?: false
                    val device = bluetoothBroadcastReceiver.findDevice(mac)
                    if (device == null) {
                        replyHandler.error("没找到蓝牙设备")
                        return@checkPermission
                    }
                    val connection = BluetoothDeviceConnection.buildBluetoothDeviceConnection(
                        registrar,
                        device,
                        safe
                    )
                    replyHandler.success(connection.index)
                }
            }
            else -> replyHandler.notImplemented()
        }
    }

    @SuppressLint("CheckResult")
    private fun checkPermission(handler: ReplyHandler, runnable: () -> Unit) {
        val info = arrayListOf(
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_LOCATION_EXTRA_COMMANDS,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            info.addAll(
                listOf(
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION,
                )
            )
        }

        if (Build.VERSION.SDK_INT >= 31) {
            info.addAll(
                listOf(
                    Manifest.permission.BLUETOOTH_ADVERTISE,
                    Manifest.permission.BLUETOOTH_SCAN,
                    Manifest.permission.BLUETOOTH_CONNECT,
                )
            )
        }

        permissions.request(*info.toTypedArray())
            .subscribe {
                if (it) {
                    runnable()
                } else {
                    handler.success(-1)
                }
            }
    }
}
