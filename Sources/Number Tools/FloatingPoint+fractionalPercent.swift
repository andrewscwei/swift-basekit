extension FloatingPoint {
  public func fractionalPercent(in range: ClosedRange<Self>) -> Self {
    let m = 1 / (range.upperBound - range.lowerBound)
    let b = -range.lowerBound / (range.upperBound - range.lowerBound)

    return m * self + b
  }
}
