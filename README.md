[![bitrise CI](https://img.shields.io/bitrise/d2f7e3b6ab1ea0c5?token=qtI4l__6bRRUTZQb1bD-nw)](https://bitrise.io)
![platforms](https://img.shields.io/badge/platforms-iOS-lightgrey)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)


# README #

## What is this repository for? ##

* ConnectorProtocol is a generic protocol specification to control a network based music player for Swift.
The protocol abstracts a player specific implementation from a client implementation, which allows to have
a single client that supports multiple player types.
* MPDConnector is a full implementation of this protocol for the MPD protocol: https://github.com/katoemba/mpdconnector/
* These two frameworks are the foundation of the Rigelian MPD client, for more info see https://www.rigelian.net

## What are the building blocks of this Protocol? ##

* The protocol relies heavily on reactive constructs, using RxSwift.
* ConnectorProtocol consist of five sub-protocols:
	  * PlayerProtocol defines a basic player, access status, control and browse implementation, plus functions to maintain player-specific settings.
	  * PlayerBrowserProtocol is a generic protocol to detect players on the network.
	  * StatusProtocol is a protocol through which the connection status of a player, as well as the music-playing status can be monitored.
	  * ControlProtocol is a protocol through which commands can be sent to a player, like play, pause, add a song etc.
	  * BrowseProtocol is a protocol through which you can browse through the music on a player. It defines various ViewModels for artists, albums, genres etc.
* A number of basic objects are defined:
	* Album
	* Artist
	* Song
	* Playlist
	* Folder
	* PlayerStatus
* The protocol is meant to be independent of the target platform (iOS, MacOS, tvOS). However testing is only done on iOS.

## Requirements

* Xcode 11
* Swift 5.0

## Installation

libmpdclient-swift is dependent on RxSwift.

Build and usage via swift package manager is supported:

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

The easiest way to add the library is directly from within XCode (11). Alternatively you can create a `Package.swift` file. 

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "MyProject",
  dependencies: [
  .package(url: "https://github.com/katoemba/connectorprotocol.git", from: "1.7.0")
  ],
  targets: [
    .target(name: "MyProject", dependencies: ["connectorprotocol"])
  ]
)
```

## Testing ##

* A very limited set of unit tests is included.

## Who do I talk to? ##

* In case of questions you can contact berrie at rigelian dot net
