// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct IntervalFormatStyleTests {
}

// MARK: -

extension IntervalFormatStyleTests {

    @Test
    func formatted() {
        let result = Interval.perfect5.formatted()

        #expect(!result.characters.isEmpty)
    }

    @Test
    func init_defaultLocale() {
        let style = Interval.FormatStyle()

        #expect(style.locale == .autoupdatingCurrent)
    }
}
