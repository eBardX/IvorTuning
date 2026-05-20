// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct EqualTemperamentCommonTests {
}

// MARK: -

extension EqualTemperamentCommonTests {

    @Test
    func bohlenPierce_period() {
        #expect(EqualTemperament.bohlenPierce.period == .tritave)
    }

    @Test
    func bohlenPierce_stepSize() {
        assertEqual(EqualTemperament.bohlenPierce.stepSize.multiplied(by: 13), .tritave)
    }

    @Test
    func carlosAlpha_stepSize() throws {
        let fifth = try #require(Ratio(numberValue: Number(3) / Number(2)))

        assertEqual(EqualTemperament.carlosAlpha.stepSize.multiplied(by: 9), fifth)
    }

    @Test
    func carlosBeta_stepSize() throws {
        let fifth = try #require(Ratio(numberValue: Number(3) / Number(2)))

        assertEqual(EqualTemperament.carlosBeta.stepSize.multiplied(by: 11), fifth)
    }

    @Test
    func carlosGamma_stepSize() throws {
        let fifth = try #require(Ratio(numberValue: Number(3) / Number(2)))

        assertEqual(EqualTemperament.carlosGamma.stepSize.multiplied(by: 20), fifth)
    }

    @Test
    func edo12_stepSize() {
        assertEqual(EqualTemperament.edo12.stepSize.multiplied(by: 12), .octave)
    }

    @Test
    func edo19_stepSize() {
        assertEqual(EqualTemperament.edo19.stepSize.multiplied(by: 19), .octave)
    }

    @Test
    func edo22_stepSize() {
        assertEqual(EqualTemperament.edo22.stepSize.multiplied(by: 22), .octave)
    }

    @Test
    func edo24_stepSize() {
        assertEqual(EqualTemperament.edo24.stepSize.multiplied(by: 24), .octave)
    }

    @Test
    func edo31_stepSize() {
        assertEqual(EqualTemperament.edo31.stepSize.multiplied(by: 31), .octave)
    }

    @Test
    func edo53_stepSize() {
        assertEqual(EqualTemperament.edo53.stepSize.multiplied(by: 53), .octave)
    }
}
