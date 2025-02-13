extension FloatingPoint {
  public func clamped(in range: ClosedRange<Self>) -> Self {
    range.lowerBound > self ? range.lowerBound : range.upperBound < self ? range.upperBound : self
  }
}
