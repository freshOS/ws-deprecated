// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ws",
    platforms: [.iOS(.v13)],
    products: [.library(name: "ws", targets: ["ws"])],
    dependencies: [
        .package(url: "https://github.com/freshOS/Arrow", .exact("5.1.2")),
        .package(url: "https://github.com/Alamofire/Alamofire", .exact("4.9.1"))
    ],
    targets: [
        .target(name: "ws", dependencies:["Arrow", "Alamofire"]),
        .testTarget(name: "wsTests", dependencies: ["ws"])
    ]
)
