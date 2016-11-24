import PackageDescription

var package = Package(
    name: "Overdrive",
    targets: [
        Target(name: "Overdrive"),
        Target(name: "Extensions")
    ],
    exclude: [
      "Sources/Support",
      "Tests/Support"
    ]
)
