import PackageDescription

var package = Package(
    name: "Overdrive",
    targets: [
        Target(
            name: "Overdrive"),
        Target(
            name: "TestSupport",
            dependencies: [ "Overdrive" ]),
        Target(
            name: "OverdriveTests",
            dependencies: [ "TestSupport" ]
        )
    ],
    exclude: [ 
      "Sources/Support",
      "Tests/Support"
    ]
)
