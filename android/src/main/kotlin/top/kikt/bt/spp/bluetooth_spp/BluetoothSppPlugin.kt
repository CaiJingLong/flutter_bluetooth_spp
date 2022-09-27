package top.kikt.bt.spp.bluetooth_spp

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothBroadcastReceiver
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothDeviceConnection
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothSpp

class BluetoothSppPlugin(private val registrar: Registrar, channel: MethodChannel) :
    MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {

    private val sppPlugin: BluetoothSpp = BluetoothSpp(registrar)

    private val bluetoothBroadcastReceiver = BluetoothBroadcastReceiver(registrar, channel)

    init {
        registrar.activity().registerReceiver(bluetoothBroadcastReceiver, IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothDevice.ACTION_NAME_CHANGED)
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        })

        registrar.addRequestPermissionsResultListener(this)
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

    private var nextRunnable: (() -> Unit)? = null

    private var replyHandler: ReplyHandler? = null
    private var permissionRequestCode = 0x6969

    @SuppressLint("CheckResult")
    private fun checkPermission(handler: ReplyHandler, runnable: () -> Unit) {

        val info = arrayListOf(
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        )

        if (Build.VERSION.SDK_INT >= 31) {
            info.addAll(
                listOf(
                    Manifest.permission.BLUETOOTH_ADVERTISE,
                    Manifest.permission.BLUETOOTH_SCAN,
                    Manifest.permission.BLUETOOTH_CONNECT,
                )
            )
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            nextRunnable = runnable
            replyHandler = handler

            ActivityCompat.requestPermissions(registrar.activity(),info.toTypedArray(), permissionRequestCode)
        } else {
            runnable()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != permissionRequestCode) {
            return false
        }
        val notGrandPermissions = ArrayList<String>()
        grantResults.forEachIndexed { index, it ->
            if (it != PackageManager.PERMISSION_GRANTED) {
                notGrandPermissions.add(permissions[index])
            }
        }

        if (notGrandPermissions.isNotEmpty()) {
            Log.i("发生权限问题", "未给与 ${notGrandPermissions.toList()} 权限")
            nextRunnable?.invoke()

            nextRunnable = null
            replyHandler = null
            return true
        }

        nextRunnable?.invoke()
        nextRunnable = null
        replyHandler = null

        return true
    }
}
