// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct KeySignatureFormatStyleTests {
}

// MARK: -

extension KeySignatureFormatStyleTests {

    @Test
    func description() {
        #expect(KeySignature(fifths: 3)?.description == "3♯")
        #expect(KeySignature(accidentals: [PitchClass.fSharp, .bFlat])?.description == "B♭ F♯")
    }

    @Test
    func formatted() {
        #expect(KeySignature(fifths: -2).map { String($0.formatted().characters) } == "2♭")
    }

    @Test
    func init_defaultLocale() {
        let style = KeySignature.FormatStyle()

        #expect(style.locale == .autoupdatingCurrent)
    }

    @Test
    func stringValue_ascii() {
        #expect(KeySignature(fifths: 3)?.stringValue(ascii: true) == "3#")
        #expect(KeySignature(fifths: -2)?.stringValue(ascii: true) == "2b")
        #expect(KeySignature(fifths: 0)?.stringValue(ascii: true) == "no #/b")
        #expect(KeySignature(accidentals: [PitchClass.gSharp, .eFlat, .fSharp, .bFlat])?.stringValue(ascii: true)
                    == "Bb Eb F# G#")
    }

    @Test
    func stringValue_unicode() {
        #expect(KeySignature(fifths: 7)?.stringValue() == "7♯")
        #expect(KeySignature(fifths: 1)?.stringValue() == "1♯")
        #expect(KeySignature(fifths: -1)?.stringValue() == "1♭")
        #expect(KeySignature(fifths: -7)?.stringValue() == "7♭")
        #expect(KeySignature(fifths: 0)?.stringValue() == "no ♯/♭")
        #expect(KeySignature(accidentals: [PitchClass.gSharp, .fSharp])?.stringValue() == "F♯ G♯")
        #expect(KeySignature(accidentals: [PitchClass.aFlat, .bFlat])?.stringValue() == "B♭ A♭")
    }
}
