// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiTools

struct TuningErrorTests {
}

// MARK: -

extension TuningErrorTests {
    @Test
    func category() {
        #expect(TuningError.unsupportedStandardConversion.category?.stringValue == "IvorTuning")
    }

    @Test
    func message_unsupportedStandardConversion() {
        #expect(TuningError.unsupportedStandardConversion.message == "Tuning system does not support standard pitch notation")
    }
}
