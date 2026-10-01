// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct FrequencyReferenceTests {
}

// MARK: -

extension FrequencyReferenceTests {
    @Test
    func equatable() {
        let reference = Frequency.Reference(frequency: 440, value: 0, unit: .cents)

        #expect(reference == Frequency.Reference(frequency: 440, value: 0, unit: .cents))
        #expect(reference != Frequency.Reference(frequency: 441, value: 0, unit: .cents))
        #expect(reference != Frequency.Reference(frequency: 440, value: 1, unit: .cents))
        #expect(reference != Frequency.Reference(frequency: 440, value: 0, unit: .savarts))
    }

    @Test(arguments: [(Ratio.Unit.cents, Number(6_900)),
                      (.hekts, Number(4_700)),
                      (.millioctaves, Number(5_700)),
                      (.savarts, Number(1_700))])
    func default_puts440AtRoundValue(unit: Ratio.Unit,
                                     value: Number) {
        let reference = Frequency.Reference.default(in: unit)

        #expect(reference.frequency == 440)
        #expect(reference.unit == unit)
        #expect(reference.value == value)
    }

    @Test
    func init_keepsValues() {
        let reference = Frequency.Reference(frequency: 432, value: Number(-12.5), unit: .hekts)

        #expect(reference.frequency == 432)
        #expect(reference.unit == .hekts)
        #expect(reference.value == Number(-12.5))
    }
}

// MARK: - Conversions

extension FrequencyReferenceTests {
    @Test(arguments: Ratio.Unit.allCases)
    func frequency_atReferenceValue_isReferenceFrequency(unit: Ratio.Unit) {
        let reference = Frequency.Reference.default(in: unit)

        #expect(reference.frequency(at: reference.value) == 440)
    }

    @Test(arguments: [(Ratio.Unit.cents, Number(8_100), Number(880)),
                      (.cents, Number(5_700), Number(220)),
                      (.millioctaves, Number(6_700), Number(880)),
                      (.savarts, Number(2_700), Number(4_400)),
                      (.savarts, Number(700), Number(44)),
                      (.hekts, Number(6_000), Number(1_320)),
                      (.hekts, Number(3_400), Number(440) / 3)])
    func frequency_atValue(unit: Ratio.Unit,
                           value: Number,
                           hertz: Number) {
        assertEqual(Frequency.Reference.default(in: unit).frequency(at: value), Frequency(hertz))
    }

    @Test(arguments: Ratio.Unit.allCases)
    func frequency_tooFarAbove_returnsNil(unit: Ratio.Unit) {
        #expect(Frequency.Reference.default(in: unit).frequency(at: Number(1e9)) == nil)
    }

    @Test(arguments: Ratio.Unit.allCases)
    func frequency_tooFarBelow_returnsNil(unit: Ratio.Unit) {
        #expect(Frequency.Reference.default(in: unit).frequency(at: Number(-1e9)) == nil)
    }

    @Test(arguments: Ratio.Unit.allCases)
    func roundTrip_aboveAndBelow(unit: Ratio.Unit) {
        let reference = Frequency.Reference(frequency: 415, value: 100, unit: unit)

        for hertz in [Number(27.5), Number(415), Number(441.123457), Number(4_186)] {
            let frequency = Frequency(hertz)
            let value = reference.value(of: frequency)

            assertEqual(reference.frequency(at: value), frequency)
        }
    }

    @Test
    func value_belowReference_isLess() {
        let reference = Frequency.Reference(frequency: 440, value: 0, unit: .cents)

        assertEqual(reference.value(of: 220), -1_200)
        assertEqual(reference.value(of: 440), 0)
        assertEqual(reference.value(of: 880), 1_200)
    }

    @Test(arguments: [(Ratio.Unit.cents, Number(880), Number(8_100)),
                      (.millioctaves, Number(880), Number(6_700)),
                      (.savarts, Number(4_400), Number(2_700)),
                      (.hekts, Number(1_320), Number(6_000))])
    func value_ofFrequency(unit: Ratio.Unit,
                           hertz: Number,
                           value: Number) {
        assertEqual(Frequency.Reference.default(in: unit).value(of: Frequency(hertz)), value)
    }
}
