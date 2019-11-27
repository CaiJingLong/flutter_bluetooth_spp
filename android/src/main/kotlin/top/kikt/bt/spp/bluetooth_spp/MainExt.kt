package top.kikt.bt.spp.bluetooth_spp

import android.os.Handler
import android.os.Looper

/// create 2019-11-27 by cai

val Any.handler get() = Handler(Looper.getMainLooper())

inline fun Any.runOnMainThread(crossinline runnable: () -> Unit) {
  handler.post {
    runnable()
  }
}