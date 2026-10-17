#if SFSYMBOLS_PRIVATE

#if canImport(AppKit) && os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI) && SFSYMBOLS_SWIFTUI
import SwiftUI
#endif

internal import SFSymbolsPrivate

extension SFSymbols {
    /// The name of a symbol in the private system symbol set, which ships with the OS but which neither the SF Symbols
    /// app lists nor the public API loads. Private names have no API contract: any OS release can rename or remove them.
    public struct PrivateSystemSymbolName: RawRepresentable, Hashable, Sendable, SymbolName {
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension SFSymbols {
    public init(privateSystemName: PrivateSystemSymbolName) {
        self.init(name: privateSystemName as SymbolName)
    }

    public init(privateSystemName: PrivateSystemSymbolName, pointSize: CGFloat, weight: NSUISymbolWeight) {
        self.init(name: privateSystemName, pointSize: pointSize, weight: weight, scale: nil)
    }

    public init(privateSystemName: PrivateSystemSymbolName, pointSize: CGFloat, weight: NSUISymbolWeight, scale: NSUISymbolScale?) {
        self.init(name: privateSystemName as SymbolName, pointSize: pointSize, weight: weight, scale: scale)
    }

    public init(privateSystemName: PrivateSystemSymbolName, textStyle: NSUISymbolTextStyle) {
        self.init(name: privateSystemName, textStyle: textStyle, scale: nil)
    }

    public init(privateSystemName: PrivateSystemSymbolName, scale: NSUISymbolScale) {
        self.init(name: privateSystemName, textStyle: nil, scale: scale)
    }

    public init(privateSystemName: PrivateSystemSymbolName, textStyle: NSUISymbolTextStyle?, scale: NSUISymbolScale?) {
        self.init(name: privateSystemName as SymbolName, textStyle: textStyle, scale: scale)
    }

    #if canImport(AppKit) && os(macOS)

    var loadedPrivateSystemSymbolImage: NSImage? {
        if let variableValue, #available(macOS 13.0, *) {
            PrivateSystemSymbolImageFactory.image(named: name.rawValue, variableValue: variableValue)
        } else {
            PrivateSystemSymbolImageFactory.image(named: name.rawValue)
        }
    }

    #elseif canImport(UIKit)

    var loadedPrivateSystemSymbolImage: UIImage? {
        if let variableValue, #available(iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            PrivateSystemSymbolImageFactory.image(named: name.rawValue, variableValue: variableValue, configuration: configuration)
        } else {
            PrivateSystemSymbolImageFactory.image(named: name.rawValue, configuration: configuration)
        }
    }

    #endif
}

extension NSUIImage {
    public static func symbol(privateSystemName: SFSymbols.PrivateSystemSymbolName) -> NSUIImage {
        SFSymbols(privateSystemName: privateSystemName).nsuiImage
    }

    public static func symbol(privateSystemName: SFSymbols.PrivateSystemSymbolName, pointSize: CGFloat, weight: NSUISymbolWeight) -> NSUIImage {
        SFSymbols(privateSystemName: privateSystemName, pointSize: pointSize, weight: weight).nsuiImage
    }

    public static func symbol(privateSystemName: SFSymbols.PrivateSystemSymbolName, pointSize: CGFloat, weight: NSUISymbolWeight, scale: NSUISymbolScale?) -> NSUIImage {
        SFSymbols(privateSystemName: privateSystemName, pointSize: pointSize, weight: weight, scale: scale).nsuiImage
    }

    public static func symbol(privateSystemName: SFSymbols.PrivateSystemSymbolName, textStyle: NSUISymbolTextStyle) -> NSUIImage {
        SFSymbols(privateSystemName: privateSystemName, textStyle: textStyle).nsuiImage
    }

    public static func symbol(privateSystemName: SFSymbols.PrivateSystemSymbolName, scale: NSUISymbolScale) -> NSUIImage {
        SFSymbols(privateSystemName: privateSystemName, scale: scale).nsuiImage
    }

    public static func symbol(privateSystemName: SFSymbols.PrivateSystemSymbolName, textStyle: NSUISymbolTextStyle?, scale: NSUISymbolScale?) -> NSUIImage {
        SFSymbols(privateSystemName: privateSystemName, textStyle: textStyle, scale: scale).nsuiImage
    }
}

#if canImport(SwiftUI) && SFSYMBOLS_SWIFTUI

extension Image {
    public init(privateSystemName: SFSymbols.PrivateSystemSymbolName) {
        #if canImport(AppKit) && os(macOS)
        self.init(_internalSystemName: privateSystemName.rawValue)
        #else
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            self.init(_internalSystemName: privateSystemName.rawValue)
        } else {
            self.init(uiImage: SFSymbols(privateSystemName: privateSystemName).uiImage)
        }
        #endif
    }
}

#endif

#endif
