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
        let keySignature = try #require(KeySignature(accidentals: [PitchClass.bFlat, .fSharp]))

        #expect(keySignature.accidental(for: .b) == .flat)
        #expect(keySignature.accidental(for: .f) == .sharp)
        #expect(keySignature.accidental(for: .c) == .natural)
    }

    @Test
    func accidentals_canonicalOrder_custom() throws {
        let mixed = try #require(KeySignature(accidentals: [PitchClass.gSharp, .eFlat, .fSharp, .bFlat]))
        let partialSharps = try #require(KeySignature(accidentals: [PitchClass.gSharp, .fSharp]))
        let partialFlats = try #require(KeySignature(accidentals: [PitchClass.aFlat, .bFlat]))

        #expect(mixed.accidentals == [.bFlat, .eFlat, .fSharp, .gSharp])
        #expect(partialSharps.accidentals == [.fSharp, .gSharp])
        #expect(partialFlats.accidentals == [.bFlat, .aFlat])
    }

    @Test
    func accidentals_canonicalOrder_diatonic() throws {
        let sevenSharps = try #require(KeySignature(fifths: 7))
        let sevenFlats = try #require(KeySignature(fifths: -7))
        let none = try #require(KeySignature(fifths: 0))

        #expect(sevenSharps.accidentals == [.fSharp, .cSharp, .gSharp, .dSharp, .aSharp, .eSharp, .bSharp])
        #expect(sevenFlats.accidentals == [.bFlat, .eFlat, .aFlat, .dFlat, .gFlat, .cFlat, .fFlat])
        #expect(none.accidentals.isEmpty)
    }

    @Test
    func codable() throws {
        let originals = try [#require(KeySignature(fifths: -3)),
                             #require(KeySignature(fifths: 0)),
                             #require(KeySignature(accidentals: [PitchClass.fSharp, .bFlat]))]

        for original in originals {
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(KeySignature.self, from: data)

            #expect(decoded == original)
        }
    }

    @Test
    func codable_encodesCanonicalAccidentals() throws {
        let keySignature = try #require(KeySignature(accidentals: [PitchClass.fSharp, .bFlat]))
        let data = try JSONEncoder().encode(keySignature)

        #expect(String(bytes: data, encoding: .utf8) == #"["B♭","F♯"]"#)
    }

    @Test
    func codable_invalid() {
        let repeated = Data(#"["F♯","F♭"]"#.utf8)
        let double = Data(#"["F𝄪"]"#.utf8)

        #expect(throws: DecodingError.self) { try JSONDecoder().decode(KeySignature.self, from: repeated) }
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(KeySignature.self, from: double) }
    }

    @Test
    func diatonicCollection() throws {
        let sevenFlats = try #require(KeySignature(fifths: -7))
        let none = try #require(KeySignature(fifths: 0))
        let oneFlat = try #require(KeySignature(fifths: -1))
        let sevenSharps = try #require(KeySignature(fifths: 7))

        #expect(sevenFlats.diatonicCollection == [.fFlat, .cFlat, .gFlat, .dFlat, .aFlat, .eFlat, .bFlat])
        #expect(none.diatonicCollection == [.f, .c, .g, .d, .a, .e, .b])
        #expect(oneFlat.diatonicCollection == [.bFlat, .f, .c, .g, .d, .a, .e])
        #expect(sevenSharps.diatonicCollection == [.fSharp, .cSharp, .gSharp, .dSharp, .aSharp, .eSharp, .bSharp])
    }

    @Test
    func diatonicCollection_custom() throws {
        let keySignature = try #require(KeySignature(accidentals: [PitchClass.fSharp, .gSharp]))

        #expect(keySignature.diatonicCollection == nil)
    }

    @Test
    func equatable_ignoresOrder() {
        #expect(KeySignature(accidentals: [PitchClass.fSharp, .gSharp])
                    == KeySignature(accidentals: [PitchClass.gSharp, .fSharp]))
        #expect(KeySignature(accidentals: [PitchClass.fSharp, .gSharp])
                    != KeySignature(accidentals: [PitchClass.fSharp]))
    }

    @Test
    func equatable_explicitNatural() {
        #expect(KeySignature(accidentals: [PitchClass.fSharp, .c]) == KeySignature(fifths: 1))
        #expect(KeySignature(accidentals: [PitchClass.c]) == KeySignature(fifths: 0))
    }

    @Test
    func hashable() throws {
        let set: Set<KeySignature> = try [#require(KeySignature(accidentals: [PitchClass.fSharp, .gSharp])),
                                          #require(KeySignature(accidentals: [PitchClass.gSharp, .fSharp])),
                                          #require(KeySignature(fifths: 1))]

        #expect(set.count == 2)
    }

    @Test
    func init_accidentals_custom() throws {
        let keySignature = try #require(KeySignature(accidentals: [PitchClass.bFlat, .fSharp]))

        #expect(!keySignature.isDiatonic)
        #expect(keySignature.fifths == nil)
    }

    @Test
    func init_accidentals_diatonic() throws {
        let twoSharps = try #require(KeySignature(accidentals: [PitchClass.cSharp, .fSharp]))
        let threeFlats = try #require(KeySignature(accidentals: [PitchClass.aFlat, .bFlat, .eFlat]))
        let empty = try #require(KeySignature(accidentals: [PitchClass]()))

        #expect(twoSharps == KeySignature(fifths: 2))
        #expect(twoSharps.isDiatonic)
        #expect(twoSharps.fifths == 2)
        #expect(threeFlats.fifths == -3)
        #expect(empty.fifths == 0)
    }

    @Test
    func init_accidentals_invalid() {
        #expect(KeySignature(accidentals: [PitchClass.fSharp, .fSharp]) == nil)
        #expect(KeySignature(accidentals: [PitchClass.fSharp, .f]) == nil)
        #expect(KeySignature(accidentals: [PitchClass.bFlat, .bSharp]) == nil)
        #expect(KeySignature(accidentals: [PitchClass.fDoubleSharp]) == nil)
        #expect(KeySignature(accidentals: [PitchClass.bDoubleFlat]) == nil)
    }

    @Test
    func init_fifths_allDiatonic() throws {
        let sharps: [PitchClass] = [.fSharp, .cSharp, .gSharp, .dSharp, .aSharp, .eSharp, .bSharp]
        let flats: [PitchClass] = [.bFlat, .eFlat, .aFlat, .dFlat, .gFlat, .cFlat, .fFlat]

        for fifths in -7...7 {
            let keySignature = try #require(KeySignature(fifths: fifths))
            let expected = fifths < 0 ? Array(flats.prefix(-fifths)) : Array(sharps.prefix(fifths))

            #expect(keySignature.isDiatonic)
            #expect(keySignature.fifths == fifths)
            #expect(keySignature.accidentals == expected)
        }
    }

    @Test
    func init_fifths_invalid() {
        #expect(KeySignature(fifths: -8) == nil)
        #expect(KeySignature(fifths: 8) == nil)
    }

    @Test
    func pitchClasses() throws {
        let twoFlats = try #require(KeySignature(fifths: -2))
        let custom = try #require(KeySignature(accidentals: [PitchClass.bFlat, .aFlat]))

        #expect(twoFlats.pitchClasses == [.c, .d, .eFlat, .f, .g, .a, .bFlat])
        #expect(custom.pitchClasses == [.c, .d, .e, .f, .g, .aFlat, .bFlat])
    }
}
