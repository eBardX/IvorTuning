// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct LinearTemperamentTests {
}

// MARK: -

extension LinearTemperamentTests {

    @Test
    func standardConversion_has35Entries() {
        #expect(LinearTemperament.pythagorean.standardConversion(for: .a440)?.count == 35)
    }

    @Test
    func standardConversion_referenceIsSame() throws {
        let conversion = try #require(LinearTemperament.pythagorean.standardConversion(for: .a440))

        #expect(conversion[.a]?.direction == .same)
        #expect(conversion[.a]?.interval == .unison)
    }

    @Test
    func standardConversion_sameOctaveConvention() throws {
        // B4 is above A4; C4 is below A4 — same-SPN-octave convention
        let conversion = try #require(LinearTemperament.pythagorean.standardConversion(for: .a440))

        #expect(conversion[.b]?.direction == .ascending)
        #expect(conversion[.c]?.direction == .descending)
    }

    @Test
    func standardConversion_pythagorean_pureAToD() throws {
        // A is a pure fifth (3:2) above D, so D4 lies a pure fifth below A4.
        let conversion = try #require(LinearTemperament.pythagorean.standardConversion(for: .a440))
        let pureFifth = try #require(Ratio(numberValue: Number(3) / Number(2)))

        assertEqual(conversion[.d], (pureFifth, .descending))
    }

    @Test
    func standardConversion_pythagorean_pureAToE() throws {
        // E is a pure fifth below A (A→E ascending is a pure fifth; E4 lies a pure
        // fourth below A4), so the interval is exactly 4:3 descending.
        let conversion = try #require(LinearTemperament.pythagorean.standardConversion(for: .a440))
        let pureFourth = try #require(Ratio(numberValue: Number(4) / Number(3)))

        assertEqual(conversion[.e], (pureFourth, .descending))
    }

    @Test
    func standardConversion_quarterCommaMeantone_pureMajorThird() throws {
        // In quarter-comma meantone, four stacked fifths produce a pure major third (5:4).
        // With C4 as reference, E4 lies exactly 5:4 above it.
        let conversion = try #require(LinearTemperament.quarterCommaMeantone.standardConversion(for: .c256))
        let pureMajorThird = try #require(Ratio(numberValue: Number(5) / Number(4)))

        assertEqual(conversion[.e], (pureMajorThird, .ascending))
    }

    @Test
    func standardConversion_pythagorean_enharmonicsAreDistinct() throws {
        // In Pythagorean tuning, C# and Db are separated by a Pythagorean comma —
        // they are NOT enharmonically equivalent.
        let conversion = try #require(LinearTemperament.pythagorean.standardConversion(for: .a440))

        // Both lie below A4 but at different distances: C# is higher than Db,
        // so its descending interval from A4 is smaller.
        #expect(conversion[.cSharp]?.direction == .descending)
        #expect(conversion[.dFlat]?.direction == .descending)
        #expect(conversion[.cSharp]?.interval != conversion[.dFlat]?.interval)
    }

    @Test
    func standardConversion_pythagorean_bbbDistinctFromA() throws {
        // In Pythagorean tuning, B𝄫 (12 fifths below A on the fifth chain) is a
        // Pythagorean comma below A, NOT enharmonically equal to it.
        let conversion = try #require(LinearTemperament.pythagorean.standardConversion(for: .a440))
        let pythagoreanComma = try #require(Ratio(numberValue: Number(531_441) / Number(524_288)))

        assertEqual(conversion[.bDoubleFlat], (pythagoreanComma, .descending))
    }
}
