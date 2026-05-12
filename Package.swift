// swift-tools-version: 6.2

// © 2025–2026 John Gary Pusey (see LICENSE.md)

import PackageDescription

let swiftSettings: [SwiftSetting] = [.defaultIsolation(nil),
                                     .enableUpcomingFeature("ExistentialAny"),
                                     .enableUpcomingFeature("ImmutableWeakCaptures"),
                                     .enableUpcomingFeature("InferIsolatedConformances"),
                                     .enableUpcomingFeature("InternalImportsByDefault"),
                                     .enableUpcomingFeature("MemberImportVisibility"),
                                     .enableUpcomingFeature("NonisolatedNonsendingByDefault")]

let package = Package(name: "IvorTuning",
                      platforms: [.iOS(.v18),
                                  .macOS(.v15)],
                      products: [.library(name: "IvorTuning",
                                          targets: ["IvorTuning"])],
                      dependencies: [.package(url: "https://github.com/eBardX/XestiNumbers.git",
                                              .upToNextMajor(from: "1.0.0")),
                                     .package(url: "https://github.com/eBardX/XestiTools.git",
                                              .upToNextMajor(from: "7.4.0"))],
                      targets: [.target(name: "IvorTuning",
                                        dependencies: [.product(name: "XestiNumbers",
                                                                package: "XestiNumbers"),
                                                       .product(name: "XestiTools",
                                                                package: "XestiTools")],
                                        swiftSettings: swiftSettings),
                                .testTarget(name: "IvorTuningTests",
                                            dependencies: [.target(name: "IvorTuning"),
                                                           .product(name: "XestiNumbers",
                                                                    package: "XestiNumbers"),
                                                           .product(name: "XestiTools",
                                                                    package: "XestiTools")],
                                            swiftSettings: swiftSettings)],
                      swiftLanguageModes: [.v6])
