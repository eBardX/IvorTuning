// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing

struct PitchClassCommonTests {
}

// MARK: -

extension PitchClassCommonTests {
    @Test
    func a_accidentals() {
        let entries: [(PitchClass, Pitch.Letter, Pitch.Accidental)] = [(.a, .a, .natural),
                                                                       (.aDoubleFlat, .a, .doubleFlat),
                                                                       (.aDoubleSharp, .a, .doubleSharp),
                                                                       (.aFlat, .a, .flat),
                                                                       (.aSharp, .a, .sharp)]

        for (pitchClass, letter, accidental) in entries {
            #expect(pitchClass.letter == letter)
            #expect(pitchClass.accidental == accidental)
        }
    }

    @Test
    func b_accidentals() {
        let entries: [(PitchClass, Pitch.Letter, Pitch.Accidental)] = [(.b, .b, .natural),
                                                                       (.bDoubleFlat, .b, .doubleFlat),
                                                                       (.bDoubleSharp, .b, .doubleSharp),
                                                                       (.bFlat, .b, .flat),
                                                                       (.bSharp, .b, .sharp)]

        for (pitchClass, letter, accidental) in entries {
            #expect(pitchClass.letter == letter)
            #expect(pitchClass.accidental == accidental)
        }
    }

    @Test
    func c_accidentals() {
        let entries: [(PitchClass, Pitch.Letter, Pitch.Accidental)] = [(.c, .c, .natural),
                                                                       (.cDoubleFlat, .c, .doubleFlat),
                                                                       (.cDoubleSharp, .c, .doubleSharp),
                                                                       (.cFlat, .c, .flat),
                                                                       (.cSharp, .c, .sharp)]

        for (pitchClass, letter, accidental) in entries {
            #expect(pitchClass.letter == letter)
            #expect(pitchClass.accidental == accidental)
        }
    }

    @Test
    func d_accidentals() {
        let entries: [(PitchClass, Pitch.Letter, Pitch.Accidental)] = [(.d, .d, .natural),
                                                                       (.dDoubleFlat, .d, .doubleFlat),
                                                                       (.dDoubleSharp, .d, .doubleSharp),
                                                                       (.dFlat, .d, .flat),
                                                                       (.dSharp, .d, .sharp)]

        for (pitchClass, letter, accidental) in entries {
            #expect(pitchClass.letter == letter)
            #expect(pitchClass.accidental == accidental)
        }
    }

    @Test
    func e_accidentals() {
        let entries: [(PitchClass, Pitch.Letter, Pitch.Accidental)] = [(.e, .e, .natural),
                                                                       (.eDoubleFlat, .e, .doubleFlat),
                                                                       (.eDoubleSharp, .e, .doubleSharp),
                                                                       (.eFlat, .e, .flat),
                                                                       (.eSharp, .e, .sharp)]

        for (pitchClass, letter, accidental) in entries {
            #expect(pitchClass.letter == letter)
            #expect(pitchClass.accidental == accidental)
        }
    }

    @Test
    func f_accidentals() {
        let entries: [(PitchClass, Pitch.Letter, Pitch.Accidental)] = [(.f, .f, .natural),
                                                                       (.fDoubleFlat, .f, .doubleFlat),
                                                                       (.fDoubleSharp, .f, .doubleSharp),
                                                                       (.fFlat, .f, .flat),
                                                                       (.fSharp, .f, .sharp)]

        for (pitchClass, letter, accidental) in entries {
            #expect(pitchClass.letter == letter)
            #expect(pitchClass.accidental == accidental)
        }
    }

    @Test
    func g_accidentals() {
        let entries: [(PitchClass, Pitch.Letter, Pitch.Accidental)] = [(.g, .g, .natural),
                                                                       (.gDoubleFlat, .g, .doubleFlat),
                                                                       (.gDoubleSharp, .g, .doubleSharp),
                                                                       (.gFlat, .g, .flat),
                                                                       (.gSharp, .g, .sharp)]

        for (pitchClass, letter, accidental) in entries {
            #expect(pitchClass.letter == letter)
            #expect(pitchClass.accidental == accidental)
        }
    }
}
