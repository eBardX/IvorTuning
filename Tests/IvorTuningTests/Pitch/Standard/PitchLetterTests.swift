// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct PitchLetterTests {
}

// MARK: -

extension PitchLetterTests {

    @Test
    func description() {
        #expect(Pitch.Letter.a.description == "A")
        #expect(Pitch.Letter.b.description == "B")
        #expect(Pitch.Letter.c.description == "C")
        #expect(Pitch.Letter.d.description == "D")
        #expect(Pitch.Letter.e.description == "E")
        #expect(Pitch.Letter.f.description == "F")
        #expect(Pitch.Letter.g.description == "G")
    }

    @Test
    func init_invalid() {
        #expect(throws: ParseError.self) { try Pitch.Letter(stringValue: "H") }
        #expect(throws: ParseError.self) { try Pitch.Letter(stringValue: "h") }
        #expect(throws: ParseError.self) { try Pitch.Letter(stringValue: "") }
    }

    @Test
    func init_valid_lowercase() throws {
        #expect(try Pitch.Letter(stringValue: "a") == .a)
        #expect(try Pitch.Letter(stringValue: "b") == .b)
        #expect(try Pitch.Letter(stringValue: "c") == .c)
        #expect(try Pitch.Letter(stringValue: "d") == .d)
        #expect(try Pitch.Letter(stringValue: "e") == .e)
        #expect(try Pitch.Letter(stringValue: "f") == .f)
        #expect(try Pitch.Letter(stringValue: "g") == .g)
    }

    @Test
    func init_valid_uppercase() throws {
        #expect(try Pitch.Letter(stringValue: "A") == .a)
        #expect(try Pitch.Letter(stringValue: "B") == .b)
        #expect(try Pitch.Letter(stringValue: "C") == .c)
        #expect(try Pitch.Letter(stringValue: "D") == .d)
        #expect(try Pitch.Letter(stringValue: "E") == .e)
        #expect(try Pitch.Letter(stringValue: "F") == .f)
        #expect(try Pitch.Letter(stringValue: "G") == .g)
    }

    @Test
    func order() {
        #expect(Pitch.Letter.c.order == 1)
        #expect(Pitch.Letter.d.order == 2)
        #expect(Pitch.Letter.e.order == 3)
        #expect(Pitch.Letter.f.order == 4)
        #expect(Pitch.Letter.g.order == 5)
        #expect(Pitch.Letter.a.order == 6)
        #expect(Pitch.Letter.b.order == 7)
    }
}
