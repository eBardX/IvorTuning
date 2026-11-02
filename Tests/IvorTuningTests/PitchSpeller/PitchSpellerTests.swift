// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiTools

struct PitchSpellerTests {
}

// MARK: -

extension PitchSpellerTests {
    @Test
    func spellMapped_allNil() {
        #expect(MeredithPitchSpeller().spellMapped([nil, nil]) == [nil, nil])
    }

    @Test
    func spellMapped_empty() {
        #expect(MeredithPitchSpeller().spellMapped([]).isEmpty)
    }

    @Test
    func spellMapped_keepsNilInPlace() {
        let result = MeredithPitchSpeller().spellMapped([nil, 60, nil, 69, nil])

        #expect(result == [nil, "C4", nil, "A4", nil])
    }

    @Test
    func spellMapped_spellsNonNilNotesTogether() {
        let speller = MeredithPitchSpeller()
        let eMajor: [NoteNumber] = [64, 66, 68, 69, 71, 73, 75, 76]
        let withGaps: [NoteNumber?] = [64, nil, 66, 68, 69, 71, 73, nil, 75, 76]

        let expected = speller.spell(eMajor)
        let result = speller.spellMapped(withGaps)

        #expect(result.compactMap(\.self) == expected)
        #expect(result[8] == "D#5")
    }
}
