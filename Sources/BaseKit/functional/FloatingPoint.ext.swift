import Foundation

extension FloatingPoint {
  public func clamped(in range: ClosedRange<Self>) -> Self {
    range.lowerBound > self ? range.lowerBound : range.upperBound < self ? range.upperBound : self
  }

  public func fractionalPercent(in range: ClosedRange<Self>) -> Self {
    let m = 1 / (range.upperBound - range.lowerBound)
    let b = -range.lowerBound / (range.upperBound - range.lowerBound)

    return m * self + b
  }
}
