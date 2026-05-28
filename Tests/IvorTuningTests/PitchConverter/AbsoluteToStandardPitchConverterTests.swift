// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct AbsoluteToStandardPitchConverterTests {
    private static let twelveETRatios: [Ratio?] = [Ratio(cents: 0),
                                                   Ratio(cents: 100),
                                                   Ratio(cents: 200),
                                                   Ratio(cents: 300),
                                                   Ratio(cents: 400),
                                                   Ratio(cents: 500),
                                                   Ratio(cents: 600),
                                                   Ratio(cents: 700),
                                                   Ratio(cents: 800),
                                                   Ratio(cents: 900),
                                                   Ratio(cents: 1_000),
                                                   Ratio(cents: 1_100)]

    private let keyboardMap = KeyboardMap(referenceNote: 69,
                                          referenceFrequency: 440,
                                          middleNote: 69,
                                          equivalenceRatio: .octave,
                                          ratios: Self.twelveETRatios)
    private let speller = MeredithPitchSpeller()
}

// MARK: -

extension AbsoluteToStandardPitchConverterTests {

    @Test
    func equality() {
        let lhs = AbsoluteToStandardPitchConverter(keyboardMap: keyboardMap,
                                                   pitchSpeller: speller)
        let rhs = AbsoluteToStandardPitchConverter(keyboardMap: keyboardMap,
                                                   pitchSpeller: speller)

        #expect(lhs == rhs)
    }

    @Test
    func inequality() {
        let lhs = AbsoluteToStandardPitchConverter(keyboardMap: keyboardMap,
                                                   pitchSpeller: speller)
        let rhs = AbsoluteToStandardPitchConverter(keyboardMap: keyboardMap,
                                                   pitchSpeller: MeredithPitchSpeller(contextBefore: 5))

        #expect(lhs != rhs)
    }
}
