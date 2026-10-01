// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct KeyboardToStandardPitchConverterTests {
}

// MARK: -

extension KeyboardToStandardPitchConverterTests {

    @Test
    func init_throwsUnsupportedConversion() {
        #expect(throws: TuningError.unsupportedConversion(from: .keyboard,
                                                          to: .standard)) {
            try KeyboardToStandardPitchConverter(pitchSpeller: MeredithPitchSpeller())
        }
    }
}
