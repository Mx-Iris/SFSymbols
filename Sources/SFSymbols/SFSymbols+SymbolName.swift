import Foundation

@available(*, deprecated, renamed: "SFSymbols.SymbolName", message: "Use SFSymbols.SymbolName")
public typealias SymbolName = SFSymbols.SymbolName

extension SFSymbols {
    public protocol SymbolName: Sendable {
        var rawValue: String { get }
        var bundle: Bundle? { get }
    }
}

extension SFSymbols.SymbolName {
    public var bundle: Bundle? { nil }
}
