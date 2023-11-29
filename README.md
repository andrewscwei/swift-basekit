# BaseKit [![CI](https://github.com/ghoztsys/swift-basekit/workflows/CI/badge.svg?branch=master)](https://github.com/ghoztsys/swift-basekit/actions/workflows/ci.yml?query=branch%3Amain)

BaseKit is a lightweight Swift library consisting of low level functions, classes and protocols that are essential for adopting the clean architecture pattern in building iOS/iPadOS/macOS apps.

### Key Features:

- classes and protocols for implementing the repository pattern, i.e. `Repository`, `DataSource`
- observable data containers, i.e. `LiveData`, `Reference` and `WeakReference`
- better data representation via `Either` and `Result` extension
- protocols for implementing application use cases, i.e. `UseCase` and `Interactor`
- utility class for accessing `UserDefaults` and `KeyChain`
- debug tools

## Setup

```sh
$ bundle install

# Run tests
$ bundle exec fastlane test
```

## Usage

### Adding BaseKit to an Existing Xcode App Project

From Xcode, go to **File** > **Swift Packages** > **Add Package Dependency...**, then enter the Git repo url for BaseKit: https://github.com/ghoztsys/swift-basekit.

### Adding BaseKit to an Existing Xcode App Project as a Local Dependency

Adding BaseKit as a local Swift package allows you to modify its source code as you develop your app, having changes take effect immediately during development without the need to commit changes to Git. You are responsible for documenting any API changes you have made to ensure other projects dependent on BaseKit can migrate easily.

1. Add BaseKit as a submodule to your Xcode project repo (it is recommended to add it to a directory called `Submodules` in the project root):
    ```sh
    $ git submodule add https://github.com/ghoztsys/swift-basekit Submodules/BaseKit
    ```
2. In the Xcode project, drag BaseKit (the directory containing its `Package.swift` file) to the project navigator (the left panel). If you've previously created a `Submodules` directory to store BaseKit (and possibly other submodules your project may depend on), drag BaseKit to the `Submodules` group in the navigator.
    > Once dragged, the icon of the BaseKit directory should turn into a one resembling a package. If you are unable to expand the BaseKit directory from the navigator, it is possible you have BaseKit open as a project on Xcode in a separate window. In any case, restarting Xcode should solve the problem.
3. Add BaseKit as a library to your app target:
    1. From project settings, select your target, then go to **Build Phases** > **Link Binary With Libraries**. Click on the `+` button and add the BaseKit library.

### Adding BaseKit to Another Swift Package

In `Package.swift`, add the following to `dependencies`:

```swift
dependencies: [
  .package(name: "BaseKit", url: "git@github.com:ghoztsys/swift-basekit", from: "0.25.0")
]
```

