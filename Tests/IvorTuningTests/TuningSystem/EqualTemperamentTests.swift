// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct EqualTemperamentTests {
}

// MARK: -

extension EqualTemperamentTests {

    @Test
    func stepSizeOnly_nilDivisionsAndPeriod() {
        let et = EqualTemperament(stepSize: .init(cents: 78))

        #expect(et.divisions == nil)
        #expect(et.period == nil)
    }

    @Test
    func stepSize_ordering() {
        #expect(EqualTemperament.edo31.stepSize.cents < EqualTemperament.edo19.stepSize.cents)
        #expect(EqualTemperament.edo19.stepSize.cents < EqualTemperament.edo12.stepSize.cents)
    }
}
