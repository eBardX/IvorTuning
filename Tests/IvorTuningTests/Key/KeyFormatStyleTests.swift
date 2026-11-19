// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct KeyFormatStyleTests {
}

// MARK: -

extension KeyFormatStyleTests {

    @Test
    func description() {
        #expect(Key.diatonic(tonic: .fSharp, mode: .minor)?.description == "F♯ minor")
        #expect(Key.diatonic(tonic: .d, mode: .dorian)?.description == "D dorian")
        #expect(Key.diatonic(fifths: 0, mode: .major)?.description == "C major")
        #expect(Key.diatonic(fifths: -6, mode: .major)?.description == "G♭ major")
        #expect(Key.diatonic(fifths: 3, mode: nil)?.description == "F♯ C♯ G♯")
        #expect(Key.diatonic(fifths: 4, mode: nil)?.description == "F♯ C♯ G♯ D♯")
        #expect(Key.diatonic(fifths: 0, mode: nil)?.description == "(no accidentals)")
        #expect(Key(accidentals: [PitchClass.fSharp, .bFlat])?.description == "B♭ F♯")
        #expect(Key.atonal.description == "Atonal")
    }

    @Test
    func description_payloads() {
        #expect(Key.Diatonic(fifths: -1, mode: .minor)?.description == "D minor")
        #expect(Key.Diatonic(fifths: -2, mode: nil)?.description == "B♭ E♭")
    }

    @Test
    func formatted() {
        #expect(Key.diatonic(fifths: -2, mode: .major).map { String($0.formatted().characters) } == "B♭ major")
        #expect(String(Key.atonal.formatted().characters) == "Atonal")
    }

    @Test
    func formatted_ascii() {
        let style = Key.FormatStyle(ascii: true)

        func name(_ key: Key?) -> String? {
            key.map { String($0.formatted(style).characters) }
        }

        #expect(name(.diatonic(tonic: .fSharp, mode: .minor)) == "F# minor")
        #expect(name(.diatonic(fifths: -2, mode: nil)) == "Bb Eb")
        #expect(name(.diatonic(fifths: 0, mode: nil)) == "(no accidentals)")
        #expect(name(Key(accidentals: [PitchClass.fSharp, .bFlat])) == "Bb F#")
        #expect(name(.atonal) == "Atonal")
    }

    @Test
    func init_defaults() {
        let style = Key.FormatStyle()

        #expect(!style.ascii)
        #expect(style.locale == .autoupdatingCurrent)
    }
}
