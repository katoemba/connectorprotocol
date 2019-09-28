// swift-tools-version:5.0

let package = Package(
    name: "ConnectorProtocol",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ConnectorProtocol",
            targets: ["ConnectorProtocol_iOS", "ConnectorProtocol_MacOS", "ConnectorProtocol_tvOS"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ConnectorProtocol_iOS",
            dependencies: []),
        .target(
            name: "ConnectorProtocol_MacOS",
            dependencies: []),
        .target(
            name: "ConnectorProtocol_tvOS",
            dependencies: []),
        .testTarget(
            name: "ConnectorProtocolTests",
            dependencies: ["ConnectorProtocol_iOS"])
    ]
)
