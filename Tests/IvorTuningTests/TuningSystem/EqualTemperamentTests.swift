// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct EqualTemperamentTests {
}

// MARK: -

extension EqualTemperamentTests {

    @Test
    func divisions_ordering() {
        #expect(EqualTemperament.edo12.divisions < EqualTemperament.edo19.divisions)
        #expect(EqualTemperament.edo19.divisions < EqualTemperament.edo31.divisions)
    }

    @Test
    func standardConversion_nonOctave_isNil() {
        #expect(EqualTemperament.bohlenPierce.standardConversion(for: .a440) == nil)
        #expect(EqualTemperament.carlosAlpha.standardConversion(for: .a440) == nil)
    }

    @Test
    func standardConversion_has35Entries() {
        #expect(EqualTemperament.edo12.standardConversion(for: .a440)?.count == 35)
    }

    @Test
    func standardConversion_referenceIsSame() throws {
        let conversion = try #require(EqualTemperament.edo12.standardConversion(for: .a440),
                                      "standardConversion returned nil")

        #expect(conversion[.a]?.direction == .same)
        #expect(conversion[.a]?.interval == .unison)
    }

    @Test
    func standardConversion_sameOctaveConvention() throws {
        // With A4 as reference, B♮ should map to ascending 2 semitones (B4, above A4),
        // not descending 10 semitones to B3. C♮ maps to C4 (9 semitones below A4).
        let conversion = try #require(EqualTemperament.edo12.standardConversion(for: .a440),
                                      "standardConversion returned nil")

        assertEqual(conversion[.b], (Ratio(cents: 200), .ascending))
        assertEqual(conversion[.c], (Ratio(cents: 900), .descending))
    }

    @Test
    func standardConversion_edo19() throws {
        let conversion = try #require(EqualTemperament.edo19.standardConversion(for: .a440))

        #expect(conversion.count == 35)
        #expect(conversion[.a]?.direction == .same)
        // B is 3 steps above A in 19-EDO (3/19 of an octave)
        #expect(conversion[.b]?.direction == .ascending)
        assertEqual(conversion[.b]?.interval, Ratio(cents: 3.0 * 1_200.0 / 19.0))
    }
}
