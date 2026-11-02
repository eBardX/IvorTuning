// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct KeyboardToAbsolutePitchConverterTests {
    private let converter = KeyboardToAbsolutePitchConverter()
}

// MARK: -

extension KeyboardToAbsolutePitchConverterTests {
    @Test
    func convert_bohlenPierce() throws {
        let bpConverter = try KeyboardToAbsolutePitchConverter(keyboardLayout: .bohlenPierce,
                                                               tuningSystem: EqualTemperament.bohlenPierce)

        #expect(bpConverter.convert(69) == 440)
        assertEqual(bpConverter.convert(60)?.numberValue, Number(440) / Number(Foundation.pow(3.0, 9.0 / 13.0)))
    }

    @Test
    func convert_default_pianoKeys() {
        #expect(converter.convert(69) == 440)
        assertEqual(converter.convert(60), Frequency(Number(261.625565)))
        assertEqual(converter.convert(57), 220)
        assertEqual(converter.convert(81), 880)
    }

    @Test
    func convert_lambda() throws {
        let lambda = try KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])
        let lambdaConverter = try KeyboardToAbsolutePitchConverter(keyboardLayout: lambda,
                                                                   tuningSystem: EqualTemperament.bohlenPierce)
        let key60 = try #require(lambdaConverter.convert(60))

        #expect(lambdaConverter.convert(69) == 440)
        #expect(lambdaConverter.convert(61) == nil)
        #expect(lambdaConverter.convert(66) == nil)
        #expect(lambdaConverter.convert(70) == nil)
        assertEqual(lambdaConverter.convert(72)?.numberValue, key60.numberValue * 3)
    }

    @Test
    func convert_matchesStandardToAbsolute() throws {
        // A pitch-class layout’s key sounds exactly what standard → absolute gives its pitch.
        let meantone = try KeyboardToAbsolutePitchConverter(keyboardLayout: .piano,
                                                            tuningSystem: LinearTemperament.quarterCommaMeantone)
        let standard = try StandardToAbsolutePitchConverter(tuningSystem: LinearTemperament.quarterCommaMeantone)

        #expect(meantone.convert(63) == standard.convert("Eb4"))
        #expect(meantone.convert(68) == standard.convert("G#4"))
    }

    @Test
    func convert_pitchStandard_tunesKeyboard() throws {
        let baroque = try KeyboardToAbsolutePitchConverter(keyboardLayout: .piano,
                                                           tuningSystem: EqualTemperament.edo12,
                                                           pitchStandard: .a415)
        let philosophical = try KeyboardToAbsolutePitchConverter(keyboardLayout: .piano,
                                                                 tuningSystem: EqualTemperament.edo12,
                                                                 pitchStandard: .c256)

        #expect(baroque.convert(69) == 415)
        #expect(philosophical.convert(60) == 256)
    }

    @Test
    func convert_rawFrequencyLayout() throws {
        var frequencies = [Frequency?](repeating: nil, count: 128)

        frequencies[0] = 30
        frequencies[127] = 20

        let raw = try KeyboardToAbsolutePitchConverter(keyboardLayout: KeyboardLayout(frequencies: frequencies))

        #expect(raw.convert(0) == 30)
        #expect(raw.convert(127) == 20)
        #expect(raw.convert(60) == nil)
    }

    @Test
    func convert_sequence_mapsEachNote() throws {
        let lambda = try KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])
        let lambdaConverter = try KeyboardToAbsolutePitchConverter(keyboardLayout: lambda,
                                                                   tuningSystem: EqualTemperament.bohlenPierce)

        #expect(lambdaConverter.convert([69, 61]) == [440, nil])
    }

    @Test
    func equality() throws {
        #expect(try converter == KeyboardToAbsolutePitchConverter(keyboardLayout: .piano,
                                                                  tuningSystem: EqualTemperament.edo12))
        #expect(try converter != KeyboardToAbsolutePitchConverter(keyboardLayout: .piano,
                                                                  tuningSystem: EqualTemperament.edo19))
    }

    @Test
    func init_degreeLayout_linearTemperament_throwsUnsupportedDegree() {
        #expect(throws: TuningError.invalidKeyboardLayout(.unsupportedDegree(index: 0))) {
            try KeyboardToAbsolutePitchConverter(keyboardLayout: .bohlenPierce,
                                                 tuningSystem: LinearTemperament.pythagorean)
        }
    }

    @Test
    func init_full_rawLayout_throwsRawLayoutNotAllowed() throws {
        let layout = try KeyboardLayout(frequencies: [Frequency?](repeating: 440, count: 128))

        #expect(throws: TuningError.invalidKeyboardLayout(.rawLayoutNotAllowed)) {
            try KeyboardToAbsolutePitchConverter(keyboardLayout: layout,
                                                 tuningSystem: EqualTemperament.edo12)
        }
    }

    @Test
    func init_short_patternedLayout_throwsRawLayoutRequired() {
        #expect(throws: TuningError.invalidKeyboardLayout(.rawLayoutRequired)) {
            try KeyboardToAbsolutePitchConverter(keyboardLayout: .bohlenPierce)
        }
    }
}
