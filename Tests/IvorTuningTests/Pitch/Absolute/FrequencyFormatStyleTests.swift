// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiNumbers

struct FrequencyFormatStyleTests {
}

// MARK: -

extension FrequencyFormatStyleTests {

    @Test
    func formatted() throws {
        let frequency = try #require(Frequency(numberValue: Number(440)))
        let result = frequency.formatted()

        #expect(!result.characters.isEmpty)
    }

    @Test
    func init_defaultLocale() {
        let style = Frequency.FormatStyle()

        #expect(style.locale == .autoupdatingCurrent)
    }
}
