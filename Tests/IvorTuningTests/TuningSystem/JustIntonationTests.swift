// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct JustIntonationTests {
}

// MARK: -

extension JustIntonationTests {

    @Test
    func equivalenceRatio_custom() {
        let ji = JustIntonation(ratios: [], equivalenceRatio: .tritave)

        #expect(ji.equivalenceRatio == .tritave)
    }

    @Test
    func equivalenceRatio_defaultsToOctave() {
        #expect(JustIntonation(ratios: []).equivalenceRatio == .octave)
    }

    @Test
    func ratios_includesEquivalenceRatioEndpoints() throws {
        let threeHalves = try #require(Ratio(numberValue: Number(3) / Number(2)))
        let ji = JustIntonation(ratios: [threeHalves])

        #expect(ji.ratios.first == .unison)
        #expect(ji.ratios.last == .octave)
    }

    @Test
    func ratios_outOfRangeReduced() throws {
        // 5:2 (major tenth) should fold to 5:4 (major third)
        let fiveHalves   = try #require(Ratio(numberValue: Number(5) / Number(2)))
        let fiveQuarters = try #require(Ratio(numberValue: Number(5) / Number(4)))
        let ji = JustIntonation(ratios: [fiveHalves])

        #expect(ji.ratios.contains { $0.numberValue == fiveQuarters.numberValue })
    }

    @Test
    func ratios_equivalenceRatioDiscarded() {
        // Passing the equivalence ratio explicitly should not create an interior entry
        let ji = JustIntonation(ratios: [.octave])

        #expect(ji.ratios.count == 2)
    }

    @Test
    func ratios_sorted() throws {
        let threeHalves  = try #require(Ratio(numberValue: Number(3) / Number(2)))
        let fiveQuarters = try #require(Ratio(numberValue: Number(5) / Number(4)))
        // Pass in descending order; result should be ascending
        let ji = JustIntonation(ratios: [threeHalves, fiveQuarters])

        #expect(ji.ratios[1].numberValue == fiveQuarters.numberValue)
        #expect(ji.ratios[2].numberValue == threeHalves.numberValue)
    }

    @Test
    func ratios_unisonDiscarded() throws {
        let threeHalves = try #require(Ratio(numberValue: Number(3) / Number(2)))
        // Passing 1:1 explicitly should not add an extra interior entry
        let ji = JustIntonation(ratios: [.unison, threeHalves])

        #expect(ji.ratios.count == 3)
    }
}
