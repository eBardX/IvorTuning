// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorTuning
import Testing

struct PitchClassTests {
}

// MARK: -

extension PitchClassTests {
    @Test
    func codable() throws {
        let original = PitchClass.cSharp
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PitchClass.self, from: data)

        #expect(decoded == original)
    }

    @Test
    func description() {
        #expect(PitchClass.c.description == "C♮")
        #expect(PitchClass.cSharp.description == "C♯")
        #expect(PitchClass.cFlat.description == "C♭")
        #expect(PitchClass.cDoubleSharp.description == "C𝄪")
        #expect(PitchClass.cDoubleFlat.description == "C𝄫")
    }

    @Test
    func equatable() {
        #expect(PitchClass.c == PitchClass.c)   // swiftlint:disable:this identical_operands
        #expect(PitchClass.c != PitchClass.cSharp)
        #expect(PitchClass.aFlat != PitchClass.gSharp)
    }

    @Test
    func hashable() {
        let set: Set<PitchClass> = [.c, .c, .cSharp, .d]

        #expect(set.count == 3)
    }

    @Test
    func init_invalid() {
        #expect(throws: ParseError.self) { try PitchClass(stringValue: "X") }
        #expect(throws: ParseError.self) { try PitchClass(stringValue: "") }
        #expect(throws: ParseError.self) { try PitchClass(stringValue: "1") }
    }

    @Test
    func init_valid() throws {
        let cNat = try PitchClass(stringValue: "C")
        let cSharp = try PitchClass(stringValue: "C♯")
        let aFlat = try PitchClass(stringValue: "A♭")
        let bFlat = try PitchClass(stringValue: "Bb")

        #expect(cNat == .c)
        #expect(cSharp == .cSharp)
        #expect(aFlat == .aFlat)
        #expect(bFlat == .bFlat)
    }

    @Test
    func letterAndAccidental() {
        let pc = PitchClass.gSharp

        #expect(pc.letter == .g)
        #expect(pc.accidental == .sharp)
    }

    @Test
    func stringValue_omitNatural() {
        #expect(PitchClass.c.stringValue(omitNatural: true) == "C")
        #expect(PitchClass.cSharp.stringValue(omitNatural: true) == "C♯")
        #expect(PitchClass.d.stringValue(omitNatural: false) == "D♮")
    }
}
