// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiNumbers

struct RatioFormatStyleTests {
}

// MARK: -

extension RatioFormatStyleTests {

    @Test
    func formatted() {
        let ratio = Ratio(cents: Number(700))
        let result = ratio.formatted()

        #expect(!result.characters.isEmpty)
    }

    @Test
    func init_defaultLocale() {
        let style = Ratio.FormatStyle()

        #expect(style.locale == .autoupdatingCurrent)
    }
}
