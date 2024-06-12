/// PlatformContext
///
/// The platform context contains platform-specific implementation of
/// subsystems like the secure storage manager or the logger.

import Foundation

/// A container for platform-specific subsystems.

class SpruceKitPlatformContext: NSObject {
   let keyMgr     = KeyManager()
   let logger     = SpruceKitLogger()
   let storageMgr = StorageManager()
}
