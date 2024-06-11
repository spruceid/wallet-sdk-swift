// File: Logger
//
//    Copy log messages to the system logger.

//
// Imports
//

import Foundation

//
// Code
//

// Class: SpruceKitLogger
//    A logging system for debug purposes.

class SpruceKitLogger: NSObject {
   // Make this a singleton.

   static let shared = SpruceKitLogger()

   // Verbosity

   enum Verbosity: Int {
      case trace
      case info
      case warn
      case error
   }

   var verbosity = .trace

   // Local Method: logRaw()
   //    The core logging interface; all log statements pass through this, so
   // the formatting, decision making &c. are centrallized.  It also means we
   // can mutex if necessary; if we're feeding the system logger, for example,
   // we may need to break a single log string into multiple lines, at which
   // point we'll want some defenses in place against conncurrent logs
   // interleaving.
   //
   // Arguments:
   //    verb   - verbosity for the log
   //    prefix - string to prefix on the log line
   //    text   - the text to be logged

   private func logRaw(verb:   Verbosity,
                       prefix: String,
                       text:   String) {
      if verb.rawValue < verbosity.rawValue { return }

      print("[\(prefix)] \(text)")
   }

   // Method: logTrace()
   //    Log a string at "trace" verbosity.
   //
   // Arguments:
   //    text - the text to log

   func logTrace(text: String) {
      logRaw(verb: .trace, prefix: "Tr", text: text)
   }

   // Method: logInfo()
   //    Log a string at "info" verbosity.
   //
   // Arguments:
   //    text - the text to log

   func logInfo(text: String) {
      logRaw(verb: .info, prefix: "In", text: text)
   }

   // Method: logWarn()
   //    Log a string at "warn" verbosity.
   //
   // Arguments:
   //    text - the text to log

   func logWarn(text: String) {
      logRaw(verb: .warn, prefix: "W?", text: text)
   }

   // Method: logError()
   //    Log a string at "error" verbosity.
   //
   // Arguments:
   //    text - the text to log

   func logError(text: String) {
      logRaw(verb: .error, prefix: "E!", text: text)
   }
}

//
// Copyright © 2024, Spruce Systems, Inc.
//
