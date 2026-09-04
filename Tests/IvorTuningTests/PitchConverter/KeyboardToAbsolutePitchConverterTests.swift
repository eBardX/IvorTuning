// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct KeyboardToAbsolutePitchConverterTests {
    private let keyboardMap = KeyboardMap(referenceNote: 69,
                                          referenceFrequency: 440,
                                          middleNote: 69,
                                          equivalenceRatio: .octave,
                                          ratios: Fixtures.twelveETRatios)
}

// MARK: -

extension KeyboardToAbsolutePitchConverterTests {

    @Test
    func equality() {
        let lhs = KeyboardToAbsolutePitchConverter(keyboardMap: keyboardMap)
        let rhs = KeyboardToAbsolutePitchConverter(keyboardMap: keyboardMap)

        #expect(lhs == rhs)
    }

    @Test
    func inequality() {
        let other = KeyboardMap(referenceNote: 69,
                                referenceFrequency: 440,
                                middleNote: 60,
                                equivalenceRatio: .octave,
                                ratios: Fixtures.twelveETRatios)

        let lhs = KeyboardToAbsolutePitchConverter(keyboardMap: keyboardMap)
        let rhs = KeyboardToAbsolutePitchConverter(keyboardMap: other)

        #expect(lhs != rhs)
    }
}
