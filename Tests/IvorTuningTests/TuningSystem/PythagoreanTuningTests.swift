// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct PythagoreanTuningTests {
}

// MARK: -

extension PythagoreanTuningTests {

    @Test
    func period() {
        #expect(PythagoreanTuning().period == .octave)
    }
}
