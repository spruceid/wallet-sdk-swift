// File: Storage Manager
//
//    Store and retrieve sensitive data.  Data is stored in the Application Support directory of the app, encrypted in place
// via the .completeFileProtection option, and marked as excluded from backups so it will not be included in iCloud backps.

//
// Imports
//

import Foundation

// import SpruceIDMobileSdkRs

//    The following is a stripped-down version of the protocol definition from mobile-sdk-rs against which the storage
// manager is intended to link.

/*
public typealias Key = String
public typealias Value = Data

public enum StorageManagerError: Error {
    case InvalidLookupKey
    case CouldNotDecryptValue
    case StorageFull
    case CouldNotMakeKey
    case InternalError
}

public protocol StorageManagerInterface: AnyObject {
    func add(key: Key, value: Value) throws
    func get(key: Key) throws -> Value
    func list() -> [Key]
    func remove(key: Key) throws
}
*/

//
// Code
//

// Class: StorageManager
//    Store and retrieve sensitive data.

class StorageManager: NSObject, StorageManagerInterface {
    // Local-Method: path()
    //    Get the path to the application support dir, appending the given file name to it.  We use the application support
    // directory because its contents are not shared.
    //
    // Arguments:
    //    file - the name of the file
    //
    // Returns:
    //    An URL for the named file in the app's Application Support directory.

    private func path(file: String) -> URL? {
        do {
            //    Get the applications support dir, and tack the name of the thing we're storing on the end of it.  This does
            // imply that `file` should be a valid filename.

            let fm = FileManager.default
            let bundle = Bundle.main

            let asdir = try fm.url(for: .applicationSupportDirectory,
                                   in: .userDomainMask,
                                   appropriateFor: nil, // Ignored
                                   create: true) // May not exist, make if necessary.

            //    If we create subdirectories in the application support directory, we need to put them in a subdir named
            // after the app; normally, that's `CFBundleDisplayName` from `info.plist`, but that key doesn't have to be
            // set, in which case we need to use `CFBundleName`.

            guard let appname = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            else {
                return nil
            }

            let datadir = asdir.appending(path: "\(appname)/sprucekit/datastore/", directoryHint: .isDirectory)

            if !fm.fileExists(atPath: datadir.path) {
                try fm.createDirectory(at: datadir, withIntermediateDirectories: true, attributes: nil)
            }

            return datadir.appendingPathComponent(file)
        } catch {
            return nil
        }
    }

    // Method: add()
    //    Store a value for a specified key, encrypted in place.
    //
    // Arguments:
    //     key   - the name of the file
    //     value - the data to store
    //
    // Returns:
    //    A boolean indicating success.

    func add(key: Key, value: Value) throws {
        guard let file = path(file: key) else { return }

        do {
            try value.write(to: file, options: .completeFileProtection)
        } catch {
            throw StorageManagerError.InternalError
        }
    }

    // Method: get()
    //    Get a value for the specified key.
    //
    // Arguments:
    //    key - the name associated with the data
    //
    // Returns:
    //    Optional data potentially containing the value associated with the key; may be `nil`.

    func get(key: Key) throws -> Value {
        guard let file = path(file: key) else { return Data() }

        do {
            let d = try Data(contentsOf: file)
            return d
        } catch {
            throw StorageManagerError.InternalError
        }
    }

    // Method: list()
    //    List the the items in storage.  Note that this will list all items in the `application support` directory,
    // potentially including any files created by other systems.
    //
    // Returns:
    //    A list of items in storage.

    func list() -> [Key] {
        guard let asdir = path(file: "")?.path else { return [String]() }

        do {
            return try FileManager.default.contentsOfDirectory(atPath: asdir)
        } catch {
            return [String]()
        }
    }

    // Method: remove()
    //    Remove a key/value pair. Removing a nonexistent key/value pair is not an error.
    //
    // Arguments:
    //    key - the name of the file
    //
    // Returns:
    //    A boolean indicating success; at present, there is no failure path, but this may change in the future.

    func remove(key: Key) throws {
        guard let file = path(file: key) else { return }

        do {
            try FileManager.default.removeItem(at: file)
        } catch {
            // It's fine if the file isn't there.
        }
    }

    // Method: sys_test()
    //    Check to see if everything works.

    /*
    func sys_test() {
        let key = "test_key"
        let value = Data("Some random string of text. 😎".utf8)

        do {
            try add(key: key, value: value)
        } catch {
            print("\(classForCoder):\(#function): Failed add() value for key.")
            return
        }

        let keys = list()

        print("Keys:")
        for k in keys {
            print("  \(k)")
        }

        do {
            let payload = try get(key: key)

            if !(payload == value) {
                print("\(classForCoder):\(#function): Mismatch between stored & retrieved value.")
                return
            }
        } catch {
            print("\(classForCoder):\(#function): Failed get() value for key.")
            return
        }

        do {
            try remove(key: key)
        } catch {
            print("\(classForCoder):\(#function): Failed remove() value for key.")
            return
        }

        print("\(classForCoder):\(#function): Completed successfully.")
        }
     */
}

//
// Copyright © 2024, Spruce Systems, Inc.
//
