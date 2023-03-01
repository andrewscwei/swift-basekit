// © GHOZT

import Foundation

/// A `TemperaryFile` binds its in-memory lifecycle to a file in the device
/// filesystem, creating the file on `init` and destroying it on `deinit`. Use
/// `keepAlive()` to delay `TemporaryFile` from being deallocated.
public class TemporaryFile {

  /// URL of the associated file in the device filesystem.
  public let url: URL

  /// Instantiates a `TemporaryFile` object, subsequently creating a file in the
  /// device filesystem at the specified URL.
  ///
  /// - Parameters:
  ///   - baseName: The base name of the file to create, defaults to a random
  ///               `UUID` string.
  ///   - ext: The extension of the file to create (no need to prefix it with a
  ///          period).
  public init(_ baseName: String = UUID().uuidString, extension ext: String) {
    self.url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(baseName).appendingPathExtension(ext)
    log(.debug) { "Creating a temporary file at \(self.url.absoluteString)... OK" }
  }

  /// Deinitializes this object, subsequently removes its associated file from
  /// the device filesystem.
  deinit {
    let path = self.url.absoluteString

    // Remove the file as soon as this object is garbage collected.
    DispatchQueue.global(qos: .utility).async { [url = self.url] in
      do {
        try FileManager.default.removeItem(at: url)
        log(.debug) { "Destroying temporary file at \(path)... OK" }
      }
      catch let error {
        log(.error) { "Destroying temporary file at \(path)... ERR: \(error.localizedDescription)" }
      }
    }
  }

  /// No-op function that can be called just to keep this `TemporaryFile`
  /// instance from being dereferenced (which would otherwise cause its
  /// associated file to be deleted from the device filesystem).
  ///
  /// - SeeAlso: https://en.wikipedia.org/wiki/Resource_acquisition_is_initialization
  public func keepAlive() {}
}
