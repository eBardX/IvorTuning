// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct PitchFormatStyleTests {
}

// MARK: -

extension PitchFormatStyleTests {

    @Test
    func formatted() {
        let result = Pitch.c4.formatted()

        #expect(!result.characters.isEmpty)
    }

    @Test
    func init_defaultLocale() {
        let style = Pitch.FormatStyle()

        #expect(style.locale == .autoupdatingCurrent)
    }
}
