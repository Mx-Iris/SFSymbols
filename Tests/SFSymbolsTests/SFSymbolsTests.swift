#if canImport(AppKit) && os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Foundation
import Testing
import SFSymbols

@Suite("Configuration modifiers")
struct ConfigurationModifierTests {
    enum ConfigurationModifier: CaseIterable {
        case pointSizeAndWeight
        case pointSizeWeightAndScale
        case textStyle
        case textStyleAndScale
        case scale
        case hierarchicalColor
        case paletteColors
        case preferringMonochrome
        #if canImport(AppKit) && os(macOS)
        case preferringHierarchical
        #endif
        case preferringMulticolor
        case variableValueMode
        case colorRenderingMode
    }

    @Test("A modifier takes effect on a symbol created without a configuration", arguments: ConfigurationModifier.allCases)
    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    func modifierTakesEffectWithoutInitialConfiguration(_ modifier: ConfigurationModifier) throws {
        let (modifiedSymbol, expectedConfiguration) = apply(modifier, to: SFSymbols(systemName: .star))

        let configuration = try #require(modifiedSymbol.configuration)
        #expect(try encodedForm(of: configuration) == encodedForm(of: expectedConfiguration))
    }

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    private func apply(_ modifier: ConfigurationModifier, to symbol: SFSymbols) -> (modifiedSymbol: SFSymbols, expectedConfiguration: NSUISymbolConfiguration) {
        switch modifier {
        case .pointSizeAndWeight:
            return (symbol.pointSize(20, weight: .bold), NSUISymbolConfiguration(pointSize: 20, weight: .bold))
        case .pointSizeWeightAndScale:
            return (symbol.pointSize(20, weight: .bold, scale: .large), NSUISymbolConfiguration(pointSize: 20, weight: .bold, scale: .large))
        case .textStyle:
            return (symbol.textStyle(.headline), NSUISymbolConfiguration(textStyle: .headline))
        case .textStyleAndScale:
            return (symbol.textStyle(.headline, scale: .small), NSUISymbolConfiguration(textStyle: .headline, scale: .small))
        case .scale:
            return (symbol.scale(.large), NSUISymbolConfiguration(scale: .large))
        case .hierarchicalColor:
            return (symbol.hierarchicalColor(.red), NSUISymbolConfiguration(hierarchicalColor: .red))
        case .paletteColors:
            return (symbol.paletteColors([.red, .blue]), NSUISymbolConfiguration(paletteColors: [.red, .blue]))
        case .preferringMonochrome:
            return (symbol.preferringMonochrome(), NSUISymbolConfiguration.preferringMonochrome())
        #if canImport(AppKit) && os(macOS)
        case .preferringHierarchical:
            return (symbol.preferringHierarchical(), NSUISymbolConfiguration.preferringHierarchical())
        #endif
        case .preferringMulticolor:
            return (symbol.preferringMulticolor(), NSUISymbolConfiguration.preferringMulticolor())
        case .variableValueMode:
            return (symbol.variableValueMode(.draw), NSUISymbolConfiguration(variableValueMode: .draw))
        case .colorRenderingMode:
            return (symbol.colorRenderingMode(.gradient), NSUISymbolConfiguration(colorRenderingMode: .gradient))
        }
    }

    /// `NSImage.SymbolConfiguration` compares by identity, so two configurations are compared by their archived contents.
    private func encodedForm(of configuration: NSUISymbolConfiguration) throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: configuration, requiringSecureCoding: true)
    }
}
