import Foundation
import PackagePlugin

/// Regenerates the symbol name constants of the SFSymbols target:
/// - `SFSymbols+SystemSymbolName.swift` from the name list of the SF Symbols app;
/// - `SFSymbols+PrivateSystemSymbolName.swift` from the private symbol set (CoreGlyphsPrivate.bundle) of the running macOS.
///
/// Run it from the package's context menu in Xcode, or from the package root with
/// `swift package --allow-writing-to-package-directory generate-symbol-names`.
/// Pass `--beta` to read the public names from SF Symbols beta.app instead of SF Symbols.app.
@main
struct GenerateSymbolNames: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        var argumentExtractor = ArgumentExtractor(arguments)
        // Xcode passes the targets picked in its plugin dialog as `--target` options. The plugin always regenerates the
        // SFSymbols target, so the picked targets do not matter.
        _ = argumentExtractor.extractOption(named: "target")
        let readsBetaApp = argumentExtractor.extractFlag(named: "beta") > 0
        guard argumentExtractor.remainingArguments.isEmpty else {
            throw GenerationError("Unknown arguments: \(argumentExtractor.remainingArguments.joined(separator: " "))")
        }

        let sourcesDirectoryURL = try context.package.targets(named: ["SFSymbols"])[0].directoryURL

        let symbolsAppURL = URL(filePath: readsBetaApp ? "/Applications/SF Symbols beta.app" : "/Applications/SF Symbols.app")
        let symbolsAppVersion = Bundle(url: symbolsAppURL)?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown version"
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion

        // Read and check both lists before writing either file, so that a failure leaves both files as they were.
        let publicSymbolNameList = try SymbolNameList(contentsOf: symbolsAppURL.appending(path: "Contents/Resources/Metadata/name_availability.plist"))
        let privateSymbolNameList = try SymbolNameList(contentsOf: URL(filePath: "/System/Library/CoreServices/CoreGlyphsPrivate.bundle/Contents/Resources/name_availability.plist"))

        try write(
            publicSymbolNameList,
            describedAs: "SF Symbols \(symbolsAppVersion)",
            extending: "SFSymbols.SystemSymbolName",
            compilationCondition: nil,
            into: sourcesDirectoryURL.appending(path: "SFSymbols+SystemSymbolName.swift")
        )
        try write(
            privateSymbolNameList,
            describedAs: "CoreGlyphsPrivate.bundle of macOS \(systemVersion.majorVersion).\(systemVersion.minorVersion)",
            extending: "SFSymbols.PrivateSystemSymbolName",
            compilationCondition: "SFSYMBOLS_PRIVATE",
            into: sourcesDirectoryURL.appending(path: "SFSymbols+PrivateSystemSymbolName.swift")
        )
    }

    private func write(_ symbolNameList: SymbolNameList, describedAs sourceDescription: String, extending typeName: String, compilationCondition: String?, into outputURL: URL) throws {
        let previousSymbolNames = SymbolNameList.symbolNames(inGeneratedSourceAt: outputURL)

        let swiftSource = symbolNameList.swiftSource(extending: typeName, generatedFrom: sourceDescription, compilationCondition: compilationCondition)
        do {
            try swiftSource.write(to: outputURL, atomically: true, encoding: .utf8)
        } catch {
            throw GenerationError("Cannot write \(outputURL.path): \(error.localizedDescription)")
        }

        let symbolNames = Set(symbolNameList.entries.map(\.symbolName))
        print("\(outputURL.lastPathComponent): \(symbolNames.count) names from \(sourceDescription), \(symbolNames.subtracting(previousSymbolNames).count) added, \(previousSymbolNames.subtracting(symbolNames).count) removed")
    }
}

struct GenerationError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
