// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiNumbers

struct EqualTemperamentCommonTests {
}

// MARK: -

extension EqualTemperamentCommonTests {

    @Test
    func bohlenPierce_equivalenceRatio() {
        #expect(EqualTemperament.bohlenPierce.equivalenceRatio == .tritave)
    }

    @Test
    func bohlenPierce_divisions() {
        #expect(EqualTemperament.bohlenPierce.divisions == 13)
    }

    @Test
    func carlosAlpha_structure() {
        #expect(EqualTemperament.carlosAlpha.divisions == 9)
        #expect(EqualTemperament.carlosAlpha.equivalenceRatio == Ratio(3, 2))
    }

    @Test
    func carlosBeta_structure() {
        #expect(EqualTemperament.carlosBeta.divisions == 11)
        #expect(EqualTemperament.carlosBeta.equivalenceRatio == Ratio(3, 2))
    }

    @Test
    func carlosGamma_structure() {
        #expect(EqualTemperament.carlosGamma.divisions == 20)
        #expect(EqualTemperament.carlosGamma.equivalenceRatio == Ratio(3, 2))
    }

    @Test
    func edo12_divisions() {
        #expect(EqualTemperament.edo12.divisions == 12)
    }

    @Test
    func edo19_divisions() {
        #expect(EqualTemperament.edo19.divisions == 19)
    }

    @Test
    func edo22_divisions() {
        #expect(EqualTemperament.edo22.divisions == 22)
    }

    @Test
    func edo24_divisions() {
        #expect(EqualTemperament.edo24.divisions == 24)
    }

    @Test
    func edo31_divisions() {
        #expect(EqualTemperament.edo31.divisions == 31)
    }

    @Test
    func edo53_divisions() {
        #expect(EqualTemperament.edo53.divisions == 53)
    }
}
