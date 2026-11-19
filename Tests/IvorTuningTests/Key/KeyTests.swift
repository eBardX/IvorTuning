// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorTuning
import Testing

struct KeyTests {
}

// MARK: -

extension KeyTests {

    @Test
    func accidentals() {
        #expect(Key.atonal.accidentals.isEmpty)
        #expect(Key.diatonic(fifths: 0, mode: .major)?.accidentals.isEmpty == true)
        #expect(Key.diatonic(fifths: -2, mode: nil)?.accidentals == [.bFlat, .eFlat])
        #expect(Key(accidentals: [PitchClass.fSharp, .bFlat])?.accidentals == [.bFlat, .fSharp])
    }

    @Test
    func codable_decodingFailures() {
        let failures = [#""none""#,
                        #"3"#,
                        #"{}"#,
                        #"{"fifths":9}"#,
                        #"{"fifths":1,"mode":"ionian"}"#,
                        #"{"custom":["F♯"]}"#,
                        #"{"custom":[]}"#,
                        #"{"custom":["B♭","F♯"],"fifths":1}"#,
                        #"{"custom":["B♭","F♯"],"mode":"major"}"#,
                        #"{"custom":["F♯","F♭"]}"#]

        for json in failures {
            #expect(throws: DecodingError.self, "\(json)") {
                try JSONDecoder().decode(Key.self, from: Data(json.utf8))
            }
        }
    }

    @Test
    func codable_encoding() throws {
        let encoder = JSONEncoder()

        encoder.outputFormatting = .sortedKeys

        func json(_ key: Key?) throws -> String? {
            try String(bytes: encoder.encode(#require(key)), encoding: .utf8)
        }

        #expect(try json(.atonal) == #""atonal""#)
        #expect(try json(.diatonic(fifths: 3, mode: .minor)) == #"{"fifths":3,"mode":"minor"}"#)
        #expect(try json(.diatonic(fifths: 3, mode: nil)) == #"{"fifths":3}"#)
        #expect(try json(Key(accidentals: [PitchClass.fSharp, .bFlat])) == #"{"custom":["B♭","F♯"]}"#)
    }

    @Test
    func codable_roundTrip() throws {
        let originals: [Key] = try [.atonal,
                                    #require(.diatonic(fifths: 0, mode: nil)),
                                    #require(.diatonic(fifths: -7, mode: .major)),
                                    #require(.diatonic(tonic: .fSharp, mode: .minor)),
                                    #require(Key(accidentals: [PitchClass.aSharp, .bFlat]))]

        for original in originals {
            let data = try JSONEncoder().encode(original)

            #expect(try JSONDecoder().decode(Key.self, from: data) == original)
        }
    }

    @Test
    func equatable() {
        #expect(Key.diatonic(fifths: 1, mode: nil) != Key.diatonic(fifths: 1, mode: .major))
        #expect(Key.diatonic(fifths: 0, mode: nil) != .atonal)
        #expect(Key.diatonic(tonic: .e, mode: .minor) == Key.diatonic(fifths: 1, mode: .minor))
    }

    @Test
    func fifths() {
        #expect(Key.atonal.fifths == nil)
        #expect(Key.diatonic(fifths: -3, mode: nil)?.fifths == -3)
        #expect(Key(accidentals: [PitchClass.fSharp, .gSharp])?.fifths == nil)
    }

    @Test
    func init_accidentals_custom() {
        guard case let .custom(signature)? = Key(accidentals: [PitchClass.bFlat, .fSharp])
        else { Issue.record("Expected a custom key"); return }

        #expect(signature.accidentals == [.bFlat, .fSharp])
    }

    @Test
    func init_accidentals_diatonic() {
        #expect(Key(accidentals: [PitchClass]()) == .diatonic(fifths: 0, mode: nil))
        #expect(Key(accidentals: [PitchClass.c, .g]) == .diatonic(fifths: 0, mode: nil))
        #expect(Key(accidentals: [PitchClass.cSharp, .fSharp]) == .diatonic(fifths: 2, mode: nil))
        #expect(Key(accidentals: [PitchClass.aFlat, .bFlat, .eFlat]) == .diatonic(fifths: -3, mode: nil))

        for fifths in -7...7 {
            let diatonic = Key.Diatonic(fifths: fifths, mode: nil)

            #expect(Key(accidentals: diatonic?.accidentals.reversed() ?? []) == diatonic.map { .diatonic($0) })
        }
    }

    @Test
    func init_accidentals_invalid() {
        #expect(Key(accidentals: [PitchClass.fSharp, .fSharp]) == nil)
        #expect(Key(accidentals: [PitchClass.fSharp, .f]) == nil)
        #expect(Key(accidentals: [PitchClass.fDoubleSharp]) == nil)
        #expect(Key(accidentals: [PitchClass.bDoubleFlat]) == nil)
    }

    @Test
    func modeAndTonic() {
        #expect(Key.atonal.mode == nil)
        #expect(Key.atonal.tonic == nil)
        #expect(Key.diatonic(fifths: 3, mode: nil)?.mode == nil)
        #expect(Key.diatonic(fifths: 3, mode: nil)?.tonic == nil)
        #expect(Key.diatonic(fifths: 3, mode: .minor)?.mode == .minor)
        #expect(Key.diatonic(fifths: 3, mode: .minor)?.tonic == .fSharp)
        #expect(Key(accidentals: [PitchClass.bFlat, .fSharp])?.mode == nil)
        #expect(Key(accidentals: [PitchClass.bFlat, .fSharp])?.tonic == nil)
    }

    @Test
    func nearestDiatonicFifths() {
        #expect(Key.atonal.nearestDiatonicFifths == 0)
        #expect(Key(accidentals: [PitchClass.bFlat, .aFlat])?.nearestDiatonicFifths == -1)

        for fifths in -7...7 {
            #expect(Key.diatonic(fifths: fifths, mode: .major)?.nearestDiatonicFifths == fifths)
        }
    }

    @Test
    func staticDiatonic_invalid() {
        #expect(Key.diatonic(fifths: 8, mode: nil) == nil)
        #expect(Key.diatonic(tonic: .eSharp, mode: .minor) == nil)
    }
}
