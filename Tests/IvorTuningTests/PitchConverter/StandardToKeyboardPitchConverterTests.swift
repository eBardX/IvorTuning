// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct StandardToKeyboardPitchConverterTests {
    private let keyboardMap = KeyboardMap(referenceNote: 69,
                                          referenceFrequency: 440,
                                          middleNote: 69,
                                          equivalenceRatio: .octave,
                                          ratios: Fixtures.twelveETRatios)
}

// MARK: -

extension StandardToKeyboardPitchConverterTests {

    @Test
    func equality() {
        let lhs = StandardToKeyboardPitchConverter(keyboardMap: keyboardMap,
                                                   tuningSystem: EqualTemperament.edo12,
                                                   pitchStandard: .a440)
        let rhs = StandardToKeyboardPitchConverter(keyboardMap: keyboardMap,
                                                   tuningSystem: EqualTemperament.edo12,
                                                   pitchStandard: .a440)

        #expect(lhs == rhs)
    }

    @Test
    func inequality() {
        let lhs = StandardToKeyboardPitchConverter(keyboardMap: keyboardMap,
                                                   tuningSystem: EqualTemperament.edo12,
                                                   pitchStandard: .a440)
        let rhs = StandardToKeyboardPitchConverter(keyboardMap: keyboardMap,
                                                   tuningSystem: EqualTemperament.edo12,
                                                   pitchStandard: .a432)

        #expect(lhs != rhs)
    }
}
