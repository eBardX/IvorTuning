// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct AbsoluteToStandardPitchConverterTests {
    private let keyboardMap = KeyboardMap(referenceNote: 69,
                                          referenceFrequency: 440,
                                          middleNote: 69,
                                          equivalenceRatio: .octave,
                                          ratios: Fixtures.twelveETRatios)
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
