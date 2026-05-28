// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct JustIntonationCommonTests {
}

// MARK: -

extension JustIntonationCommonTests {

    @Test
    func fiveLimitJI_count() {
        #expect(JustIntonation.fiveLimitJI.ratios.count == 14)
    }

    @Test
    func fiveLimitJI_equivalenceRatio() {
        #expect(JustIntonation.fiveLimitJI.equivalenceRatio == .octave)
    }

    @Test
    func fiveLimitJI_pureFifth() throws {
        let threeHalves = try #require(Ratio(numberValue: Number(3) / Number(2)))

        #expect(JustIntonation.fiveLimitJI.ratios.contains { $0.numberValue == threeHalves.numberValue })
    }

    @Test
    func fiveLimitJI_pureMajorThird() throws {
        let fiveQuarters = try #require(Ratio(numberValue: Number(5) / Number(4)))

        #expect(JustIntonation.fiveLimitJI.ratios.contains { $0.numberValue == fiveQuarters.numberValue })
    }

    @Test
    func fiveLimitJI_standardConversion_isNil() {
        #expect(JustIntonation.fiveLimitJI.standardConversion(for: .a440) == nil)
    }

    @Test
    func partch43_count() {
        #expect(JustIntonation.partch43.ratios.count == 43)
    }

    @Test
    func partch43_equivalenceRatio() {
        #expect(JustIntonation.partch43.equivalenceRatio == .octave)
    }

    @Test
    func partch43_standardConversion_isNil() {
        #expect(JustIntonation.partch43.standardConversion(for: .a440) == nil)
    }

    @Test
    func sevenLimitJI_count() {
        #expect(JustIntonation.sevenLimitJI.ratios.count == 15)
    }

    @Test
    func sevenLimitJI_harmonicSeventh() throws {
        let sevenQuarters = try #require(Ratio(numberValue: Number(7) / Number(4)))

        #expect(JustIntonation.sevenLimitJI.ratios.contains { $0.numberValue == sevenQuarters.numberValue })
    }

    @Test
    func sevenLimitJI_includesFiveLimitFifth() throws {
        let threeHalves = try #require(Ratio(numberValue: Number(3) / Number(2)))

        #expect(JustIntonation.sevenLimitJI.ratios.contains { $0.numberValue == threeHalves.numberValue })
    }

    @Test
    func sevenLimitJI_standardConversion_isNil() {
        #expect(JustIntonation.sevenLimitJI.standardConversion(for: .a440) == nil)
    }
}
