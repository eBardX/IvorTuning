// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct KeyboardLayoutTests {
    private let cMajor: [PitchClass?] = [.c, nil, .d, nil, .e, .f, nil, .g, nil, .a, nil, .b]
    private let twelveTone: [Ratio?] = (0..<12).map { Ratio(cents: Number(100 * $0)) }
}

// MARK: -

extension KeyboardLayoutTests {
    @Test
    func codable_encodesDefinition() throws {
        let encoder = JSONEncoder()

        encoder.outputFormatting = .sortedKeys

        let layout = try KeyboardLayout(degrees: [0, 1])

        #expect(try encoder.encode(layout) == encoder.encode(layout.definition))
    }

    @Test
    func codable_invalidDefinition_throwsDataCorrupted() throws {
        let invalid = KeyboardLayout.Definition.degrees([0, 0],
                                                        anchorNote: 60,
                                                        referenceNote: 60)
        let data = try JSONEncoder().encode(invalid)

        #expect {
            try JSONDecoder().decode(KeyboardLayout.self, from: data)
        } throws: { error in
            guard case let DecodingError.dataCorrupted(context) = error
            else { return false }

            return context.debugDescription.contains("Keyboard layout is invalid")
        }
    }

    @Test
    func codable_roundTrips() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let layouts = try [KeyboardLayout.piano,
                           .bohlenPierce,
                           KeyboardLayout(pitchClasses: cMajor,
                                          anchorNote: 48,
                                          anchorOctave: 3),
                           KeyboardLayout(ratios: twelveTone,
                                          equivalenceRatio: .octave,
                                          anchorNote: 57,
                                          referenceNote: 57,
                                          referenceFrequency: 415),
                           KeyboardLayout(frequencies: (0..<128).map { $0.isMultiple(of: 2) ? Frequency(Number(100 + $0)) : nil })]

        for layout in layouts {
            let data = try encoder.encode(layout)
            let decoded = try decoder.decode(KeyboardLayout.self, from: data)

            #expect(decoded == layout)
        }
    }

    @Test
    func degrees_defaults() throws {
        let layout = try KeyboardLayout(degrees: [0, 1, 2])

        #expect(layout.definition == .degrees([0, 1, 2],
                                              anchorNote: 60,
                                              referenceNote: 69))
        #expect(layout.keysPerPeriod == 3)
    }

    @Test
    func degrees_descendAfterAscent_throwsSlotOutOfOrder() {
        #expect(throws: TuningError.invalidKeyboardLayout(.slotOutOfOrder(index: 2))) {
            try KeyboardLayout(degrees: [0, 5, 2])
        }
    }

    @Test
    func degrees_duplicate_throwsDuplicateSlot() {
        #expect(throws: TuningError.invalidKeyboardLayout(.duplicateSlot(index: 2))) {
            try KeyboardLayout(degrees: [0, 3, 3])
        }
    }

    @Test
    func degrees_empty_throwsUnmappedAnchor() {
        #expect(throws: TuningError.invalidKeyboardLayout(.unmappedAnchor)) {
            try KeyboardLayout(degrees: [])
        }
    }

    @Test
    func degrees_lambda_passes() throws {
        let layout = try KeyboardLayout(degrees: [0, nil, 2, 3, 4, 6, nil, 7, 9, 10, nil, 12])

        #expect(layout.keysPerPeriod == 12)
    }

    @Test
    func degrees_negative_throwsUnsupportedDegree() {
        #expect(throws: TuningError.invalidKeyboardLayout(.unsupportedDegree(index: 2))) {
            try KeyboardLayout(degrees: [0, 1, -1])
        }
    }

    @Test
    func degrees_nilAnchor_throwsUnmappedAnchor() {
        #expect(throws: TuningError.invalidKeyboardLayout(.unmappedAnchor)) {
            try KeyboardLayout(degrees: [nil, 1, 2])
        }
    }

    @Test
    func degrees_referenceBelowAnchor_wrapsToSlot() throws {
        // Slot (57 − 60) mod 4 = 1.
        _ = try KeyboardLayout(degrees: [0, 1, nil, nil],
                               anchorNote: 60,
                               referenceNote: 57)

        #expect(throws: TuningError.invalidKeyboardLayout(.unmappedReference)) {
            try KeyboardLayout(degrees: [0, nil, 2, 3],
                               anchorNote: 60,
                               referenceNote: 57)
        }
    }

    @Test
    func degrees_unmappedReference_throws() {
        // Slot (69 − 60) mod 12 = 9 is nil.
        #expect(throws: TuningError.invalidKeyboardLayout(.unmappedReference)) {
            try KeyboardLayout(degrees: [0, 1, 2, 3, 4, 5, 6, 7, 8, nil, 10, 11])
        }
    }

    @Test
    func degrees_wrapOnce_passes() throws {
        _ = try KeyboardLayout(degrees: [5, 7, 9, 0, 2])
    }

    @Test
    func degrees_wrapPastAnchor_throwsSlotOutOfOrder() {
        #expect(throws: TuningError.invalidKeyboardLayout(.slotOutOfOrder(index: 3))) {
            try KeyboardLayout(degrees: [5, 7, 0, 6])
        }
    }

    @Test
    func degrees_wrapTwice_throwsSlotOutOfOrder() {
        #expect(throws: TuningError.invalidKeyboardLayout(.slotOutOfOrder(index: 4))) {
            try KeyboardLayout(degrees: [5, 7, 1, 3, 2])
        }
    }

    @Test
    func equality_isStructural() throws {
        // A frequency layout and a raw-ratio layout can sound identical yet are unequal.
        let tenCents = Ratio(cents: 10)
        let ratios = try KeyboardLayout(ratios: [.unison],
                                        equivalenceRatio: tenCents,
                                        referenceFrequency: 440)
        let frequencies = try KeyboardLayout(frequencies: (0..<128).map {
            Frequency(Number(440) * exp(log(Number(2)) * Number($0 - 69) / Number(120)))
        })

        #expect(ratios != frequencies)
        #expect(try ratios == KeyboardLayout(ratios: [.unison],
                                             equivalenceRatio: tenCents,
                                             referenceFrequency: 440))
        #expect(Set([ratios, ratios, frequencies]).count == 2)
    }

    @Test
    func frequencies_allNil_throwsNoMappedKeys() {
        #expect(throws: TuningError.invalidKeyboardLayout(.noMappedKeys)) {
            try KeyboardLayout(frequencies: [Frequency?](repeating: nil, count: 128))
        }
    }

    @Test
    func frequencies_valid() throws {
        var frequencies = [Frequency?](repeating: nil, count: 128)

        frequencies[69] = 440
        frequencies[70] = 440

        let layout = try KeyboardLayout(frequencies: frequencies)

        #expect(layout.definition == .frequencies(frequencies))
        #expect(layout.keysPerPeriod == 128)
    }

    @Test(arguments: [0, 127, 129])
    func frequencies_wrongCount_throwsInvalidFrequencyCount(count: Int) {
        let frequencies = [Frequency?](repeating: 440, count: count)

        #expect(throws: TuningError.invalidKeyboardLayout(.invalidFrequencyCount)) {
            try KeyboardLayout(frequencies: frequencies)
        }
    }

    @Test
    func initDefinition_roundTrips() throws {
        let layouts = try [KeyboardLayout.piano,
                           .bohlenPierce,
                           KeyboardLayout(ratios: twelveTone,
                                          equivalenceRatio: .octave,
                                          referenceFrequency: 440),
                           KeyboardLayout(frequencies: [Frequency?](repeating: 440, count: 128))]

        for layout in layouts {
            #expect(try KeyboardLayout(layout.definition) == layout)
        }
    }

    @Test
    func initDefinition_validates() {
        #expect(throws: TuningError.invalidKeyboardLayout(.slotOutOfOrder(index: 2))) {
            try KeyboardLayout(.degrees([0, 5, 2],
                                        anchorNote: 60,
                                        referenceNote: 60))
        }
    }

    @Test
    func pitchClasses_anchorNeedNotBeC() throws {
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

        #expect(layout.definition == .pitchClasses([.a,
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
                                                   anchorOctave: 3))
    }

    @Test
    func pitchClasses_defaults() throws {
        let layout = try KeyboardLayout(pitchClasses: cMajor)

        #expect(layout.definition == .pitchClasses(cMajor,
                                                   anchorNote: 60,
                                                   anchorOctave: 4))
        #expect(layout.keysPerPeriod == 12)
    }

    @Test
    func pitchClasses_duplicate_throwsDuplicateSlot() {
        #expect(throws: TuningError.invalidKeyboardLayout(.duplicateSlot(index: 3))) {
            try KeyboardLayout(pitchClasses: [.c, .d, nil, .c])
        }
    }

    @Test
    func pitchClasses_empty_throwsUnmappedAnchor() {
        #expect(throws: TuningError.invalidKeyboardLayout(.unmappedAnchor)) {
            try KeyboardLayout(pitchClasses: [])
        }
    }

    @Test
    func pitchClasses_enharmonicsAllowed() throws {
        // Order can't be checked without a tuning system, and G♯/A♭ are distinct spellings.
        let layout = try KeyboardLayout(pitchClasses: [.c, .gSharp, .aFlat])

        #expect(layout.keysPerPeriod == 3)
    }

    @Test
    func pitchClasses_misorderedLettersAllowed() throws {
        // E♯ lies above F♭ in some tunings, so a valid layout can step backwards in letter name.
        _ = try KeyboardLayout(pitchClasses: [.c, .d, .eSharp, .fFlat])
    }

    @Test
    func pitchClasses_nilAnchor_throwsUnmappedAnchor() {
        #expect(throws: TuningError.invalidKeyboardLayout(.unmappedAnchor)) {
            try KeyboardLayout(pitchClasses: [nil, .c, .d])
        }
    }

    @Test
    func ratios_anchorNeedNotBeUnison() throws {
        _ = try KeyboardLayout(ratios: [Ratio(cents: 700), .unison],
                               equivalenceRatio: .octave,
                               referenceNote: 61,
                               referenceFrequency: 440)
    }

    @Test
    func ratios_defaults() throws {
        let layout = try KeyboardLayout(ratios: twelveTone,
                                        equivalenceRatio: .octave,
                                        referenceFrequency: 440)

        #expect(layout.definition == .ratios(twelveTone,
                                             equivalenceRatio: .octave,
                                             anchorNote: 60,
                                             referenceNote: 69,
                                             referenceFrequency: 440))
        #expect(layout.keysPerPeriod == 12)
    }

    @Test
    func ratios_nilAnchor_throwsUnmappedAnchor() {
        #expect(throws: TuningError.invalidKeyboardLayout(.unmappedAnchor)) {
            try KeyboardLayout(ratios: [nil, .unison],
                               equivalenceRatio: .octave,
                               referenceFrequency: 440)
        }
    }

    @Test
    func ratios_nonMonotonicAndDuplicates_allowed() throws {
        let white = (0..<7).map { Ratio(cents: Number($0) * 1_200 / 7) }
        let black = (0..<5).map { Ratio(cents: Number($0) * 1_200 / 5) }
        let layout = try KeyboardLayout(ratios: [white[0],
                                                 black[0],
                                                 white[1],
                                                 black[1],
                                                 white[2],
                                                 white[3],
                                                 black[2],
                                                 white[4],
                                                 black[3],
                                                 white[5],
                                                 black[4],
                                                 white[6]],
                                        equivalenceRatio: .octave,
                                        referenceFrequency: 440)

        #expect(layout.keysPerPeriod == 12)
    }

    @Test
    func ratios_ratioAbovePeriod_throwsInvalidRatio() {
        #expect(throws: TuningError.invalidKeyboardLayout(.invalidRatio(index: 1))) {
            try KeyboardLayout(ratios: [.unison, .tritave],
                               equivalenceRatio: .octave,
                               referenceFrequency: 440)
        }
    }

    @Test
    func ratios_ratioAtPeriod_throwsInvalidRatio() {
        #expect(throws: TuningError.invalidKeyboardLayout(.invalidRatio(index: 2))) {
            try KeyboardLayout(ratios: [.unison, Ratio(cents: 600), .octave],
                               equivalenceRatio: .octave,
                               referenceFrequency: 440)
        }
    }

    @Test
    func ratios_unisonEquivalence_throwsInvalidEquivalenceRatio() {
        #expect(throws: TuningError.invalidKeyboardLayout(.invalidEquivalenceRatio)) {
            try KeyboardLayout(ratios: [.unison],
                               equivalenceRatio: .unison,
                               referenceFrequency: 440)
        }
    }

    @Test
    func ratios_unmappedReference_throws() {
        var ratios = twelveTone

        ratios[9] = nil

        #expect(throws: TuningError.invalidKeyboardLayout(.unmappedReference)) {
            try KeyboardLayout(ratios: ratios,
                               equivalenceRatio: .octave,
                               referenceFrequency: 440)
        }
    }
}
