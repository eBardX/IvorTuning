// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct AbsoluteToKeyboardPitchConverterTests {
    private let converter = AbsoluteToKeyboardPitchConverter()

    private let lambda = try? KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])

    private let raw440 = try? KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                             equivalenceRatio: .octave,
                                             referenceFrequency: 440)
}

// MARK: -

extension AbsoluteToKeyboardPitchConverterTests {
    @Test
    func convert_default_pianoKeys() {
        #expect(converter.convert(440) == 69)
        #expect(converter.convert(445) == 69)
        #expect(converter.convert(460) == 70)
        #expect(converter.convert(220) == 57)
        #expect(converter.convert(262) == 60)
    }

    @Test
    func convert_default_rangeEdges() {
        #expect(converter.convert(8) == 0)
        #expect(converter.convert(12_900) == 127)
        #expect(converter.convert(13_000) == nil)
    }

    @Test
    func convert_interleavedScales_unisonTiesToLowerKey() throws {
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
        let toKey = try AbsoluteToKeyboardPitchConverter(keyboardLayout: layout)
        let toFrequency = try KeyboardToAbsolutePitchConverter(keyboardLayout: layout)

        #expect(try toKey.convert(#require(toFrequency.convert(61))) == 60)
        #expect(try toKey.convert(#require(toFrequency.convert(62))) == 62)
    }

    @Test
    func convert_lambda_keyMatchingWithin() throws {
        let lambdaLayout = try #require(lambda)
        let strict = try AbsoluteToKeyboardPitchConverter(keyboardLayout: lambdaLayout,
                                                          tuningSystem: EqualTemperament.bohlenPierce,
                                                          pitchStandard: .a440,
                                                          keyMatching: .within(Ratio(cents: 5)))
        let toFrequency = try KeyboardToAbsolutePitchConverter(keyboardLayout: lambdaLayout,
                                                               tuningSystem: EqualTemperament.bohlenPierce)

        #expect(try strict.convert(bohlenPierceDegree1(on: lambdaLayout)) == nil)
        #expect(try strict.convert(#require(toFrequency.convert(62))) == 62)    // degree 2
        #expect(strict.convert(440) == 69)
    }

    @Test
    func convert_lambda_nearestKey() throws {
        let lambdaLayout = try #require(lambda)
        let lambdaConverter = try AbsoluteToKeyboardPitchConverter(keyboardLayout: lambdaLayout,
                                                                   tuningSystem: EqualTemperament.bohlenPierce)

        // Lambda leaves out degree 1; its neighbors, degrees 0 and 2, are equally near, so it goes
        // to the lower key.
        #expect(lambdaConverter.convert(440) == 69)
        #expect(try lambdaConverter.convert(bohlenPierceDegree1(on: lambdaLayout)) == 60)
    }

    @Test
    func convert_rawLayout() throws {
        let rawConverter = try AbsoluteToKeyboardPitchConverter(keyboardLayout: #require(raw440))

        #expect(rawConverter.convert(440) == 69)
        #expect(rawConverter.convert(262) == 60)
    }

    @Test
    func convert_sequence_mapsEachFrequency() {
        #expect(converter.convert([440, 220, 13_000]) == [69, 57, nil])
    }

    @Test
    func equality() throws {
        #expect(try converter == AbsoluteToKeyboardPitchConverter(keyboardLayout: .piano,
                                                                  tuningSystem: EqualTemperament.edo12,
                                                                  pitchStandard: .a440))
        #expect(try converter != AbsoluteToKeyboardPitchConverter(keyboardLayout: .piano,
                                                                  tuningSystem: EqualTemperament.edo12,
                                                                  pitchStandard: .a415))
        #expect(try converter != AbsoluteToKeyboardPitchConverter(keyboardLayout: .piano,
                                                                  tuningSystem: EqualTemperament.edo12,
                                                                  keyMatching: .within(.unison)))
    }

    @Test
    func init_full_rawLayout_throwsRawLayoutNotAllowed() throws {
        let layout = try #require(raw440)

        #expect(throws: TuningError.invalidKeyboardLayout(.rawLayoutNotAllowed)) {
            try AbsoluteToKeyboardPitchConverter(keyboardLayout: layout,
                                                 tuningSystem: EqualTemperament.edo12)
        }
    }

    @Test
    func init_pitchClassLayout_unsupportedTuning_throws() {
        #expect(throws: TuningError.unsupportedStandardConversion) {
            try AbsoluteToKeyboardPitchConverter(keyboardLayout: .piano,
                                                 tuningSystem: EqualTemperament.bohlenPierce)
        }
    }

    @Test
    func init_short_patternedLayout_throwsRawLayoutRequired() {
        #expect(throws: TuningError.invalidKeyboardLayout(.rawLayoutRequired)) {
            try AbsoluteToKeyboardPitchConverter(keyboardLayout: .piano)
        }
    }
}
