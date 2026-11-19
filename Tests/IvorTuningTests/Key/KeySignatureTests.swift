// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorTuning
import Testing

struct KeySignatureTests {
}

// MARK: -

extension KeySignatureTests {

    @Test
    func accidentalForLetter() throws {
        let signature = try #require(Key.Signature(accidentals: [PitchClass.bFlat, .fSharp]))

        #expect(signature.accidental(for: .b) == .flat)
        #expect(signature.accidental(for: .f) == .sharp)
        #expect(signature.accidental(for: .c) == .natural)
    }

    @Test
    func accidentals_canonicalOrder() throws {
        let mixed = try #require(Key.Signature(accidentals: [PitchClass.gSharp, .eFlat, .fSharp, .bFlat]))
        let partialSharps = try #require(Key.Signature(accidentals: [PitchClass.gSharp, .fSharp]))
        let partialFlats = try #require(Key.Signature(accidentals: [PitchClass.aFlat, .bFlat]))

        #expect(mixed.accidentals == [.bFlat, .eFlat, .fSharp, .gSharp])
        #expect(partialSharps.accidentals == [.fSharp, .gSharp])
        #expect(partialFlats.accidentals == [.bFlat, .aFlat])
    }

    @Test
    func codable() throws {
        let originals = try [#require(Key.Signature(accidentals: [PitchClass.fSharp, .bFlat])),
                             #require(Key.Signature(accidentals: [PitchClass.eFlat])),
                             #require(Key.Signature(accidentals: [PitchClass.fFlat, .bSharp]))]

        for original in originals {
            let data = try JSONEncoder().encode(original)

            #expect(try JSONDecoder().decode(Key.Signature.self, from: data) == original)
        }
    }

    @Test
    func codable_encodesCanonicalAccidentals() throws {
        let signature = try #require(Key.Signature(accidentals: [PitchClass.fSharp, .bFlat]))
        let data = try JSONEncoder().encode(signature)

        #expect(String(bytes: data, encoding: .utf8) == #"["B♭","F♯"]"#)
    }

    @Test
    func codable_invalid() {
        let repeated = Data(#"["F♯","F♭"]"#.utf8)
        let double = Data(#"["F𝄪"]"#.utf8)
        let diatonic = Data(#"["F♯","C♯"]"#.utf8)
        let empty = Data(#"[]"#.utf8)

        #expect(throws: DecodingError.self) { try JSONDecoder().decode(Key.Signature.self, from: repeated) }
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(Key.Signature.self, from: double) }
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(Key.Signature.self, from: diatonic) }
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(Key.Signature.self, from: empty) }
    }

    @Test
    func description() {
        #expect(Key.Signature(accidentals: [PitchClass.fSharp, .bFlat])?.description == "B♭ F♯")
    }

    @Test
    func equatable_ignoresOrder() {
        #expect(Key.Signature(accidentals: [PitchClass.fSharp, .gSharp])
                    == Key.Signature(accidentals: [PitchClass.gSharp, .fSharp]))
        #expect(Key.Signature(accidentals: [PitchClass.fSharp, .gSharp])
                    != Key.Signature(accidentals: [PitchClass.fSharp, .gSharp, .dSharp]))
        #expect(Key.Signature(accidentals: [PitchClass.fSharp, .gSharp, .e])
                    == Key.Signature(accidentals: [PitchClass.gSharp, .fSharp]))
    }

    @Test
    func hashable() throws {
        let set: Set<Key.Signature> = try [#require(Key.Signature(accidentals: [PitchClass.fSharp, .gSharp])),
                                           #require(Key.Signature(accidentals: [PitchClass.gSharp, .fSharp])),
                                           #require(Key.Signature(accidentals: [PitchClass.bFlat, .fSharp]))]

        #expect(set.count == 2)
    }

    @Test
    func init_enharmonicDuplicates() {
        #expect(Key.Signature(accidentals: [PitchClass.aSharp, .bFlat]) != nil)
        #expect(Key.Signature(accidentals: [PitchClass.eSharp]) != nil)
        #expect(Key.Signature(accidentals: [PitchClass.cFlat]) != nil)
    }

    @Test
    func init_invalid() {
        #expect(Key.Signature(accidentals: [PitchClass.fSharp, .fSharp]) == nil)
        #expect(Key.Signature(accidentals: [PitchClass.fSharp, .f]) == nil)
        #expect(Key.Signature(accidentals: [PitchClass.bFlat, .bSharp]) == nil)
        #expect(Key.Signature(accidentals: [PitchClass.fDoubleSharp]) == nil)
        #expect(Key.Signature(accidentals: [PitchClass.bDoubleFlat]) == nil)
    }

    @Test
    func init_rejectsEveryDiatonicSet() throws {
        for fifths in -7...7 {
            let diatonic = try #require(Key.Diatonic(fifths: fifths, mode: nil))

            #expect(Key.Signature(accidentals: diatonic.accidentals) == nil)
            #expect(Key.Signature(accidentals: diatonic.accidentals.reversed()) == nil)
            #expect(Key.Signature(accidentals: diatonic.diatonicCollection) == nil)
        }

        #expect(Key.Signature(accidentals: [PitchClass]()) == nil)
        #expect(Key.Signature(accidentals: [PitchClass.c, .g]) == nil)
    }

    @Test
    func nearestDiatonicFifths_fewestDifferences() {
        #expect(Key.Signature(accidentals: [PitchClass.fSharp, .cSharp, .gSharp, .eSharp])?.nearestDiatonicFifths == 3)
        #expect(Key.Signature(accidentals: [PitchClass.eFlat])?.nearestDiatonicFifths == 0)
        #expect(Key.Signature(accidentals: [PitchClass.cSharp])?.nearestDiatonicFifths == 0)
    }

    @Test
    func nearestDiatonicFifths_tieBreaks() {
        // One letter from both 1♯ and 3♯: fewer accidentals.
        #expect(Key.Signature(accidentals: [PitchClass.fSharp, .gSharp])?.nearestDiatonicFifths == 1)

        // One letter from both 1♭ and 3♭: fewer accidentals.
        #expect(Key.Signature(accidentals: [PitchClass.bFlat, .aFlat])?.nearestDiatonicFifths == -1)

        // One letter from both 1♯ and 1♭, leaning neither way: sharps.
        #expect(Key.Signature(accidentals: [PitchClass.bFlat, .fSharp])?.nearestDiatonicFifths == 1)

        // Two letters from 1♯, 1♭ and 3♯, leaning to sharps.
        #expect(Key.Signature(accidentals: [PitchClass.bFlat, .fSharp, .gSharp])?.nearestDiatonicFifths == 1)

        // Two letters from 1♯, 1♭ and 3♭, leaning to flats.
        #expect(Key.Signature(accidentals: [PitchClass.bFlat, .aFlat, .fSharp])?.nearestDiatonicFifths == -1)
    }

    @Test
    func pitchClasses() throws {
        let signature = try #require(Key.Signature(accidentals: [PitchClass.bFlat, .aFlat]))

        #expect(signature.pitchClasses == [.c, .d, .e, .f, .g, .aFlat, .bFlat])
    }

    @Test
    func stringValue() {
        #expect(Key.Signature(accidentals: [PitchClass.gSharp, .fSharp])?.stringValue() == "F♯ G♯")
        #expect(Key.Signature(accidentals: [PitchClass.aFlat, .bFlat])?.stringValue() == "B♭ A♭")
        #expect(Key.Signature(accidentals: [PitchClass.gSharp, .eFlat, .fSharp, .bFlat])?.stringValue(ascii: true)
                    == "Bb Eb F# G#")
    }
}
