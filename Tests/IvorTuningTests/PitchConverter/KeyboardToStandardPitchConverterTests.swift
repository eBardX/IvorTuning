// © 2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiTools

struct KeyboardToStandardPitchConverterTests {
    private let converter = KeyboardToStandardPitchConverter()

    // E major: E4 F♯4 G♯4 A4 B4 C♯5 D♯5 E5
    private let eMajor: [NoteNumber] = [64, 66, 68, 69, 71, 73, 75, 76]
}

// MARK: -

extension KeyboardToStandardPitchConverterTests {
    @Test
    func convert_default_sequenceUsesContext() {
        let result = converter.convert(eMajor)

        #expect(result.count == eMajor.count)
        #expect(result[6] == "D#5")
        #expect(converter.convert(75) == "Eb5")    // the same key on its own
    }

    @Test
    func convert_default_singleNoteGetsDefaultSpelling() {
        #expect(converter.convert(60) == "C4")
        #expect(converter.convert(63) == "Eb4")
        #expect(converter.convert(70) == "Bb4")
    }

    @Test
    func convert_layoutSpelling_agreesWithAbsoluteToStandard() throws {
        // A split-key keyboard, with B♯ just below the next C.
        let layout = try KeyboardLayout(pitchClasses: [.c,
                                                       .cSharp,
                                                       .d,
                                                       .dSharp,
                                                       .eFlat,
                                                       .e,
                                                       .f,
                                                       .fSharp,
                                                       .g,
                                                       .gSharp,
                                                       .aFlat,
                                                       .a,
                                                       .bFlat,
                                                       .b,
                                                       .bSharp])
        let toStandard = try KeyboardToStandardPitchConverter(keyboardLayout: layout,
                                                              tuningSystem: EqualTemperament.edo31)
        let toFrequency = try KeyboardToAbsolutePitchConverter(keyboardLayout: layout,
                                                               tuningSystem: EqualTemperament.edo31)
        let absoluteToStandard = try AbsoluteToStandardPitchConverter(keyboardLayout: layout,
                                                                      tuningSystem: EqualTemperament.edo31)

        for note in UInt(36)...96 {
            let noteNumber = try #require(NoteNumber(uintValue: note))
            let frequency = try #require(toFrequency.convert(noteNumber))

            #expect(toStandard.convert(noteNumber) == absoluteToStandard.convert(frequency), "key \(note)")
        }
    }

    @Test
    func convert_layoutSpelling_anchorNeedNotBeC() throws {
        let layout = try KeyboardLayout(pitchClasses: [.a,
                                                       .bFlat,
                                                       .b,
                                                       .c,
                                                       .cSharp,
                                                       .d,
                                                       .eFlat,
                                                       .e,
                                                       .f,
                                                       .fSharp,
                                                       .g,
                                                       .gSharp],
                                        anchorNote: 57,
                                        anchorOctave: 3)
        let fixed = try KeyboardToStandardPitchConverter(keyboardLayout: layout,
                                                         tuningSystem: EqualTemperament.edo19)

        #expect(fixed.convert(57) == "A3")
        #expect(fixed.convert(60) == "C4")
        #expect(fixed.convert(69) == "A4")
    }

    @Test
    func convert_layoutSpelling_anySize() throws {
        let nineteen = try KeyboardLayout(pitchClasses: [.c,
                                                         .cSharp,
                                                         .dFlat,
                                                         .d,
                                                         .dSharp,
                                                         .eFlat,
                                                         .e,
                                                         .eSharp,
                                                         .f,
                                                         .fSharp,
                                                         .gFlat,
                                                         .g,
                                                         .gSharp,
                                                         .aFlat,
                                                         .a,
                                                         .aSharp,
                                                         .bFlat,
                                                         .b,
                                                         .bSharp])
        let fixed = try KeyboardToStandardPitchConverter(keyboardLayout: nineteen,
                                                         tuningSystem: EqualTemperament.edo19)

        #expect(fixed.convert(60) == "C4")
        #expect(fixed.convert(62) == "Db4")
        #expect(fixed.convert(78) == "B#4")
        #expect(fixed.convert(79) == "C5")
    }

    @Test
    func convert_layoutSpelling_finalCFlatTakesNextOctave() throws {
        let layout = try KeyboardLayout(pitchClasses: [.c, .d, .e, .f, .g, .a, .b, .cFlat])
        let fixed = try KeyboardToStandardPitchConverter(keyboardLayout: layout,
                                                         tuningSystem: EqualTemperament.edo19)

        #expect(fixed.convert(67) == "Cb5")
        #expect(fixed.convert(68) == "C5")
        #expect(fixed.convert(59) == "Cb4")
    }

