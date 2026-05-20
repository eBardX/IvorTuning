// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiTools

struct NoteNumberFormatStyleTests {
}

// MARK: -

extension NoteNumberFormatStyleTests {

    @Test
    func formatted() {
        let noteNumber: NoteNumber = 60
        let result = noteNumber.formatted()

        #expect(!result.characters.isEmpty)
    }

    @Test
    func init_defaultLocale() {
        let style = NoteNumber.FormatStyle()

        #expect(style.locale == .autoupdatingCurrent)
    }
}
