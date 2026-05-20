// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct JustIntonationCommonTests {
}

// MARK: -

extension JustIntonationCommonTests {

    @Test
    func fiveLimit_count() {
        #expect(JustIntonation.fiveLimit.ratios.count == 14)
    }

    @Test
    func fiveLimit_period() {
        #expect(JustIntonation.fiveLimit.period == .octave)
    }

    @Test
    func fiveLimit_pureFifth() throws {
        let threeHalves = try #require(Ratio(numberValue: Number(3) / Number(2)))

        #expect(JustIntonation.fiveLimit.ratios.contains { $0.numberValue == threeHalves.numberValue })
    }

    @Test
    func fiveLimit_pureMajorThird() throws {
        let fiveQuarters = try #require(Ratio(numberValue: Number(5) / Number(4)))

        #expect(JustIntonation.fiveLimit.ratios.contains { $0.numberValue == fiveQuarters.numberValue })
    }

    @Test
    func partch43_count() {
        #expect(JustIntonation.partch43.ratios.count == 43)
    }

    @Test
    func partch43_period() {
        #expect(JustIntonation.partch43.period == .octave)
    }

    @Test
    func sevenLimit_count() {
        #expect(JustIntonation.sevenLimit.ratios.count == 15)
    }

    @Test
    func sevenLimit_harmonicSeventh() throws {
        let sevenQuarters = try #require(Ratio(numberValue: Number(7) / Number(4)))

        #expect(JustIntonation.sevenLimit.ratios.contains { $0.numberValue == sevenQuarters.numberValue })
    }

    @Test
    func sevenLimit_includesFiveLimitFifth() throws {
        let threeHalves = try #require(Ratio(numberValue: Number(3) / Number(2)))

        #expect(JustIntonation.sevenLimit.ratios.contains { $0.numberValue == threeHalves.numberValue })
    }
}
