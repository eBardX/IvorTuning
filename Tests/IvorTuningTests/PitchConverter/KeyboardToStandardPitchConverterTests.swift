// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct KeyboardToStandardPitchConverterTests {
}

// MARK: -

extension KeyboardToStandardPitchConverterTests {

    @Test
    func equality() {
        let lhs = KeyboardToStandardPitchConverter(pitchSpeller: MeredithPitchSpeller())
        let rhs = KeyboardToStandardPitchConverter(pitchSpeller: MeredithPitchSpeller())

        #expect(lhs == rhs)
    }

    @Test
    func inequality() {
        let lhs = KeyboardToStandardPitchConverter(pitchSpeller: MeredithPitchSpeller())
        let rhs = KeyboardToStandardPitchConverter(pitchSpeller: MeredithPitchSpeller(contextBefore: 5))

        #expect(lhs != rhs)
    }
}
