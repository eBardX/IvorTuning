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

    @Test
    func isConversionSupported_sameNotation_isUnsupported() {
        for notation in [PitchNotation.absolute, .keyboard, .standard] {
            #expect(!notation.isConversionSupported(to: notation))
        }
    }

    @Test
    func isConversionSupported_standardToAbsolute_isSupported() {
        #expect(PitchNotation.standard.isConversionSupported(to: .absolute))
    }

    @Test(arguments: [(PitchNotation.absolute, PitchNotation.keyboard),
                      (.absolute, .standard),
                      (.keyboard, .absolute),
                      (.keyboard, .standard),
                      (.standard, .keyboard)])
    func isConversionSupported_unimplementedConverter_isUnsupported(source: PitchNotation,
                                                                    target: PitchNotation) {
        #expect(!source.isConversionSupported(to: target))
    }
}
