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
        #expect(PitchNotation(stringValue: "") == nil)
        #expect(PitchNotation(stringValue: "midi") == nil)
        #expect(PitchNotation(stringValue: "Absolute") == nil)
    }

    @Test
    func init_valid() {
        #expect(PitchNotation(stringValue: "absolute") == .absolute)
        #expect(PitchNotation(stringValue: "keyboard") == .keyboard)
        #expect(PitchNotation(stringValue: "standard") == .standard)
    }
}
