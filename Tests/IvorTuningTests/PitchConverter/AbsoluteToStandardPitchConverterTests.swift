// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct AbsoluteToStandardPitchConverterTests {
    private let converter = AbsoluteToStandardPitchConverter()

    private let toFrequency = KeyboardToAbsolutePitchConverter()

    // E major: E4 F♯4 G♯4 A4 B4 C♯5 D♯5 E5
    private var eMajor: [Frequency] {
        [64, 66, 68, 69, 71, 73, 75, 76].map { toFrequency.convert(NoteNumber(uintValue: $0).require()).require() }
    }
}

// MARK: -

extension AbsoluteToStandardPitchConverterTests {
    @Test
    func convert_default_sequenceUsesContext() {
        let result = converter.convert(eMajor)

        #expect(result.count == 8)
        #expect(result[6] == "D#5")
    }

    @Test
    func convert_default_singleFrequencyGetsDefaultSpelling() {
        #expect(converter.convert(440) == "A4")
        #expect(converter.convert(445) == "A4")
        #expect(converter.convert(eMajor[6]) == "Eb5")
    }

    @Test
    func convert_keyMatchingWithin() throws {
        let strict = try AbsoluteToStandardPitchConverter(keyboardLayout: .piano,
                                                          tuningSystem: EqualTemperament.edo12,
                                                          pitchSpeller: MeredithPitchSpeller(),
                                                          keyMatching: .within(Ratio(cents: 5)))

        #expect(strict.convert(440) == "A4")
        #expect(strict.convert(450) == nil)
    }

    @Test
    func convert_layoutSpelling_meantoneKeyboard() throws {
        // On the meantone E♭–G♯ keyboard, the key between D and E is E♭, whatever the context.
        let meantone = try AbsoluteToStandardPitchConverter(keyboardLayout: .piano,
                                                            tuningSystem: LinearTemperament.quarterCommaMeantone)
        let toMeantone = try KeyboardToAbsolutePitchConverter(keyboardLayout: .piano,
                                                              tuningSystem: LinearTemperament.quarterCommaMeantone)
        let frequencies = try [64, 66, 68, 69, 71, 73, 75, 76].map {
            try #require(toMeantone.convert(NoteNumber(uintValue: $0).require()))
        }

        #expect(meantone.convert(frequencies) == ["E4", "F#4", "G#4", "A4", "B4", "C#5", "Eb5", "E5"])
    }

    @Test
    func convert_layoutSpelling_nineteenKeys() throws {
        let nineteen = try KeyboardLayout(pitchClasses: [.c,
                                                         .cSharp,
                                                         .dFlat,
                                                         .d,
                                                         .dSharp,
                                                         .eFlat,
                                                         .e,
                                                         .eSharp,
                                                         .f,
                                                         .fSharp,
                                                         .gFlat,
                                                         .g,
                                                         .gSharp,
                                                         .aFlat,
                                                         .a,
                                                         .aSharp,
                                                         .bFlat,
                                                         .b,
                                                         .bSharp])
        let spelled = try AbsoluteToStandardPitchConverter(keyboardLayout: nineteen,
                                                           tuningSystem: EqualTemperament.edo19)
        let standard = try StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.edo19)

        for pitch: Pitch in ["C4", "Db4", "D#4", "E#4", "Ab4", "B#4"] {
            #expect(try spelled.convert(#require(standard.convert(pitch))) == pitch)
        }
    }

    @Test
    func convert_outOfRange_staysNilInSequence() {
        #expect(converter.convert([440, 13_000, 220]) == ["A4", nil, "A3"])
    }

    @Test
    func convert_rawLayoutWithSpeller() throws {
        let raw = try KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                     equivalenceRatio: .octave,
                                     referenceFrequency: 440)
        let spelled = try AbsoluteToStandardPitchConverter(keyboardLayout: raw,
                                                           pitchSpeller: MeredithPitchSpeller())

        #expect(spelled.convert(eMajor)[6] == "D#5")
    }

    @Test
    func equality() throws {
        #expect(try converter == AbsoluteToStandardPitchConverter(keyboardLayout: .piano,
                                                                  tuningSystem: EqualTemperament.edo12,
                                                                  pitchSpeller: MeredithPitchSpeller()))
        #expect(try converter != AbsoluteToStandardPitchConverter(keyboardLayout: .piano,
                                                                  tuningSystem: EqualTemperament.edo12,
                                                                  pitchStandard: .a415,
                                                                  pitchSpeller: MeredithPitchSpeller()))
    }

    @Test
    func init_full_rawLayout_throwsRawLayoutNotAllowed() throws {
        let raw = try KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                     equivalenceRatio: .octave,
                                     referenceFrequency: 440)

        #expect(throws: TuningError.invalidKeyboardLayout(.rawLayoutNotAllowed)) {
            try AbsoluteToStandardPitchConverter(keyboardLayout: raw,
                                                 tuningSystem: EqualTemperament.edo12,
                                                 pitchSpeller: MeredithPitchSpeller())
        }
    }

    @Test
    func init_layoutSpeller_degreeLayout_throwsPitchClassLayoutRequired() {
        #expect(throws: TuningError.invalidKeyboardLayout(.pitchClassLayoutRequired)) {
            try AbsoluteToStandardPitchConverter(keyboardLayout: .bohlenPierce,
                                                 tuningSystem: EqualTemperament.bohlenPierce)
        }
    }

    @Test
    func init_short_frequencyLayout_throwsNotTwelveKeysPerOctave() throws {
        let frequencies = try KeyboardLayout(frequencies: [Frequency?](repeating: 440, count: 128))

        #expect(throws: TuningError.invalidKeyboardLayout(.notTwelveKeysPerOctave)) {
            try AbsoluteToStandardPitchConverter(keyboardLayout: frequencies,
                                                 pitchSpeller: MeredithPitchSpeller())
        }
    }

    @Test
    func init_short_patternedLayout_throwsRawLayoutRequired() {
        #expect(throws: TuningError.invalidKeyboardLayout(.rawLayoutRequired)) {
            try AbsoluteToStandardPitchConverter(keyboardLayout: .piano,
                                                 pitchSpeller: MeredithPitchSpeller())
        }
    }

    @Test
    func init_speller_degreeLayoutWithTwelveKeys_succeeds() throws {
        let degrees = try KeyboardLayout(degrees: Array(0..<12))
        let spelled = try AbsoluteToStandardPitchConverter(keyboardLayout: degrees,
                                                           tuningSystem: EqualTemperament.edo12,
                                                           pitchSpeller: MeredithPitchSpeller())

        #expect(spelled.convert(440) == "A4")
    }

    @Test
    func init_speller_lambda_throwsNotTwelveKeysPerOctave() throws {
        // 12 slots, but the period is a tritave.
        let lambda = try KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])

        #expect(throws: TuningError.invalidKeyboardLayout(.notTwelveKeysPerOctave)) {
            try AbsoluteToStandardPitchConverter(keyboardLayout: lambda,
                                                 tuningSystem: EqualTemperament.bohlenPierce,
                                                 pitchSpeller: MeredithPitchSpeller())
        }
    }
}
