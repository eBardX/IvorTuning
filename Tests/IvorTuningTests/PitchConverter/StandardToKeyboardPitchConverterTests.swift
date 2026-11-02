// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct StandardToKeyboardPitchConverterTests {
    private let converter = StandardToKeyboardPitchConverter()
}

// MARK: -

extension StandardToKeyboardPitchConverterTests {
    @Test
    func convert_default_matchesNotationalFormulaForEveryPitch() throws {
        let letters: [(String, Int)] = [("C", 0), ("D", 2), ("E", 4), ("F", 5), ("G", 7), ("A", 9), ("B", 11)]
        let accidentals: [(String, Int)] = [("bb", -2), ("b", -1), ("", 0), ("#", 1), ("x", 2)]

        for octave in -1...9 {
            for (letter, letterOffset) in letters {
                for (accidental, accidentalOffset) in accidentals {
                    let pitch = try #require(Pitch(plain: "\(letter)\(accidental)\(octave)"))
                    let key = 12 * (octave + 1) + letterOffset + accidentalOffset
                    let expected = (0...127) ~= key ? NoteNumber(uintValue: UInt(key)) : nil

                    #expect(converter.convert(pitch) == expected, "\(pitch.plain)")
                }
            }
        }
    }

    @Test(arguments: [("C4", 60),
                      ("B#3", 60),
                      ("Dbb4", 60),
                      ("C#4", 61),
                      ("Db4", 61),
                      ("Bx3", 61),
                      ("D4", 62),
                      ("Cx4", 62),
                      ("Ebb4", 62),
                      ("D#4", 63),
                      ("Eb4", 63),
                      ("Fbb4", 63),
                      ("E4", 64),
                      ("Dx4", 64),
                      ("Fb4", 64),
                      ("F4", 65),
                      ("E#4", 65),
                      ("Gbb4", 65),
                      ("F#4", 66),
                      ("Gb4", 66),
                      ("Ex4", 66),
                      ("G4", 67),
                      ("Fx4", 67),
                      ("Abb4", 67),
                      ("G#4", 68),
                      ("Ab4", 68),
                      ("A4", 69),
                      ("Gx4", 69),
                      ("Bbb4", 69),
                      ("A#4", 70),
                      ("Bb4", 70),
                      ("Cbb5", 70),
                      ("B4", 71),
                      ("Ax4", 71),
                      ("Cb5", 71),
                      ("Cb4", 59)])
    func convert_default_pianoKeys(pitch: String,
                                   expected: UInt) throws {
        let pitch = try #require(Pitch(plain: pitch))

        #expect(converter.convert(pitch) == NoteNumber(uintValue: expected))
    }

    @Test
    func convert_default_rangeEdges() {
        #expect(converter.convert("C-1") == 0)
        #expect(converter.convert("G9") == 127)
        #expect(converter.convert("Cb-1") == nil)
        #expect(converter.convert("G#9") == nil)
    }

    @Test
    func convert_keyMatchingWithin() throws {
        let layout = try KeyboardLayout(pitchClasses: [.c,
                                                       .cSharp,
                                                       .d,
                                                       .eFlat,
                                                       .e,
                                                       .f,
                                                       .fSharp,
                                                       .g,
                                                       .gSharp,
                                                       .a,
                                                       .bFlat,
                                                       .b])
        let strict19 = try StandardToKeyboardPitchConverter(keyboardLayout: layout,
                                                            tuningSystem: EqualTemperament.edo19,
                                                            keyMatching: .within(Ratio(cents: 5)))
        let strictPiano = try StandardToKeyboardPitchConverter(keyboardLayout: .piano,
                                                               tuningSystem: EqualTemperament.edo12,
                                                               keyMatching: .within(Ratio(cents: 5)))

        #expect(strict19.convert("Ab4") == nil)
        #expect(strict19.convert("A4") == 69)
        #expect(strictPiano.convert("B#3") == 60)
    }