    @Test
    func convert_layoutSpelling_isFixed() throws {
        let fixed = try KeyboardToStandardPitchConverter(keyboardLayout: .piano,
                                                         tuningSystem: EqualTemperament.edo12)

        #expect(fixed.convert(63) == "Eb4")
        #expect(fixed.convert(eMajor)[6] == "Eb5")
        #expect(fixed.convert(0) == "C-1")
        #expect(fixed.convert(127) == "G9")
    }

    @Test
    func convert_layoutSpelling_octaveDependsOnTuning() throws {
        // B♯ sounds below C in meantone, but above it in Pythagorean, so a B♯ just above C4 is
        // B♯3 in Pythagorean, while in meantone it is B♯4, just below C5.
        let layout = try KeyboardLayout(pitchClasses: [.c, .bSharp])
        let meantone = try KeyboardToStandardPitchConverter(keyboardLayout: layout,
                                                            tuningSystem: LinearTemperament.quarterCommaMeantone)
        let pythagorean = try KeyboardToStandardPitchConverter(keyboardLayout: layout,
                                                               tuningSystem: LinearTemperament.pythagorean)

        #expect(meantone.convert(61) == "B#4")
        #expect(pythagorean.convert(61) == "B#3")
    }

    @Test
    func convert_layoutSpelling_outOfOctaveRangeIsNil() throws {
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
                                                       .b],
                                        anchorNote: 0,
                                        anchorOctave: 9)
        let fixed = try KeyboardToStandardPitchConverter(keyboardLayout: layout,
                                                         tuningSystem: EqualTemperament.edo19)

        #expect(fixed.convert(0) == "C9")
        #expect(fixed.convert(11) == "B9")
        #expect(fixed.convert(12) == nil)
    }

    @Test
    func convert_speller_winsOverLayoutSpelling() throws {
        let spelled = try KeyboardToStandardPitchConverter(keyboardLayout: .piano,
                                                           pitchSpeller: MeredithPitchSpeller())

        #expect(spelled.convert(eMajor)[6] == "D#5")
    }

    @Test
    func convert_withLayoutAndSpeller_unmappedKeyIsNil() throws {
        let layout = try KeyboardLayout(pitchClasses: [.c, nil, .d, nil, .e, .f, nil, .g, nil, .a, nil, .b])
        let spelled = try KeyboardToStandardPitchConverter(keyboardLayout: layout,
                                                           pitchSpeller: MeredithPitchSpeller())

        #expect(spelled.convert([60, 61, 62]) == ["C4", nil, "D4"])
    }

    @Test
    func equality() throws {
        #expect(converter == KeyboardToStandardPitchConverter(pitchSpeller: MeredithPitchSpeller()))
        #expect(try converter == KeyboardToStandardPitchConverter(keyboardLayout: .piano,
                                                                  pitchSpeller: MeredithPitchSpeller()))
        #expect(converter != KeyboardToStandardPitchConverter(pitchSpeller: MeredithPitchSpeller(contextBefore: 5)))
    }

    @Test
    func init_layoutSpeller_invalidLayoutForTuning_throws() throws {
        // C, D, C♯ pushes C♯ into the next octave, past the anchor.
        let misordered = try KeyboardLayout(pitchClasses: [.c, .d, .cSharp])

        #expect(throws: TuningError.invalidKeyboardLayout(.slotOutsidePeriod(index: 2))) {
            try KeyboardToStandardPitchConverter(keyboardLayout: misordered,
                                                 tuningSystem: EqualTemperament.edo12)
        }
    }

    @Test
    func init_layoutSpeller_nonPitchClassLayout_throwsPitchClassLayoutRequired() {
        #expect(throws: TuningError.invalidKeyboardLayout(.pitchClassLayoutRequired)) {
            try KeyboardToStandardPitchConverter(keyboardLayout: .bohlenPierce,
                                                 tuningSystem: EqualTemperament.bohlenPierce)
        }
    }

    @Test
    func init_layoutSpeller_unsupportedTuning_throws() {
        #expect(throws: TuningError.unsupportedStandardConversion) {
            try KeyboardToStandardPitchConverter(keyboardLayout: .piano,
                                                 tuningSystem: EqualTemperament.bohlenPierce)
        }
    }

    @Test
    func init_speller_wrongShape_throwsNotTwelveKeysPerOctave() throws {
        let frequencies = try KeyboardLayout(frequencies: [Frequency?](repeating: 440, count: 128))
        let tritave = try KeyboardLayout(ratios: Fixtures.twelveETRatios,
                                         equivalenceRatio: .tritave,
                                         referenceFrequency: 440)

        for layout in [KeyboardLayout.bohlenPierce, frequencies, tritave] {
            #expect(throws: TuningError.invalidKeyboardLayout(.notTwelveKeysPerOctave)) {
                try KeyboardToStandardPitchConverter(keyboardLayout: layout,
                                                     pitchSpeller: MeredithPitchSpeller())
            }
        }
    }
}
