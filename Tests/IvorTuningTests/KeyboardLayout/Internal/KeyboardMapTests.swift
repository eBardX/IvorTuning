// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct KeyboardMapTests {
    private let nineteenSubset = try? KeyboardLayout(pitchClasses: [.c,
                                                                    .cSharp,
                                                                    .d,
                                                                    .eFlat,
                                                                    .e,
                                                                    .f,
                                                                    .fSharp,
                                                                    .g,
                                                                    .gSharp,
                                                                    .a,
                                                                    .bFlat,
                                                                    .b])

    private let piano = try? KeyboardMap(keyboardLayout: .piano,
                                         tuningSystem: EqualTemperament.edo12,
                                         pitchStandard: .a440)
}

// MARK: -

extension KeyboardMapTests {
    @Test
    func degree_beyondTuningSystem_throwsUnsupportedDegree() throws {
        let layout = try KeyboardLayout(degrees: [0, 12],
                                        referenceNote: 60)

        #expect(throws: TuningError.invalidKeyboardLayout(.unsupportedDegree(index: 1))) {
            try makeKeyboardMap(layout)
        }
        #expect(throws: TuningError.invalidKeyboardLayout(.unsupportedDegree(index: 0))) {
            try makeKeyboardMap(.bohlenPierce, LinearTemperament.quarterCommaMeantone)
        }
    }

    @Test
    func degree_bohlenPierce() throws {
        let kmap = try makeKeyboardMap(.bohlenPierce, EqualTemperament.bohlenPierce)
        let key60 = try #require(kmap.frequency(of: 60))

        #expect(kmap.frequency(of: 69) == 440)
        assertEqual(key60.numberValue, Number(440) / Number(Foundation.pow(3.0, 9.0 / 13.0)))
        assertEqual(kmap.frequency(of: 73)?.numberValue, key60.numberValue * 3)
        #expect(kmap.pitches == nil)
    }

    @Test
    func degree_lambda() throws {
        let lambda = try KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])
        let kmap = try makeKeyboardMap(lambda, EqualTemperament.bohlenPierce)
        let key60 = try #require(kmap.frequency(of: 60))

        #expect(kmap.frequency(of: 69) == 440)
        #expect(kmap.frequency(of: 61) == nil)
        #expect(kmap.frequency(of: 66) == nil)
        #expect(kmap.frequency(of: 70) == nil)
        assertEqual(kmap.frequency(of: 72)?.numberValue, key60.numberValue * 3)
    }

    @Test
    func degree_wrapPlacesLaterSlotsInNextPeriod() throws {
        // Degree 5 on key 60; degree 0 on key 63, in the next period.
        let layout = try KeyboardLayout(degrees: [5, 7, 9, 0, 2],
                                        referenceNote: 60)
        let kmap = try makeKeyboardMap(layout)

        #expect(kmap.frequency(of: 60) == 440)
        assertEqual(kmap.frequency(of: 63)?.numberValue, 440 * Number(Foundation.pow(2.0, 7.0 / 12.0)))
        assertEqual(kmap.frequency(of: 65)?.numberValue, 880)
    }

    @Test
    func nearestKey_duplicatePitches_tieToLowerKey() throws {
        // 7-TET on the white keys, 5-TET on the black keys: C and C♯ sound the same pitch.
        let white = (0..<7).map { Ratio(cents: Number($0) * 1_200 / 7) }
        let black = (0..<5).map { Ratio(cents: Number($0) * 1_200 / 5) }
        let layout = try KeyboardLayout(ratios: [white[0],
                                                 black[0],
                                                 white[1],
                                                 black[1],
                                                 white[2],
                                                 white[3],
                                                 black[2],
                                                 white[4],
                                                 black[3],
                                                 white[5],
                                                 black[4],
                                                 white[6]],
                                        equivalenceRatio: .octave,
                                        referenceFrequency: 440)
        let kmap = try KeyboardMap(rawLayout: layout)
        let key60 = try #require(kmap.frequency(of: 60))

        #expect(kmap.frequency(of: 61) == key60)
        #expect(kmap.nearestKey(to: key60) == 60)
    }

    @Test
    func nearestKey_edgeOfRange_usesNearestDistinctPitch() throws {
        var frequencies = [Frequency?](repeating: nil, count: 128)

        frequencies[10] = 100
        frequencies[11] = 100
        frequencies[12] = 200

        let kmap = try KeyboardMap(rawLayout: KeyboardLayout(frequencies: frequencies))

        // Half an octave below 100 Hz is ≈ 70.7 Hz.
        #expect(kmap.nearestKey(to: 80) == 10)
        #expect(kmap.nearestKey(to: 60) == nil)
        #expect(kmap.nearestKey(to: 270) == 12)
        #expect(kmap.nearestKey(to: 290) == nil)
    }

    @Test
    func nearestKey_nearest() throws {
        let kmap = try #require(piano)

        #expect(kmap.nearestKey(to: 445) == 69)
        #expect(kmap.nearestKey(to: 460) == 70)
        #expect(kmap.nearestKey(to: 220) == 57)
        #expect(kmap.nearestKey(to: 880) == 81)
    }

    @Test
    func nearestKey_outOfRange() throws {
        let kmap = try #require(piano)
        let justBelowLowest = try #require(Frequency(uintValue: 7_900_000))   // ≈ 59 ¢ below MIDI 0

        #expect(kmap.nearestKey(to: 8) == 0)                          // ≈ 38 ¢ below MIDI 0
        #expect(kmap.nearestKey(to: justBelowLowest) == nil)
        #expect(kmap.nearestKey(to: 12_900) == 127)                   // ≈ 49 ¢ above MIDI 127
        #expect(kmap.nearestKey(to: 13_000) == nil)                   // ≈ 62 ¢ above MIDI 127
    }

    @Test
    func nearestKey_singleDistinctPitch_hasNoOuterLimit() throws {
        var frequencies = [Frequency?](repeating: nil, count: 128)

        frequencies[5] = 100
        frequencies[6] = 100

        let kmap = try KeyboardMap(rawLayout: KeyboardLayout(frequencies: frequencies))

        #expect(kmap.nearestKey(to: 1) == 5)
        #expect(kmap.nearestKey(to: 10_000) == 5)
    }

    @Test
    func nearestKey_tie_fallsBackToLowerKey() throws {
        let kmap = try makeKeyboardMap(#require(nineteenSubset), EqualTemperament.edo19)
        let aFlat4 = try #require(StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.edo19)
            .convert(Pitch(pitchClass: .aFlat, octave: 4)))

        #expect(kmap.nearestKey(to: aFlat4) == 68)                  // no letter
        #expect(kmap.nearestKey(to: aFlat4, letter: .b) == 68)      // neither key shares it
    }

    @Test
    func nearestKey_tie_letterRule() throws {
        let kmap = try makeKeyboardMap(#require(nineteenSubset), EqualTemperament.edo19)
        let aFlat4 = try #require(StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.edo19)
            .convert(Pitch(pitchClass: .aFlat, octave: 4)))

        #expect(kmap.nearestKey(to: aFlat4, letter: .a) == 69)
        #expect(kmap.nearestKey(to: aFlat4, letter: .g) == 68)
    }

    @Test
    func nearestKey_within() throws {
        let kmap = try #require(piano)
        let threeCentsUp = try #require(Frequency(440).transposed(by: DirectedInterval(interval: Ratio(cents: 3),
                                                                                       direction: .ascending)))
        let tenCentsUp = try #require(Frequency(440).transposed(by: DirectedInterval(interval: Ratio(cents: 10),
                                                                                     direction: .ascending)))

        #expect(kmap.nearestKey(to: threeCentsUp, keyMatching: .within(Ratio(cents: 5))) == 69)
        #expect(kmap.nearestKey(to: tenCentsUp, keyMatching: .within(Ratio(cents: 5))) == nil)
        #expect(kmap.nearestKey(to: tenCentsUp, keyMatching: .nearest) == 69)
        #expect(kmap.nearestKey(to: 440, keyMatching: .within(.unison)) == 69)
    }

    @Test
    func pitchClass_anchorNeedNotBeC() throws {
        let layout = try KeyboardLayout(pitchClasses: [.a,
                                                       .bFlat,
                                                       .b,
                                                       .c,
                                                       .cSharp,
                                                       .d,
                                                       .eFlat,
                                                       .e,
                                                       .f,
                                                       .fSharp,
                                                       .g,
                                                       .gSharp],
                                        anchorNote: 57,
                                        anchorOctave: 3)
        let kmap = try makeKeyboardMap(layout)

        #expect(kmap.frequency(of: 57) == 220)
        #expect(kmap.pitches?[57] == Pitch(pitchClass: .a, octave: 3))
        #expect(kmap.pitches?[60] == Pitch(pitchClass: .c, octave: 4))
        #expect(kmap.pitches?[68] == Pitch(pitchClass: .gSharp, octave: 4))
    }

    @Test
    func pitchClass_enharmonicPair_dependsOnTuning() throws {
        let layout = try KeyboardLayout(pitchClasses: [.c, .gSharp, .aFlat])

        // G♯ lies below A♭ in quarter-comma meantone and 19-EDO, …
        _ = try makeKeyboardMap(layout, LinearTemperament.quarterCommaMeantone)
        _ = try makeKeyboardMap(layout, EqualTemperament.edo19)

        // … above it in Pythagorean, …
        #expect(throws: TuningError.invalidKeyboardLayout(.slotOutsidePeriod(index: 2))) {
            try makeKeyboardMap(layout, LinearTemperament.pythagorean)
        }

        // … and sounds the same in 12-TET.
        #expect(throws: TuningError.invalidKeyboardLayout(.coincidentSlots(index: 2))) {
            try makeKeyboardMap(layout)
        }
    }

    @Test
    func pitchClass_finalCFlat_takesNextOctave() throws {
        // In 19-EDO, C♭ lies above B and below the next C.
        let layout = try KeyboardLayout(pitchClasses: [.c, .d, .e, .f, .g, .a, .b, .cFlat])
        let kmap = try makeKeyboardMap(layout, EqualTemperament.edo19)

        #expect(kmap.pitches?[67] == Pitch(pitchClass: .cFlat, octave: 5))
        #expect(kmap.pitches?[68] == Pitch(pitchClass: .c, octave: 5))
    }

    @Test
    func pitchClass_misordered_throwsSlotOutsidePeriod() throws {
        // C, D, C♯ pushes C♯ into the next octave, past the anchor.
        let layout = try KeyboardLayout(pitchClasses: [.c, .d, .cSharp])

        #expect(throws: TuningError.invalidKeyboardLayout(.slotOutsidePeriod(index: 2))) {
            try makeKeyboardMap(layout)
        }
    }

    @Test
    func pitchClass_piano_a440() throws {
        let kmap = try #require(piano)

        #expect(kmap.frequencies.count == 128)
        #expect(kmap.frequency(of: 69) == 440)
        assertEqual(kmap.frequency(of: 60), Frequency(Number(261.625565)))
        assertEqual(kmap.frequency(of: 57), 220)
        assertEqual(kmap.frequency(of: 81), 880)
        #expect(kmap.pitches?[60] == Pitch(pitchClass: .c, octave: 4))
        #expect(kmap.pitches?[63] == Pitch(pitchClass: .eFlat, octave: 4))
        #expect(kmap.pitches?[0] == Pitch(pitchClass: .c, octave: -1))
        #expect(kmap.pitches?[127] == Pitch(pitchClass: .g, octave: 9))
    }

    @Test(arguments: [(PitchStandard.a415, NoteNumber(69), Frequency(415)),
                      (.a432, 69, 432),
                      (.a435, 69, 435),
                      (.c256, 60, 256)])
    func pitchClass_pitchStandardTunesKeyboard(standard: PitchStandard,
                                               note: NoteNumber,
                                               frequency: Frequency) throws {
        #expect(try makeKeyboardMap(.piano, EqualTemperament.edo12, standard).frequency(of: note) == frequency)
    }

    @Test
    func pitchClass_rawInitializer_throwsRawLayoutRequired() {
        #expect(throws: TuningError.invalidKeyboardLayout(.rawLayoutRequired)) {
            try KeyboardMap(rawLayout: .piano)
        }
    }

    @Test
    func pitchClass_unsupportedTuning_throws() {
        #expect(throws: TuningError.unsupportedStandardConversion) {
            try makeKeyboardMap(.piano, EqualTemperament.bohlenPierce)
        }
    }

    @Test
    func raw_frequencies_copiedDirectly() throws {
        var frequencies = [Frequency?](repeating: nil, count: 128)

        frequencies[10] = 100
        frequencies[20] = 50

        let kmap = try KeyboardMap(rawLayout: KeyboardLayout(frequencies: frequencies))

        #expect(kmap.frequencies == frequencies)
    }

    @Test
    func raw_ratios_anchorNeedNotBeUnison() throws {
        // Key 60 sounds a fifth above key 61, in the same period.
        let layout = try KeyboardLayout(ratios: [Ratio(cents: 700), .unison],
                                        equivalenceRatio: .octave,
                                        referenceNote: 61,
                                        referenceFrequency: 440)
        let kmap = try KeyboardMap(rawLayout: layout)
        let fifthUp = 440 * Number(Foundation.pow(2.0, 7.0 / 12.0))

        assertEqual(kmap.frequency(of: 60)?.numberValue, fifthUp)
        assertEqual(kmap.frequency(of: 62)?.numberValue, fifthUp * 2)
        assertEqual(kmap.frequency(of: 59)?.numberValue, 220)
    }

    @Test
    func raw_ratios_ignoreTuningSystem() throws {
        let layout = try KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                        equivalenceRatio: .octave,
                                        referenceFrequency: 415)

        #expect(try makeKeyboardMap(layout, EqualTemperament.bohlenPierce, .a440) == KeyboardMap(rawLayout: layout))
        #expect(try KeyboardMap(rawLayout: layout).frequency(of: 69) == 415)
    }

    @Test
    func raw_ratios_matchPiano() throws {
        let layout = try KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                        equivalenceRatio: .octave,
                                        referenceFrequency: 440)
        let kmap = try KeyboardMap(rawLayout: layout)
        let pianoMap = try #require(piano)

        // The two tables round to the nearest microhertz by different routes, so compare relatively.
        for note in 0..<128 {
            let raw = try #require(kmap.frequencies[note]).numberValue
            let tuned = try #require(pianoMap.frequencies[note]).numberValue

            #expect(abs(raw - tuned) / tuned < Number(1e-6), "key \(note)")
        }

        #expect(kmap.pitches == nil)
    }
}
