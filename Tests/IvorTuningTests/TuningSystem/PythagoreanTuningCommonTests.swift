// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct PythagoreanTuningCommonTests {
}

// MARK: -

extension PythagoreanTuningCommonTests {

    @Test
    func standard_period() {
        #expect(PythagoreanTuning.standard.period == .octave)
    }
}
