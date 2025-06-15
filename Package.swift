// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContextMenu",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ContextMenu",
            targets: ["ContextMenu"]),
    ],
    targets: [
        .target(
            name: "ContextMenu",
            path: "Sources"
        ),
        .testTarget(
            name: "ContextMenuTests",
            dependencies: ["ContextMenu"]
        ),
    ]
)


//let package = Package(
//    name: "ContextMenu",
//    platforms: [
//        .iOS(.v14)
//    ],
//    products: [
//        // Products define the executables and libraries a package produces, making them visible to other packages.
//        .library(
//            name: "ContextMenu",
//            targets: ["ContextMenu"]),
//    ],
//    targets: [
//        .target(
//            name: "ContextMenu",
//            path: "Sources/ContextMenu"
//        ),
//        .testTarget(
//            name: "ContextMenuTests",
//            dependencies: ["ContextMenu"]
//        ),
//    ]
//)
