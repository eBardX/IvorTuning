// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers

struct WellTemperamentTests {
}

// MARK: -

extension WellTemperamentTests {

    @Test
    func standardConversion_doubleFlatEnharmonics() throws {
        let conversion = try #require(WellTemperament.werckmeisterIII.standardConversion(for: .a440))

        // C𝄫4 = B♭3 = A♯3 (an octave below B♭4 and A♯4)
        let cDoubleFlat4 = try frequency(of: .cDoubleFlat, in: conversion)

        try assertEqual(cDoubleFlat4, frequency(of: .bFlat, in: conversion, octaveShift: -1))
        try assertEqual(cDoubleFlat4, frequency(of: .aSharp, in: conversion, octaveShift: -1))

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

        // B𝄪4 = C♯5 = D♭5 (an octave above C♯4 and D♭4)
        let bDoubleSharp4 = try frequency(of: .bDoubleSharp, in: conversion)

        try assertEqual(bDoubleSharp4, frequency(of: .cSharp, in: conversion, octaveShift: 1))
        try assertEqual(bDoubleSharp4, frequency(of: .dFlat, in: conversion, octaveShift: 1))
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
}

// MARK: - Private Functions

private func frequency(of pitchClass: PitchClass,
                       in conversion: [PitchClass: DirectedInterval<Ratio>],
                       octaveShift: Int = 0) throws -> Frequency {
    let entry = try #require(conversion[pitchClass])
    let frequency = try #require(PitchStandard.a440.frequency.transposed(by: entry))

    guard octaveShift != 0
    else { return frequency }

    let octave = DirectedInterval(interval: Ratio.octave,
                                  direction: octaveShift > 0 ? .ascending : .descending)

    return try #require(frequency.transposed(by: octave))
}
