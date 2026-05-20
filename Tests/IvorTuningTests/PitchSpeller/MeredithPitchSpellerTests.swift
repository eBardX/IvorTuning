// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiTools

struct MeredithPitchSpellerTests {
}

// MARK: -

extension MeredithPitchSpellerTests {

    @Test
    func init_customParameters() {
        let speller = MeredithPitchSpeller(contextBefore: 3, contextAfter: 15)

        #expect(speller.contextBefore == 3)
        #expect(speller.contextAfter == 15)
    }

    @Test
    func init_defaultParameters() {
        let speller = MeredithPitchSpeller()

        #expect(speller.contextBefore == 10)
        #expect(speller.contextAfter == 42)
    }

    @Test
    func pitchSpeller() {
        let speller: any PitchSpeller = MeredithPitchSpeller()
        let result = speller.spell([69])   // A4

        #expect(result.count == 1)
        #expect(result[0].letter == .a)
        #expect(result[0].accidental == .natural)
    }

    @Test
    func spell_bbMajorScale() {
        // Bb3 C4 D4 Eb4 F4 G4 A4 Bb4
        let result = MeredithPitchSpeller().spell([58, 60, 62, 63, 65, 67, 69, 70])

        #expect(result[0].letter == .b)
        #expect(result[0].accidental == .flat)
        #expect(result[0].octave.intValue == 3)

        #expect(result[3].letter == .e)
        #expect(result[3].accidental == .flat)
        #expect(result[3].octave.intValue == 4)

        #expect(result[7].letter == .b)
        #expect(result[7].accidental == .flat)
        #expect(result[7].octave.intValue == 4)
    }

    @Test
    func spell_cMajorScale() {
        // C4 D4 E4 F4 G4 A4 B4 C5
        let result = MeredithPitchSpeller().spell([60, 62, 64, 65, 67, 69, 71, 72])

        let expected: [(Pitch.Letter, Pitch.Accidental, Int)] = [(.c, .natural, 4),
                                                                 (.d, .natural, 4),
                                                                 (.e, .natural, 4),
                                                                 (.f, .natural, 4),
                                                                 (.g, .natural, 4),
                                                                 (.a, .natural, 4),
                                                                 (.b, .natural, 4),
                                                                 (.c, .natural, 5)]

        for (pitch, (letter, accidental, octave)) in zip(result, expected) {
            #expect(pitch.letter == letter)
            #expect(pitch.accidental == accidental)
            #expect(pitch.octave.intValue == octave)
        }
    }

    @Test
    func spell_dMajorScale() {
        // D4 E4 F#4 G4 A4 B4 C#5 D5
        let result = MeredithPitchSpeller().spell([62, 64, 66, 67, 69, 71, 73, 74])

        #expect(result[2].letter == .f)
        #expect(result[2].accidental == .sharp)
        #expect(result[2].octave.intValue == 4)

        #expect(result[6].letter == .c)
        #expect(result[6].accidental == .sharp)
        #expect(result[6].octave.intValue == 5)
    }

    @Test
    func spell_emptyInput() {
        #expect(MeredithPitchSpeller().spell([]).isEmpty)
    }

    @Test
    func spell_fMajorScale() {
        // F4 G4 A4 Bb4 C5 D5 E5 F5
        let result = MeredithPitchSpeller().spell([65, 67, 69, 70, 72, 74, 76, 77])

        #expect(result[3].letter == .b)
        #expect(result[3].accidental == .flat)
        #expect(result[3].octave.intValue == 4)
    }

    @Test
    func spell_gMajorScale() {
        // G4 A4 B4 C5 D5 E5 F#5 G5
        let result = MeredithPitchSpeller().spell([67, 69, 71, 72, 74, 76, 78, 79])

        #expect(result[6].letter == .f)
        #expect(result[6].accidental == .sharp)
        #expect(result[6].octave.intValue == 5)
    }

    @Test
    func spell_outputCount() {
        let noteNumbers: [NoteNumber] = [60, 64, 67, 68, 63, 60, 59, 64, 68, 67, 64, 60]

        #expect(MeredithPitchSpeller().spell(noteNumbers).count == noteNumbers.count)
    }

    @Test
    func spell_singleNoteA4() {
        let result = MeredithPitchSpeller().spell([69])

        #expect(result.count == 1)
        #expect(result[0].letter == .a)
        #expect(result[0].accidental == .natural)
        #expect(result[0].octave.intValue == 4)
    }

    @Test
    func spell_singleNoteBb4() {
        let result = MeredithPitchSpeller().spell([70])   // Bb4 / A#4 — defaults to Bb

        #expect(result[0].letter == .b)
        #expect(result[0].accidental == .flat)
        #expect(result[0].octave.intValue == 4)
    }

    @Test
    func spell_singleNoteC4() {
        let result = MeredithPitchSpeller().spell([60])

        #expect(result[0].letter == .c)
        #expect(result[0].accidental == .natural)
        #expect(result[0].octave.intValue == 4)
    }

    @Test
    func spell_singleNoteCs4() {
        let result = MeredithPitchSpeller().spell([61])   // C#4 / Db4 — defaults to C#

        #expect(result[0].letter == .c)
        #expect(result[0].accidental == .sharp)
        #expect(result[0].octave.intValue == 4)
    }

    @Test
    func spell_singleNoteEb4() {
        let result = MeredithPitchSpeller().spell([63])   // Eb4 / D#4 — defaults to Eb

        #expect(result[0].letter == .e)
        #expect(result[0].accidental == .flat)
        #expect(result[0].octave.intValue == 4)
    }

    @Test
    func spell_singleNoteFs4() {
        let result = MeredithPitchSpeller().spell([66])   // F#4 / Gb4 — defaults to F#

        #expect(result[0].letter == .f)
        #expect(result[0].accidental == .sharp)
        #expect(result[0].octave.intValue == 4)
    }

    @Test
    func spell_singleNoteGs4() {
        let result = MeredithPitchSpeller().spell([68])   // G#4 / Ab4 — defaults to G#

        #expect(result[0].letter == .g)
        #expect(result[0].accidental == .sharp)
        #expect(result[0].octave.intValue == 4)
    }
}
