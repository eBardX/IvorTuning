// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct PitchAccidentalTests {
}

// MARK: -

extension PitchAccidentalTests {

    @Test
    func description() {
        #expect(Pitch.Accidental.doubleFlat.description == "𝄫")
        #expect(Pitch.Accidental.flat.description == "♭")
        #expect(Pitch.Accidental.natural.description == "♮")
        #expect(Pitch.Accidental.sharp.description == "♯")
        #expect(Pitch.Accidental.doubleSharp.description == "𝄪")
    }

    @Test
    func init_invalid() {
        #expect(throws: ParseError.self) { try Pitch.Accidental(stringValue: "x?") }
        #expect(throws: ParseError.self) { try Pitch.Accidental(stringValue: "natural") }
    }

    @Test
    func init_valid_ascii() throws {
        #expect(try Pitch.Accidental(stringValue: "bb") == .doubleFlat)
        #expect(try Pitch.Accidental(stringValue: "b") == .flat)
        #expect(try Pitch.Accidental(stringValue: "") == .natural)
        #expect(try Pitch.Accidental(stringValue: "#") == .sharp)
        #expect(try Pitch.Accidental(stringValue: "x") == .doubleSharp)
    }

    @Test
    func init_valid_unicode() throws {
        #expect(try Pitch.Accidental(stringValue: "𝄫") == .doubleFlat)
        #expect(try Pitch.Accidental(stringValue: "♭") == .flat)
        #expect(try Pitch.Accidental(stringValue: "♮") == .natural)
        #expect(try Pitch.Accidental(stringValue: "♯") == .sharp)
        #expect(try Pitch.Accidental(stringValue: "𝄪") == .doubleSharp)
    }

    @Test
    func order() {
        #expect(Pitch.Accidental.doubleFlat.order == -2)
        #expect(Pitch.Accidental.flat.order == -1)
        #expect(Pitch.Accidental.natural.order == 0)
        #expect(Pitch.Accidental.sharp.order == 1)
        #expect(Pitch.Accidental.doubleSharp.order == 2)
    }
}
