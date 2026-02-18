// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JoinNextMeeting",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "join-next-meeting",
            path: "Sources",
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Info.plist"
                ])
            ]
        )
    ]
)
