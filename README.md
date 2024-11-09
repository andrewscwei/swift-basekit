# BaseKit [![CI](https://github.com/andrewscwei/swift-basekit/workflows/CI/badge.svg)](https://github.com/andrewscwei/swift-basekit/actions/workflows/ci.yml) [![CD](https://github.com/andrewscwei/swift-basekit/workflows/CD/badge.svg)](https://github.com/andrewscwei/swift-basekit/actions/workflows/cd.yml)

BaseKit is a lightweight Swift library consisting of low level classes, protocols and functions that are essential for adopting the [clean architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) pattern when building iOS/iPadOS/macOS apps.

### Key Features:

- Classes and protocols for implementing the repository pattern, i.e. `Repository`, `DataSource`
- Data containers, i.e. `Reference` and `WeakReference`
- Better data representation via `Either` and `Result` extension
- Protocols for implementing application use cases, i.e. `UseCase` and `Interactor`
- Utility class for accessing `UserDefaults` and `KeyChain`
- Debug tools

## Setup

```sh
# Prepare Ruby environment
$ brew install rbenv ruby-build
$ rbenv install
$ rbenv rehash
$ gem install bundler

# Install fastlane
$ bundle install
```

## Usage

### Adding BaseKit to an Existing Xcode App Project

From Xcode, go to **File** > **Swift Packages** > **Add Package Dependency...**, then enter the Git repo url for BaseKit: https://github.com/andrewscwei/swift-basekit.

### Adding BaseKit to an Existing Xcode App Project as a Local Dependency

Adding BaseKit as a local Swift package allows you to modify its source code as you develop your app, having changes take effect immediately during development without the need to commit changes to Git. You are responsible for documenting any API changes you have made to ensure other projects dependent on BaseKit can migrate easily.

1. Add BaseKit as a submodule to your Xcode project repo (it is recommended to add it to a directory called `Submodules` in the project root):
   ```sh
   $ git submodule add https://github.com/andrewscwei/swift-basekit Submodules/BaseKit
   ```
2. In the Xcode project, drag BaseKit (the directory containing its `Package.swift` file) to the project navigator (the left panel). If you've previously created a `Submodules` directory to store BaseKit (and possibly other submodules your project may depend on), drag BaseKit to the `Submodules` group in the navigator.
   > Once dragged, the icon of the BaseKit directory should turn into one resembling a package. If you are unable to expand the BaseKit directory from the navigator, it is possible you have BaseKit open as a project on Xcode in a separate window. In any case, restarting Xcode should resolve the problem.
3. Add BaseKit as a library to your app target:
   1. From project settings, select your target, then go to **Build Phases** > **Link Binary With Libraries**. Click on the `+` button and add the BaseKit library.

### Adding BaseKit to Another Swift Package as a Dependency

In `Package.swift`, add the following to `dependencies` (for all available versions, see [releases](https://github.com/andrewscwei/swift-basekit/releases)):

```swift
dependencies: [
  .package(url: "https://github.com/andrewscwei/swift-basekit.git", from: "<version>"),
]
```

## Testing

> Ensure that you have installed all destinations listed in the `Fastfile`. For example, a destination such as `platform=iOS Simulator,OS=18.0,name=iPhone 16 Pro` will require that you have installed the iPhone 16 Pro simulator with iOS 18 in Xcode. In the CI environment, all common simulators should be preinstalled (see [About GitHub Hosted Runners](https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners)).

```sh
$ bundle exec fastlane test
```

## Debugging

Internal logging can be enabled by setting the `BASEKIT_DEBUG` environment variable:

1. From Xcode > **Edit Scheme...**
2. Go to **Run** > **Arguments** tab
3. Define `BASEKIT_DEBUG` under **Environment Variables**, set it to any value or simply leave it blank
