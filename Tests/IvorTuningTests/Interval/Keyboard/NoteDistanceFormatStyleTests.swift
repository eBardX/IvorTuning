// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiTools

struct NoteDistanceFormatStyleTests {
}

// MARK: -

extension NoteDistanceFormatStyleTests {

    @Test
    func formatted() {
        let distance: NoteDistance = 12
        let result = distance.formatted()

        #expect(!result.characters.isEmpty)
    }

    @Test
    func init_defaultLocale() {
        let style = NoteDistance.FormatStyle()

        #expect(style.locale == .autoupdatingCurrent)
    }
}
