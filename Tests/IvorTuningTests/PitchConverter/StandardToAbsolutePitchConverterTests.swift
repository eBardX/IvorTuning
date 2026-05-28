// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct StandardToAbsolutePitchConverterTests {
    private let converter: StandardToAbsolutePitchConverter

    init() throws {
        self.converter = try StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.edo12,
                                                              pitchStandard: .a440)
    }
}

// MARK: -

extension StandardToAbsolutePitchConverterTests {

    @Test
    func convert_referenceNote() {
        assertEqual(converter.convert("A4"), 440)
    }

    @Test
    func convert_octaveAbove() {
        assertEqual(converter.convert("A5"), 880)
    }

    @Test
    func convert_octaveBelow() {
        assertEqual(converter.convert("A3"), 220)
    }

    @Test
    func convert_unsupportedTuning_throws() {
        #expect(throws: TuningError.unsupportedStandardConversion) {
            try StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.bohlenPierce)
        }
    }

    @Test
    func convert_inOctave() throws {
        // C4 is 9 semitones below A4 in 12-EDO
        let di = DirectedInterval(interval: Ratio(cents: 900), direction: .descending)
        let expected = try #require(PitchStandard.a440.frequency.transposed(by: di))

        assertEqual(converter.convert("C4"), expected)
    }

    @Test
    func convert_crossOctave() throws {
        // C5 is 3 semitones above A4 (same-SPN-octave maps C to C4, then shift +1)
        let di = DirectedInterval(interval: Ratio(cents: 300), direction: .ascending)
        let expected = try #require(PitchStandard.a440.frequency.transposed(by: di))

        assertEqual(converter.convert("C5"), expected)
    }

    @Test
    func equality() throws {
        let lhs = try StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.edo12,
                                                       pitchStandard: .a440)
        let rhs = try StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.edo12,
                                                       pitchStandard: .a440)

        #expect(lhs == rhs)
    }

    @Test
    func inequality() throws {
        let lhs = try StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.edo12,
                                                       pitchStandard: .a440)
        let rhs = try StandardToAbsolutePitchConverter(tuningSystem: EqualTemperament.edo12,
                                                       pitchStandard: .a432)

        #expect(lhs != rhs)
    }
}
