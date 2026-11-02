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

    @Test(arguments: [(EqualTemperament.bohlenPierce, 13),
                      (.carlosAlpha, 9),
                      (.carlosBeta, 11),
                      (.carlosGamma, 20),
                      (.edo12, 12),
                      (.edo19, 19),
                      (.edo22, 22),
                      (.edo24, 24),
                      (.edo31, 31),
                      (.edo53, 53)])
    func ratioForDegree_contract_equalTemperament(system: EqualTemperament,
                                                  count: Int) {
        expectDegreeContract(system, count: count)
    }

    @Test(arguments: [JustIntonation.fiveLimitJI, .sevenLimitJI, .partch43])
    func ratioForDegree_contract_justIntonation(system: JustIntonation) {
        expectDegreeContract(system, count: system.ratios.count - 1)
    }

    @Test(arguments: [WellTemperament.kellner,
                      .kirnbergerII,
                      .kirnbergerIII,
                      .neidhardtI,
                      .neidhardtII,
                      .neidhardtIII,
                      .vallotti,
                      .werckmeisterIII,
                      .youngI,
                      .youngII])
    func ratioForDegree_contract_wellTemperament(system: WellTemperament) {
        expectDegreeContract(system, count: 12)
    }

    @Test
    func ratioForDegree_defaultsToNil() {
        #expect(StubTuningSystem().ratio(forDegree: 0) == nil)
        #expect(StubTuningSystem().ratio(forDegree: 1) == nil)
    }

    @Test(arguments: [LinearTemperament.pythagorean,
                      .quarterCommaMeantone,
                      .sixthCommaMeantone,
                      .thirdCommaMeantone,
                      .twoSeventhCommaMeantone])
    func ratioForDegree_linearTemperament_isNil(system: LinearTemperament) {
        #expect((-1...40).allSatisfy { system.ratio(forDegree: $0) == nil })
    }

    @Test
    func standardConversion_defaultsToNil() {
        #expect(StubTuningSystem().standardConversion(for: .a440) == nil)
    }
}
