package top.kikt.bt.spp.bluetooth_spp

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.IntentFilter
import android.os.Build
import androidx.fragment.app.FragmentActivity
import com.tbruyelle.rxpermissions2.RxPermissions
import com.tbruyelle.rxpermissions2.RxPermissionsFragment
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothBroadcastReceiver
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothDeviceConnection
import top.kikt.bt.spp.bluetooth_spp.core.BluetoothSpp

class BluetoothSppPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        const val channelName = "top.kikt/bluetooth_spp"
    }

    var binding: FlutterPlugin.FlutterPluginBinding? = null

    var appContext: Context? = null

    lateinit var permissions: RxPermissions

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        val channel = MethodChannel(binding.binaryMessenger, channelName)
        if (bluetoothBroadcastReceiver == null) {
            bluetoothBroadcastReceiver = BluetoothBroadcastReceiver(channel)
            binding.applicationContext.registerReceiver(bluetoothBroadcastReceiver, intentFilter)
        } else {
            bluetoothBroadcastReceiver?.channel = channel
            binding.applicationContext.registerReceiver(bluetoothBroadcastReceiver, intentFilter)
        }

//        permissions = binding.
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        bluetoothBroadcastReceiver?.channel = null
        binding.applicationContext.unregisterReceiver(bluetoothBroadcastReceiver)
        this.binding = null
    }

    private val sppPlugin: BluetoothSpp = BluetoothSpp();

    private var bluetoothBroadcastReceiver: BluetoothBroadcastReceiver? = null

    private val intentFilter = IntentFilter().apply {
        addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
        addAction(BluetoothDevice.ACTION_FOUND)
        addAction(BluetoothDevice.ACTION_NAME_CHANGED)
        addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
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
                if (appContext != null) {
                    val supportSpp = sppPlugin.supportSpp(appContext!!)
                    replyHandler.success(supportSpp)
                } else {
                    replyHandler.success(false)
                }
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
                    val device = bluetoothBroadcastReceiver?.findDevice(mac)
                    if (device == null) {
                        replyHandler.error("没找到蓝牙设备")
                        return@checkPermission
                    }
                    if (binding != null) {
                        val context = binding!!.applicationContext
                        val messenger = binding!!.binaryMessenger
                        val connection = BluetoothDeviceConnection.buildBluetoothDeviceConnection(context, messenger, device, safe)
                        replyHandler.success(connection.index)
                    } else {
                        replyHandler.error("没找到蓝牙设备")
                    }
                }
            }
            else -> replyHandler.notImplemented()
        }
    }

    @SuppressLint("CheckResult")
    private fun checkPermission(handler: ReplyHandler, runnable: () -> Unit) {
//        val info = arrayListOf(
//                Manifest.permission.BLUETOOTH,
//                Manifest.permission.BLUETOOTH_ADMIN,
//                Manifest.permission.ACCESS_FINE_LOCATION)
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            info.add(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
//        }
//
//        permissions.request(*info.toTypedArray())
//                .subscribe {
//                    if (it) {
//                        runnable()
//                    } else {
//                        handler.success(-1)
//                    }
//                }
        runnable()
    }

}
