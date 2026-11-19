// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorTuning
import Testing

struct KeyDiatonicTests {
}

// MARK: -

extension KeyDiatonicTests {

    @Test
    func accidentals_allFifths() throws {
        let sharps: [PitchClass] = [.fSharp, .cSharp, .gSharp, .dSharp, .aSharp, .eSharp, .bSharp]
        let flats: [PitchClass] = [.bFlat, .eFlat, .aFlat, .dFlat, .gFlat, .cFlat, .fFlat]

        for fifths in -7...7 {
            let diatonic = try #require(Key.Diatonic(fifths: fifths, mode: nil))
            let expected = fifths < 0 ? Array(flats.prefix(-fifths)) : Array(sharps.prefix(fifths))

            #expect(diatonic.accidentals == expected)
        }
    }

    @Test
    func codable() throws {
        let originals = try [#require(Key.Diatonic(fifths: -3, mode: .minor)),
                             #require(Key.Diatonic(fifths: 0, mode: nil)),
                             #require(Key.Diatonic(fifths: 7, mode: .locrian))]

        for original in originals {
            let data = try JSONEncoder().encode(original)

            #expect(try JSONDecoder().decode(Key.Diatonic.self, from: data) == original)
        }
    }

    @Test
    func codable_encoding() throws {
        let encoder = JSONEncoder()

        encoder.outputFormatting = .sortedKeys

        let withMode = try encoder.encode(#require(Key.Diatonic(fifths: 3, mode: .minor)))
        let withoutMode = try encoder.encode(#require(Key.Diatonic(fifths: 3, mode: nil)))

        #expect(String(bytes: withMode, encoding: .utf8) == #"{"fifths":3,"mode":"minor"}"#)
        #expect(String(bytes: withoutMode, encoding: .utf8) == #"{"fifths":3}"#)
    }

    @Test
    func codable_invalid() {
        let tooMany = Data(#"{"fifths":8}"#.utf8)
        let badMode = Data(#"{"fifths":0,"mode":"aeolian"}"#.utf8)
        let missing = Data(#"{"mode":"major"}"#.utf8)

        #expect(throws: DecodingError.self) { try JSONDecoder().decode(Key.Diatonic.self, from: tooMany) }
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(Key.Diatonic.self, from: badMode) }
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(Key.Diatonic.self, from: missing) }
    }

    @Test
    func diatonicCollection() throws {
        let sevenFlats = try #require(Key.Diatonic(fifths: -7, mode: nil))
        let none = try #require(Key.Diatonic(fifths: 0, mode: nil))
        let oneFlat = try #require(Key.Diatonic(fifths: -1, mode: nil))
        let sevenSharps = try #require(Key.Diatonic(fifths: 7, mode: nil))

        #expect(sevenFlats.diatonicCollection == [.fFlat, .cFlat, .gFlat, .dFlat, .aFlat, .eFlat, .bFlat])
        #expect(none.diatonicCollection == [.f, .c, .g, .d, .a, .e, .b])
        #expect(oneFlat.diatonicCollection == [.bFlat, .f, .c, .g, .d, .a, .e])
        #expect(sevenSharps.diatonicCollection == [.fSharp, .cSharp, .gSharp, .dSharp, .aSharp, .eSharp, .bSharp])
    }

    @Test
    func equatable_modeMatters() {
        #expect(Key.Diatonic(fifths: 1, mode: nil) != Key.Diatonic(fifths: 1, mode: .major))
        #expect(Key.Diatonic(fifths: 1, mode: .major) != Key.Diatonic(fifths: 1, mode: .minor))
        #expect(Key.Diatonic(fifths: 1, mode: .minor) == Key.Diatonic(tonic: .e, mode: .minor))
    }

    @Test
    func init_fifths() throws {
        for fifths in -7...7 {
            let diatonic = try #require(Key.Diatonic(fifths: fifths, mode: .dorian))

            #expect(diatonic.fifths == fifths)
            #expect(diatonic.mode == .dorian)
        }
    }

    @Test
    func init_fifths_invalid() {
        #expect(Key.Diatonic(fifths: -8, mode: nil) == nil)
        #expect(Key.Diatonic(fifths: 8, mode: .major) == nil)
    }

    @Test
    func init_tonic() {
        #expect(Key.Diatonic(tonic: .aSharp, mode: .minor)?.fifths == 7)
        #expect(Key.Diatonic(tonic: .cSharp, mode: .major)?.fifths == 7)
        #expect(Key.Diatonic(tonic: .cFlat, mode: .major)?.fifths == -7)
        #expect(Key.Diatonic(tonic: .aFlat, mode: .minor)?.fifths == -7)
        #expect(Key.Diatonic(tonic: .e, mode: .dorian)?.fifths == 2)
        #expect(Key.Diatonic(tonic: .c, mode: .phrygian)?.fifths == -4)
    }

    @Test
    func init_tonic_invalid() {
        #expect(Key.Diatonic(tonic: .eSharp, mode: .minor) == nil)
        #expect(Key.Diatonic(tonic: .fDoubleSharp, mode: .major) == nil)
        #expect(Key.Diatonic(tonic: .fFlat, mode: .major) == nil)
        #expect(Key.Diatonic(tonic: .dFlat, mode: .minor) == nil)
    }

    @Test
    func tonic() {
        #expect(Key.Diatonic(fifths: 1, mode: .major)?.tonic == .g)
        #expect(Key.Diatonic(fifths: 1, mode: .minor)?.tonic == .e)
        #expect(Key.Diatonic(fifths: 6, mode: .major)?.tonic == .fSharp)
        #expect(Key.Diatonic(fifths: -6, mode: .major)?.tonic == .gFlat)
        #expect(Key.Diatonic(fifths: 2, mode: .dorian)?.tonic == .e)
        #expect(Key.Diatonic(fifths: 0, mode: .locrian)?.tonic == .b)
        #expect(Key.Diatonic(fifths: 0, mode: .lydian)?.tonic == .f)
        #expect(Key.Diatonic(fifths: -1, mode: .phrygian)?.tonic == .a)
        #expect(Key.Diatonic(fifths: -1, mode: .mixolydian)?.tonic == .c)
    }

    @Test
    func tonic_everyModeAndFifths() throws {
        for fifths in -7...7 {
            for mode in Key.Mode.allCases {
                let diatonic = try #require(Key.Diatonic(fifths: fifths, mode: mode))
                let tonic = try #require(diatonic.tonic)

                #expect(diatonic.diatonicCollection[mode.diatonicIndex] == tonic)
                #expect(Key.Diatonic(tonic: tonic, mode: mode) == diatonic)
            }
        }
    }

    @Test
    func tonic_noMode() {
        #expect(Key.Diatonic(fifths: 3, mode: nil)?.tonic == nil)
    }
}
