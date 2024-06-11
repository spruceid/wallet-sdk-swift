// File: PlatformContext
//
// $LICENSE_BLOCK
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

// Function: SpruceKitStorageAdd()
//    Add an item to secure storage.
//
// Arguments:
//    context - the SpruceKit context object
//    key     - the name of the data to store
//    value   - the data to store
//
// Returns:
//    Success (true) or failure (false).

func SpruceKitStorageAdd(context: SpruceKitPlatformContext,
                         key:     String,
                         value:   Data) -> Bool
{
   return context.storageMgr.add(key: key, value: value)
}

// Function: SpruceKitStorageGet()
//    Get an item from secure storage.
//
// Arguments:
//    context - the SpruceKit context object
//    key     - the name of the data to retrieve
//
// Returns:
//    The data stored under the given key.  The returned data is optional;
// if the requested key is not found, `nil` will be returned.

func SpruceKitStorageGet(context: SpruceKitPlatformContext,
                         key:     String) -> Data?
{
   return context.storageMgr.get(key: key)
}

// Function: SpruceKitStorageRemove()
//    Remove an item from secure storage.
//
// Arguments:
//    context - the SpruceKit context object
//    key     - the name of the data to remove
//
// Returns:
//    Success (true) or failure (false).

func SpruceKitStorageRemove(context: SpruceKitPlatformContext,
                            key:     String) -> Bool
{
   return context.storageMgr.remove(key: key)
}

//
// Copyright © 2024, Spruce Systems, Inc.
//
