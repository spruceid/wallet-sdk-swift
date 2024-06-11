// File: PlatformContext
//
//    Store and retrieve sensitive data.  Data is stored in the Application Support directory of the app, encrypted in place
// via the .completeFileProtection option, and marked as excluded from backups so it will not be included in iCloud backps.

//
// Imports
//

import Foundation

//
// Code
//

// Class: SpruceKitPlatformContext
//    A container for platform-specific subsystems.

class SpruceKitPlatformContext: NSObject
{
   let storageMgr = StorageManager() // Secure storage.
}

//
// Copyright © 2024, Spruce Systems, Inc.
//