    @Test
    func convert_meantone_foldsOntoHistoricalKeyboard() throws {
        // The piano layout in meantone is the E♭–G♯ keyboard: a written D♯ lands on the E♭ key.
        let meantone = try StandardToKeyboardPitchConverter(keyboardLayout: .piano,
                                                            tuningSystem: LinearTemperament.quarterCommaMeantone)

        #expect(meantone.convert("D#4") == 63)
        #expect(meantone.convert("Eb4") == 63)
        #expect(meantone.convert("Ab4") == 68)
    }

    @Test
    func convert_meantone_followsSoundNotSpelling() throws {
        let meantone = try StandardToKeyboardPitchConverter(keyboardLayout: .piano,
                                                            tuningSystem: LinearTemperament.quarterCommaMeantone)

        #expect(meantone.convert("Bx3") == 60)
        #expect(meantone.convert("C#4") == 61)
    }

    @Test(arguments: [("Ab4", 69),
                      ("G#4", 68),
                      ("A4", 69),
                      ("Bb4", 70),
                      ("Db4", 62),
                      ("D#4", 62),
                      ("E#4", 64),
                      ("Fb4", 65),
                      ("Gb4", 67),
                      ("A#4", 69),
                      ("B#4", 71),
                      ("Cb5", 72)])
    func convert_nineteenEDOSubset_tiesGoToSameLetter(pitch: String,
                                                      expected: UInt) throws {
        let layout = try KeyboardLayout(pitchClasses: [.c,
                                                       .cSharp,
                                                       .d,
                                                       .eFlat,
                                                       .e,
                                                       .f,
                                                       .fSharp,
                                                       .g,
                                                       .gSharp,
                                                       .a,
                                                       .bFlat,
                                                       .b])
        let converter = try StandardToKeyboardPitchConverter(keyboardLayout: layout,
                                                             tuningSystem: EqualTemperament.edo19)
        let pitch = try #require(Pitch(plain: pitch))

        #expect(converter.convert(pitch) == NoteNumber(uintValue: expected))
    }

    @Test
    func convert_pitchStandard_tunesKeyboard() throws {
        let baroque = try StandardToKeyboardPitchConverter(keyboardLayout: .piano,
                                                           tuningSystem: EqualTemperament.edo12,
                                                           pitchStandard: .a415)

        #expect(baroque.convert("A4") == 69)
        #expect(baroque.convert("C4") == 60)
    }

    @Test
    func convert_rawLayout_mismatchedTuning_transposes() throws {
        let raw415 = try KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                        equivalenceRatio: .octave,
                                        referenceFrequency: 415)
        let converter = try StandardToKeyboardPitchConverter(keyboardLayout: raw415,
                                                             tuningSystem: EqualTemperament.edo12,
                                                             pitchStandard: .a440)

        #expect(converter.convert("A4") == 70)
    }

    @Test
    func equality() throws {
        let explicit = try StandardToKeyboardPitchConverter(keyboardLayout: .piano,
                                                            tuningSystem: EqualTemperament.edo12,
                                                            pitchStandard: .a440)

        #expect(converter == explicit)
    }

    @Test
    func inequality() throws {
        let other = try StandardToKeyboardPitchConverter(keyboardLayout: .piano,
                                                         tuningSystem: EqualTemperament.edo12,
                                                         pitchStandard: .a432)
        let strict = try StandardToKeyboardPitchConverter(keyboardLayout: .piano,
                                                          tuningSystem: EqualTemperament.edo12,
                                                          keyMatching: .within(Ratio(cents: 5)))

        #expect(converter != other)
        #expect(converter != strict)
    }

    @Test
    func init_invalidLayoutForTuning_throws() throws {
        let layout = try KeyboardLayout(pitchClasses: [.c, .gSharp, .aFlat])

        #expect(throws: TuningError.invalidKeyboardLayout(.coincidentSlots(index: 2))) {
            try StandardToKeyboardPitchConverter(keyboardLayout: layout,
                                                 tuningSystem: EqualTemperament.edo12)
        }
    }

    @Test
    func init_unsupportedTuning_throws() {
        #expect(throws: TuningError.unsupportedStandardConversion) {
            try StandardToKeyboardPitchConverter(keyboardLayout: .piano,
                                                 tuningSystem: EqualTemperament.bohlenPierce)
        }
    }
}
