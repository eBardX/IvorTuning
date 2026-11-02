// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiTools

struct KeyboardLayoutSpellerTests {
}

// MARK: -

extension KeyboardLayoutSpellerTests {
    @Test
    func equality() {
        let speller1 = KeyboardLayoutSpeller(pitches: ["C4", nil, "D4"])
        let speller2 = KeyboardLayoutSpeller(pitches: ["C4", nil, "D4"])
        let speller3 = KeyboardLayoutSpeller(pitches: ["C4", "C#4", "D4"])

        #expect(speller1 == speller2)
        #expect(speller1 != speller3)
    }

    @Test
    func spell_empty() {
        let speller = KeyboardLayoutSpeller(pitches: ["C4"])

        #expect(speller.spell([]).isEmpty)
    }

    @Test
    func spell_isContextFree() {
        let speller = KeyboardLayoutSpeller(pitches: ["C4", "Eb4", "E4"])

        #expect(speller.spell([1]) == ["Eb4"])
        #expect(speller.spell([2, 1, 0]) == ["E4", "Eb4", "C4"])
        #expect(speller.spell([1, 1]) == ["Eb4", "Eb4"])
    }

    @Test
    func spell_readsLayoutSpelling() throws {
        let pitches = try #require(makeKeyboardMap(.piano).pitches)
        let speller = KeyboardLayoutSpeller(pitches: pitches)

        #expect(speller.spell([60, 61, 63, 66, 68, 70]) == ["C4", "C#4", "Eb4", "F#4", "G#4", "Bb4"])
    }
}
