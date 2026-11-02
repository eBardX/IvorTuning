// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiNumbers

struct FifthChainTests {
}

// MARK: -

extension FifthChainTests {
    @Test
    func buildStandardConversion_fifthRatio_hasEveryPitchClass() {
        let conversion = buildStandardConversion(for: .a440,
                                                 fifthRatio: Ratio(cents: 700))

        #expect(conversion.count == 35)
    }

    @Test
    func buildStandardConversion_fifthRatio_placesPitchClassesInSPNOctave() {
        let conversion = buildStandardConversion(for: .a440,
                                                 fifthRatio: Ratio(cents: 700))

        // Every pitch class lies in the reference’s SPN octave, C4 through B4, even when another
        // octave would be nearer: B♯4 is above B4, and C♭4 is below C4.
        assertEqual(conversion[.a], (.unison, .same))
        assertEqual(conversion[.b], (Ratio(cents: 200), .ascending))
        assertEqual(conversion[.bSharp], (Ratio(cents: 300), .ascending))
        assertEqual(conversion[.c], (Ratio(cents: 900), .descending))
        assertEqual(conversion[.cFlat], (Ratio(cents: 1_000), .descending))
    }

    @Test
    func buildStandardConversion_fifthRatio_pureFifthsArePythagorean() {
        let conversion = buildStandardConversion(for: .c256,
                                                 fifthRatio: Ratio(3, 2))

        #expect(conversion[.c]?.direction == .same)
        #expect(conversion[.e]?.interval == Ratio(81, 64))
        #expect(conversion[.e]?.direction == .ascending)
        #expect(conversion[.f]?.interval == Ratio(4, 3))
        #expect(conversion[.f]?.direction == .ascending)
    }

    @Test
    func buildStandardConversion_ratioAt_usesChainPositions() {
        // Position 0 is C; each step up the chain is a fifth (here, 700 cents, octave-reduced).
        let conversion = buildStandardConversion(for: .c256) { position in
            Ratio(cents: Number((((position * 700) % 1_200) + 1_200) % 1_200))
        }

        #expect(conversion.count == 35)
        assertEqual(conversion[.c], (.unison, .same))
        assertEqual(conversion[.g], (Ratio(cents: 700), .ascending))
        assertEqual(conversion[.f], (Ratio(cents: 500), .ascending))
        assertEqual(conversion[.cSharp], (Ratio(cents: 100), .ascending))
    }
}
