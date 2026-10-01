// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiNumbers

struct RatioUnitTests {
}

// MARK: -

extension RatioUnitTests {
    @Test
    func allCases() {
        #expect(Ratio.Unit.allCases == [.cents, .hekts, .millioctaves, .savarts])
    }

    @Test
    func codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for unit in Ratio.Unit.allCases {
            let data = try encoder.encode(unit)

            #expect(try decoder.decode(Ratio.Unit.self, from: data) == unit)
        }
    }

    @Test(arguments: [(Ratio.Unit.cents, Number(1_200), Ratio.octave),
                      (.hekts, Number(1_300), .tritave),
                      (.millioctaves, Number(1_000), .octave),
                      (.savarts, Number(1_000), Ratio(10))])
    func divisionsAndPeriod(unit: Ratio.Unit,
                            divisions: Number,
                            period: Ratio) {
        #expect(unit.divisions == divisions)
        #expect(unit.period == period)
        assertEqual(Ratio(divisions, in: unit), period)
    }
}

// MARK: - Conversion Shorthands

extension RatioUnitTests {
    @Test
    func cents_roundTrip() {
        let value = Number(700)
        let ratio = Ratio(cents: value)

        assertEqual(ratio.cents, value)
    }

    @Test
    func hekts_roundTrip() {
        let value = Number(867)
        let ratio = Ratio(hekts: value)

        assertEqual(ratio.hekts, value)
    }

    @Test
    func millioctaves_roundTrip() {
        let value = Number(583)
        let ratio = Ratio(millioctaves: value)

        assertEqual(ratio.millioctaves, value)
    }

    @Test
    func savarts_roundTrip() {
        let value = Number(301)
        let ratio = Ratio(savarts: value)

        assertEqual(ratio.savarts, value)
    }
}

// MARK: - Conversions

extension RatioUnitTests {
    @Test(arguments: Ratio.Unit.allCases)
    func init_negative_returnsNil(unit: Ratio.Unit) {
        #expect(Ratio(-1, in: unit) == nil)
    }

    @Test(arguments: Ratio.Unit.allCases)
    func init_tooLarge_returnsNil(unit: Ratio.Unit) {
        #expect(Ratio(Number(1e9), in: unit) == nil)
    }

    @Test(arguments: Ratio.Unit.allCases)
    func init_zero_isUnison(unit: Ratio.Unit) {
        assertEqual(Ratio(0, in: unit), .unison)
    }

    @Test
    func init_matchesConveniences() {
        assertEqual(Ratio(700, in: .cents), Ratio(cents: 700))
        assertEqual(Ratio(867, in: .hekts), Ratio(hekts: 867))
        assertEqual(Ratio(583, in: .millioctaves), Ratio(millioctaves: 583))
        assertEqual(Ratio(301, in: .savarts), Ratio(savarts: 301))
    }

    @Test(arguments: Ratio.Unit.allCases)
    func value_roundTrip(unit: Ratio.Unit) throws {
        let ratio = try #require(Ratio(Number(456.75), in: unit))

        assertEqual(ratio.value(in: unit), Number(456.75))
    }

    @Test
    func value_unitsAgree() {
        assertEqual(Ratio.octave.value(in: .cents), 1_200)
        assertEqual(Ratio.octave.value(in: .millioctaves), 1_000)
        assertEqual(Ratio.tritave.value(in: .hekts), 1_300)
        assertEqual(Ratio(10).value(in: .savarts), 1_000)
        assertEqual(Ratio.unison.value(in: .cents), 0)
    }
}
