#import "BluetoothSppPlugin.h"
#import <bluetooth_spp/bluetooth_spp-Swift.h>

@implementation BluetoothSppPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBluetoothSppPlugin registerWithRegistrar:registrar];
}
@end
