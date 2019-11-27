package top.kikt.bt.spp.bluetooth_spp

import android.util.Log

/// create 2019-11-27 by cai

class Logger(val any: Any) {
  
  private val tag = any.javaClass.simpleName
  
  fun verbose(any: Any?) {
    Log.v(tag, any?.toString())
  }
  
  fun info(any: Any?) {
    Log.i(tag, any?.toString())
  }
  
  fun debug(any: Any?) {
    Log.d(tag, any?.toString())
  }
  
  fun warning(any: Any?) {
    Log.w(tag, any?.toString())
  }
  
  fun error(any: Any?) {
    Log.e(tag, any?.toString())
  }
  
}

val Any.logger: Logger
  get() = Logger(this)