// © Sybl

import Foundation

extension NSObject {

  /// Returns the class name of this object.
  public class var className: String {
    return String(describing: self).components(separatedBy: ".").last!
  }
}
