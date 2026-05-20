// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct RatioIntervalUnitTests {
}

// MARK: -

extension RatioIntervalUnitTests {

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
