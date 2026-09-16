// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WeddingApp",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        // Firebase
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.0.0")
        ),
        
        // SwiftUI Animations & UI
        .package(
            url: "https://github.com/airbnb/lottie-ios.git",
            .upToNextMajor(from: "4.0.0")
        ),
        
        // Networking
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            .upToNextMajor(from: "5.7.0")
        ),
        
        // Image caching
        .package(
            url: "https://github.com/SDWebImage/SDWebImage.git",
            .upToNextMajor(from: "5.15.0")
        ),
        
        // Date formatting
        .package(
            url: "https://github.com/MatthewWaller/RelativeDateTimeFormatter.git",
            .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        .target(
            name: "WeddingApp",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "RelativeDateTimeFormatter", package: "RelativeDateTimeFormatter")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "WeddingAppTests",
            dependencies: ["WeddingApp"]
        )
    ]
)
