// © GHOZT

import Foundation

/// Returns a dummy error meant for development use only.
public let debugError: Error = NSError(domain: "dummy", code: 0, userInfo: [
  NSLocalizedDescriptionKey: "This is a dummy error meant for development use only. Please replace this with an actual error.",
  NSLocalizedFailureErrorKey: "iunno."
])
