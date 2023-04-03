// © GHOZT

import Foundation

/// A type of `LiveData` that wraps the transformed value `T` of the output of a
/// `UseCase`.
public class UseCaseLiveData<T: Equatable, U: UseCase>: LiveData<T> {
  private let transform: (U.Output) -> T

  let useCase: U

  /// Creates a new `UseCaseLiveData` instance.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase`.
  ///   - transform: A block that transforms the use case output to the wrapped
  ///                value.
  public init(_ useCase: U, transform: @escaping (U.Output) -> T) {
    self.useCase = useCase
    self.transform = transform

    super.init()
  }

  /// Creates a new `UseCaseLiveData` instance.
  ///
  /// - Parameters:
  ///   - useCase: The `UseCase`.
  public convenience init(_ useCase: U) where U.Output == T {
    self.init(useCase) { $0 }
  }

  /// Interacts with the use case with the specified input. Upon success, the
  /// output will be stored in the wrapped value. If a failure occurred, the
  /// wrapped value will be set to `nil`.
  ///
  /// - Parameters:
  ///   - params: Input for the use case.
  public func interact(params: U.Input) {
    useCase.run(params: params) { result in
      switch result {
      case .failure:
        self.value = nil
      case .success(let data):
        self.value = self.transform(data)
      }
    }
  }

  /// Interacts with the use case with the specified input. Upon success, the
  /// output will be stored in the wrapped value. If a failure occurred, the
  /// wrapped value will be set to `nil`.
  public func interact() where U.Input == Void {
    useCase.run(params: ()) { result in
      switch result {
      case .failure:
        self.value = nil
      case .success(let data):
        self.value = self.transform(data)
      }
    }
  }
}
