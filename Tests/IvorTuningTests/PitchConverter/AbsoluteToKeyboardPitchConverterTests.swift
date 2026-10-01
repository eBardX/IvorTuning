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
    func init_throwsUnsupportedConversion() {
        #expect(throws: TuningError.unsupportedConversion(from: .absolute,
                                                          to: .keyboard)) {
            try AbsoluteToKeyboardPitchConverter(keyboardMap: keyboardMap)
        }
    }
}
