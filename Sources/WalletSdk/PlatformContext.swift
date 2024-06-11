// File: PlatformContext
//
//    The platform context contains platform-specific implementation of
// subsystems like the secure storage manager or the logger.

//
// Imports
//

import Foundation

//
// Code
//

// Class: SpruceKitPlatformContext
//    A container for platform-specific subsystems.

class SpruceKitPlatformContext: NSObject {
   let keyMgr     = KeyManager()      // Keys.
   let logger     = SpruceKitLogger() // Logging.
   let storageMgr = StorageManager()  // Secure storage.
}

//
// Copyright © 2024, Spruce Systems, Inc.
//
