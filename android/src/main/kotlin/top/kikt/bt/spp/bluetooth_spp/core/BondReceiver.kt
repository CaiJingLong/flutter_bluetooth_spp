package top.kikt.bt.spp.bluetooth_spp.core

import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import top.kikt.bt.spp.bluetooth_spp.DeviceWrapper
import top.kikt.bt.spp.bluetooth_spp.ReplyHandler
import top.kikt.bt.spp.bluetooth_spp.logger

/// create 2019-11-28 by cai
class BondReceiver(val context: Context, val deviceWrapper: DeviceWrapper, val replyHandler: ReplyHandler, val pin: String) : BroadcastReceiver() {
  
  override fun onReceive(context: Context, intent: Intent) {
    when (intent.action) {
      BluetoothDevice.ACTION_BOND_STATE_CHANGED -> {
        val state = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, -1)
        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
        logger.info("${device.address}, ${device.name},  绑定状态: $state")
        if (state == -1) {
          return
        }
        if (state == BluetoothDevice.BOND_NONE) {
          reportResult(0)
          return
        }
        if (state == BluetoothDevice.BOND_BONDING) {
          logger.info("开始绑定")
          return
        }
        if (state == BluetoothDevice.BOND_BONDED) {
          logger.info("绑定成功")
          reportResult(1)
          return
        }
      }
      BluetoothDevice.ACTION_PAIRING_REQUEST -> {
        logger.info("开始配对")
        deviceWrapper.device.setPin(pin.toByteArray())
      }
    }
  }
  
  private fun reportResult(result: Int) {
    replyHandler.success(result)
    context.unregisterReceiver(this)
  }
}
