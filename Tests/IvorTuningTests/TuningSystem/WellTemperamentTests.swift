// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct WellTemperamentTests {
}

// MARK: -

extension WellTemperamentTests {

    @Test
    func standardConversion_has35Entries() {
        #expect(WellTemperament.werckmeisterIII.standardConversion(for: .a440)?.count == 35)
    }

    @Test
    func standardConversion_referenceIsSame() throws {
        let conversion = try #require(WellTemperament.werckmeisterIII.standardConversion(for: .a440))

        #expect(conversion[.a]?.direction == .same)
        #expect(conversion[.a]?.interval == .unison)
    }

    @Test
    func standardConversion_sameOctaveConvention() throws {
        // B4 is above A4; C4 is below A4 — same-SPN-octave convention
        let conversion = try #require(WellTemperament.werckmeisterIII.standardConversion(for: .a440))

        #expect(conversion[.b]?.direction == .ascending)
        #expect(conversion[.c]?.direction == .descending)
    }

    @Test
    func standardConversion_werckmeisterIII_pureAToE() throws {
        // In Werckmeister III, A→E is a pure fifth (3:2).
        // E4 lies a perfect fourth below A4, so the interval is exactly 4:3 descending.
        let conversion = try #require(WellTemperament.werckmeisterIII.standardConversion(for: .a440))
        let pureFourth = try #require(Ratio(numberValue: Number(4) / Number(3)))

        assertEqual(conversion[.e], (pureFourth, .descending))
    }

    @Test
    func standardConversion_enharmonicsMatch() throws {
        // In a 12-tone well temperament, enharmonically equivalent pitch classes share the
        // same frequency and therefore the same directed interval from any reference.
        let conversion = try #require(WellTemperament.werckmeisterIII.standardConversion(for: .a440))

        #expect(conversion[.cSharp]?.direction == conversion[.dFlat]?.direction)
        #expect(conversion[.cSharp]?.interval == conversion[.dFlat]?.interval)
        #expect(conversion[.fSharp]?.direction == conversion[.gFlat]?.direction)
        #expect(conversion[.fSharp]?.interval == conversion[.gFlat]?.interval)
    }

    @Test
    func standardConversion_doubleFlatEnharmonics() throws {
        let conversion = try #require(WellTemperament.werckmeisterIII.standardConversion(for: .a440))

        // C𝄫 = B♭ = A♯
        #expect(conversion[.cDoubleFlat]?.interval == conversion[.bFlat]?.interval)
        #expect(conversion[.cDoubleFlat]?.direction == conversion[.bFlat]?.direction)
        #expect(conversion[.cDoubleFlat]?.interval == conversion[.aSharp]?.interval)
        #expect(conversion[.cDoubleFlat]?.direction == conversion[.aSharp]?.direction)

        // D𝄫 = C
        #expect(conversion[.dDoubleFlat]?.interval == conversion[.c]?.interval)
        #expect(conversion[.dDoubleFlat]?.direction == conversion[.c]?.direction)

        // E𝄫 = D
        #expect(conversion[.eDoubleFlat]?.interval == conversion[.d]?.interval)
        #expect(conversion[.eDoubleFlat]?.direction == conversion[.d]?.direction)

        // F𝄫 = E♭ = D♯
        #expect(conversion[.fDoubleFlat]?.interval == conversion[.eFlat]?.interval)
        #expect(conversion[.fDoubleFlat]?.direction == conversion[.eFlat]?.direction)
        #expect(conversion[.fDoubleFlat]?.interval == conversion[.dSharp]?.interval)
        #expect(conversion[.fDoubleFlat]?.direction == conversion[.dSharp]?.direction)

        // G𝄫 = F
        #expect(conversion[.gDoubleFlat]?.interval == conversion[.f]?.interval)
        #expect(conversion[.gDoubleFlat]?.direction == conversion[.f]?.direction)

        // A𝄫 = G
        #expect(conversion[.aDoubleFlat]?.interval == conversion[.g]?.interval)
        #expect(conversion[.aDoubleFlat]?.direction == conversion[.g]?.direction)

        // B𝄫 = A
        #expect(conversion[.bDoubleFlat]?.interval == conversion[.a]?.interval)
        #expect(conversion[.bDoubleFlat]?.direction == conversion[.a]?.direction)
    }

    @Test
    func standardConversion_doubleSharpEnharmonics() throws {
        let conversion = try #require(WellTemperament.werckmeisterIII.standardConversion(for: .a440))

        // C𝄪 = D
        #expect(conversion[.cDoubleSharp]?.interval == conversion[.d]?.interval)
        #expect(conversion[.cDoubleSharp]?.direction == conversion[.d]?.direction)

        // D𝄪 = E
        #expect(conversion[.dDoubleSharp]?.interval == conversion[.e]?.interval)
        #expect(conversion[.dDoubleSharp]?.direction == conversion[.e]?.direction)

        // E𝄪 = F♯
        #expect(conversion[.eDoubleSharp]?.interval == conversion[.fSharp]?.interval)
        #expect(conversion[.eDoubleSharp]?.direction == conversion[.fSharp]?.direction)

        // F𝄪 = G
        #expect(conversion[.fDoubleSharp]?.interval == conversion[.g]?.interval)
        #expect(conversion[.fDoubleSharp]?.direction == conversion[.g]?.direction)

        // G𝄪 = A
        #expect(conversion[.gDoubleSharp]?.interval == conversion[.a]?.interval)
        #expect(conversion[.gDoubleSharp]?.direction == conversion[.a]?.direction)

        // A𝄪 = B
        #expect(conversion[.aDoubleSharp]?.interval == conversion[.b]?.interval)
        #expect(conversion[.aDoubleSharp]?.direction == conversion[.b]?.direction)

        // B𝄪 = C♯ = D♭
        #expect(conversion[.bDoubleSharp]?.interval == conversion[.cSharp]?.interval)
        #expect(conversion[.bDoubleSharp]?.direction == conversion[.cSharp]?.direction)
        #expect(conversion[.bDoubleSharp]?.interval == conversion[.dFlat]?.interval)
        #expect(conversion[.bDoubleSharp]?.direction == conversion[.dFlat]?.direction)
    }
}
