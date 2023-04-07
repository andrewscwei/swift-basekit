// © GHOZT

import Foundation

extension ClosedRange {
  public func clamp(_ value: Bound) -> Bound {
    lowerBound > value ? lowerBound : upperBound < value ? upperBound : value
  }
}
