// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftServer",
    platforms: [
        .macOS(.v12)
    ],
    // Package.swift
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/tmandry/AXSwift", from: "0.3.0"),
        .package(
            url: "https://github.com/Flight-School/AnyCodable",
            from: "0.6.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "SwiftServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "AXSwift", package: "AXSwift"),
                .product(name: "AnyCodable", package: "AnyCodable"),
            ],
            path: "Sources/SwiftServer"
        )
    ]
)
