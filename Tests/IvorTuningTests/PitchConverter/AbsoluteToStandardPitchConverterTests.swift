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
}

// MARK: -

extension AbsoluteToStandardPitchConverterTests {

    @Test
    func init_throwsUnsupportedConversion() {
        #expect(throws: TuningError.unsupportedConversion(from: .absolute,
                                                          to: .standard)) {
            try AbsoluteToStandardPitchConverter(keyboardMap: keyboardMap,
                                                 pitchSpeller: MeredithPitchSpeller())
        }
    }
}
