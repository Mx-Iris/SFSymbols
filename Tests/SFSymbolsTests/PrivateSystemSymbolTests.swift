#if SFSYMBOLS_PRIVATE

#if canImport(AppKit) && os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI) && SFSYMBOLS_SWIFTUI
import SwiftUI
#endif
import Testing
import SFSymbols

@Suite("Private system symbols")
struct PrivateSystemSymbolTests {
    @Test("nsuiImage loads a symbol that only the private symbol set has", arguments: ["airdrop", "persona"])
    func loadsPrivateOnlySymbol(_ rawName: String) throws {
        try #require(publicSystemSymbolImage(named: rawName) == nil, "The public API loads \(rawName), so it proves nothing")

        let image = SFSymbols(privateSystemName: .init(rawValue: rawName)).nsuiImage

        #expect(image.size.width > 0 && image.size.height > 0)
    }

    @Test("A configuration modifier takes effect on a private symbol")
    @available(macOS 12.0, *)
    func configurationModifierTakesEffect() {
        let symbol = SFSymbols(privateSystemName: .init(rawValue: "airdrop"))

        #expect(symbol.pointSize(64, weight: .regular).nsuiImage.size.height > symbol.nsuiImage.size.height)
    }

    @Test("A private symbol with a variable value loads")
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func loadsWithVariableValue() {
        let image = SFSymbols(privateSystemName: .init(rawValue: "airdrop")).variableValue(0.5).nsuiImage

        #expect(image.size.width > 0 && image.size.height > 0)
    }

    #if os(macOS)
    @Test("A name the private symbol set lacks stops the process, as a missing public symbol does")
    func missingNameStopsProcess() async throws {
        let exitTestResult = try #require(await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            _ = SFSymbols(privateSystemName: .init(rawValue: "sfsymbols.tests.no.such.symbol")).nsuiImage
        })

        let standardError = String(decoding: exitTestResult.standardErrorContent, as: UTF8.self)
        #expect(standardError.contains("\"sfsymbols.tests.no.such.symbol\" could not be loaded from the private system symbol set"))
    }
    #endif

    private func publicSystemSymbolImage(named name: String) -> NSUIImage? {
        #if canImport(AppKit) && os(macOS)
        NSImage(systemSymbolName: name, accessibilityDescription: nil)
        #elseif canImport(UIKit)
        UIImage(systemName: name)
        #endif
    }
}

#if canImport(SwiftUI) && SFSYMBOLS_SWIFTUI

@Suite("Private system symbols in SwiftUI")
@MainActor
struct PrivateSystemSymbolSwiftUITests {
    @Test("Image(privateSystemName:) draws a symbol that only the private symbol set has")
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func privateSystemNameDrawsSymbol() throws {
        try #require(renderedImage(of: Image(systemName: "airdrop")) == nil, "Image(systemName:) draws airdrop, so it proves nothing")

        #expect(renderedImage(of: Image(privateSystemName: .init(rawValue: "airdrop"))) != nil)
    }

    @Test("Image(privateSystemName:) draws nothing, without stopping the process, for a name the private symbol set lacks")
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func privateSystemNameDrawsNothingForMissingName() {
        #expect(renderedImage(of: Image(privateSystemName: .init(rawValue: "sfsymbols.tests.no.such.symbol"))) == nil)
    }

    @Test("Image(name:) draws a private system symbol name as the private symbol")
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func nameDrawsPrivateSymbol() {
        let name = SFSymbols(privateSystemName: .init(rawValue: "airdrop")).name

        #expect(renderedImage(of: Image(name: name)) != nil)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    private func renderedImage(of image: Image) -> CGImage? {
        ImageRenderer(content: image).cgImage
    }
}

#endif

#endif
