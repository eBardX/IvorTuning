// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct TuningSystemTests {
}

// MARK: -

extension TuningSystemTests {
    @Test
    func equivalenceRatio_defaultsToOctave() {
        #expect(StubTuningSystem().equivalenceRatio == .octave)
    }

    @Test
    func standardConversion_defaultsToNil() {
        #expect(StubTuningSystem().standardConversion(for: .a440) == nil)
    }
}
