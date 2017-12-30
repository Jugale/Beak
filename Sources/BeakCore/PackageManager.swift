import Foundation
import PathKit

public class PackageManager {

    public let name: String
    public let beakFile: BeakFile
    public let functionCall: String

    public init(name: String, beakFile: BeakFile, functionCall: String) {
        self.name = name
        self.beakFile = beakFile
        self.functionCall = functionCall
    }

    public func write(path: Path) throws {
        try path.mkpath()

        let swiftFile = beakFile.contents + "\n\n" + functionCall
        let swiftFilePath = path + "Sources/\(name)/main.swift"
        try swiftFilePath.parent().mkpath()
        try swiftFilePath.write(swiftFile)

        let package = createPackage()
        try (path + "Package.Swift").write(package)
    }

    public func createPackage() -> String {
        let dependenciesString = beakFile.dependencies.map { ".package(url: \($0.package.quoted), \($0.requirement))," }.joined(separator: "\n")
        let librariesString = beakFile.libraries.map { $0.quoted }.joined(separator: "\n")
        return """
        // swift-tools-version:4.0

        import PackageDescription

        let package = Package(
            name: \(name.quoted),
            dependencies: [
            \(dependenciesString)],
            targets: [
                .target(
                    name: \(name.quoted),
                    dependencies: [
                        \(librariesString)]
                )
            ]
        )
        """
    }
}