// © 2025–2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing

struct PitchNotationTests {
}

// MARK: -

extension PitchNotationTests {
    @Test
    func codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for value in [PitchNotation.absolute, .keyboard, .standard] {
            let data = try encoder.encode(value)
            let decoded = try decoder.decode(PitchNotation.self, from: data)

            #expect(decoded == value)
        }
    }

    @Test
    func description() {
        #expect(PitchNotation.absolute.description == "absolute")
        #expect(PitchNotation.keyboard.description == "keyboard")
        #expect(PitchNotation.standard.description == "standard")
    }

    @Test
    func init_invalid() {
        #expect(throws: ParseError.self) { try PitchNotation(stringValue: "") }
        #expect(throws: ParseError.self) { try PitchNotation(stringValue: "midi") }
        #expect(throws: ParseError.self) { try PitchNotation(stringValue: "Absolute") }
    }

    @Test
    func init_valid() throws {
        #expect(try PitchNotation(stringValue: "absolute") == .absolute)
        #expect(try PitchNotation(stringValue: "keyboard") == .keyboard)
        #expect(try PitchNotation(stringValue: "standard") == .standard)
    }
}
