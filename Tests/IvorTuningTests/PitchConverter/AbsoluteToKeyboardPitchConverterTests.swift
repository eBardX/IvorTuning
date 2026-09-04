// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct AbsoluteToKeyboardPitchConverterTests {
    private let keyboardMap = KeyboardMap(referenceNote: 69,
                                          referenceFrequency: 440,
                                          middleNote: 69,
                                          equivalenceRatio: .octave,
                                          ratios: Fixtures.twelveETRatios)
}

// MARK: -

extension AbsoluteToKeyboardPitchConverterTests {

    @Test
    func equality() {
        let lhs = AbsoluteToKeyboardPitchConverter(keyboardMap: keyboardMap)
        let rhs = AbsoluteToKeyboardPitchConverter(keyboardMap: keyboardMap)

        #expect(lhs == rhs)
    }

    @Test
    func inequality() {
        let other = KeyboardMap(referenceNote: 69,
                                referenceFrequency: 440,
                                middleNote: 60,
                                equivalenceRatio: .octave,
                                ratios: Fixtures.twelveETRatios)

        let lhs = AbsoluteToKeyboardPitchConverter(keyboardMap: keyboardMap)
        let rhs = AbsoluteToKeyboardPitchConverter(keyboardMap: other)

        #expect(lhs != rhs)
    }
}
