// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct StandardToKeyboardPitchConverterTests {
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
