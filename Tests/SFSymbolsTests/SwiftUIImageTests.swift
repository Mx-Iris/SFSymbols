#if canImport(SwiftUI) && SFSYMBOLS_SWIFTUI

import SwiftUI
import Testing
import SFSymbols

@Suite("SwiftUI images")
struct SwiftUIImageTests {
    @Test("Image(name:) shows a system symbol name as the system symbol")
    func systemSymbolNameMakesSystemSymbolImage() {
        let name = SFSymbols(systemName: .star).name

        #expect(Image(name: name) == Image(systemName: "star"))
    }
}

#endif
