// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct KeyboardMapTests {
    private static let twelveETRatios: [Ratio?] = [Ratio(cents: 0),
                                                   Ratio(cents: 100),
                                                   Ratio(cents: 200),
                                                   Ratio(cents: 300),
                                                   Ratio(cents: 400),
                                                   Ratio(cents: 500),
                                                   Ratio(cents: 600),
                                                   Ratio(cents: 700),
                                                   Ratio(cents: 800),
                                                   Ratio(cents: 900),
                                                   Ratio(cents: 1_000),
                                                   Ratio(cents: 1_100)]

    private let cRooted = KeyboardMap(referenceNote: 69,
                                      referenceFrequency: 440,
                                      middleNote: 60,
                                      equivalenceRatio: .octave,
                                      ratios: Self.twelveETRatios)

    private let standard = KeyboardMap(referenceNote: 69,
                                       referenceFrequency: 440,
                                       middleNote: 69,
                                       equivalenceRatio: .octave,
                                       ratios: Self.twelveETRatios)
}

// MARK: -

extension KeyboardMapTests {
    @Test
    func init_storesProperties() {
        let kmap = KeyboardMap(referenceNote: 69,
                               referenceFrequency: 440,
                               middleNote: 60,
                               equivalenceRatio: .octave,
                               ratios: [.unison, nil] as [Ratio?])

        #expect(kmap.middleNote == 60)
        #expect(kmap.equivalenceRatio == .octave)
        #expect(kmap.ratios.count == 2)
        #expect(kmap.ratios[0] == .unison)
        #expect(kmap.ratios[1] == nil)
        #expect(kmap.referenceFrequency == 440)
        #expect(kmap.referenceNote == 69)
    }

    @Test
    func realize_noteDistance_emptyRatios() {
        let kmap = KeyboardMap(referenceNote: 69,
                               referenceFrequency: 440,
                               middleNote: 69,
                               equivalenceRatio: .octave,
                               ratios: [])

        #expect(kmap.realize(noteDistance: 0) == nil)
    }

    @Test
    func realize_noteDistance_octave() {
        assertEqual(standard.realize(noteDistance: 12), .octave)
    }

    @Test
    func realize_noteDistance_semitone() {
        assertEqual(standard.realize(noteDistance: 1), Ratio(cents: 100))
    }

    @Test
    func realize_noteDistance_unison() {
        assertEqual(standard.realize(noteDistance: 0), .unison)
    }

    @Test
    func realize_noteDistance_unmapped() {
        let kmap = KeyboardMap(referenceNote: 69,
                               referenceFrequency: 440,
                               middleNote: 69,
                               equivalenceRatio: .octave,
                               ratios: [.unison, nil] as [Ratio?])

        #expect(kmap.realize(noteDistance: 1) == nil)
    }

    @Test
    func realize_noteDistance_wrapsAcrossPeriod() {
        assertEqual(standard.realize(noteDistance: 13), Ratio(cents: 1_300))
    }

    @Test
    func realize_noteNumber_aboveReference() {
        assertEqual(standard.realize(noteNumber: 81), 880)
    }

    @Test
    func realize_noteNumber_belowReference() {
        assertEqual(standard.realize(noteNumber: 57), 220)
    }

    @Test
    func realize_noteNumber_emptyRatios() {
        let kmap = KeyboardMap(referenceNote: 69,
                               referenceFrequency: 440,
                               middleNote: 69,
                               equivalenceRatio: .octave,
                               ratios: [])

        #expect(kmap.realize(noteNumber: 69) == nil)
    }

    @Test
    func realize_noteNumber_referenceNote() {
        assertEqual(standard.realize(noteNumber: 69), 440)
    }

    @Test
    func realize_noteNumber_unmapped() {
        let kmap = KeyboardMap(referenceNote: 69,
                               referenceFrequency: 440,
                               middleNote: 69,
                               equivalenceRatio: .octave,
                               ratios: [.unison, nil] as [Ratio?])

        #expect(kmap.realize(noteNumber: 70) == nil)
    }

    @Test
    func realize_noteNumber_unmappedReference() {
        let kmap = KeyboardMap(referenceNote: 69,
                               referenceFrequency: 440,
                               middleNote: 68,
                               equivalenceRatio: .octave,
                               ratios: [.unison, nil] as [Ratio?])

        #expect(kmap.realize(noteNumber: 68) == nil)
    }

    @Test
    func realize_noteNumber_withSeparateMiddleAndReference() {
        assertEqual(cRooted.realize(noteNumber: 57), 220)
        assertEqual(cRooted.realize(noteNumber: 69), 440)
        assertEqual(cRooted.realize(noteNumber: 81), 880)
    }

    @Test
    func unrealize_frequency_nearestNote() {
        #expect(standard.unrealize(frequency: 445) == 69)
        #expect(standard.unrealize(frequency: 460) == 70)
    }

    @Test
    func unrealize_frequency_noMappedNotes() {
        let kmap = KeyboardMap(referenceNote: 69,
                               referenceFrequency: 440,
                               middleNote: 69,
                               equivalenceRatio: .octave,
                               ratios: [nil, nil] as [Ratio?])

        #expect(kmap.unrealize(frequency: 440) == nil)
    }

    @Test
    func unrealize_frequency_referenceFrequency() {
        #expect(standard.unrealize(frequency: 220) == 57)
        #expect(standard.unrealize(frequency: 440) == 69)
        #expect(standard.unrealize(frequency: 880) == 81)
    }

    @Test
    func unrealize_ratio_nearestDistance() {
        #expect(standard.unrealize(ratio: Ratio(cents: 40)) == 0)
        #expect(standard.unrealize(ratio: Ratio(cents: 70)) == 1)
    }

    @Test
    func unrealize_ratio_noMappedDistances() {
        let kmap = KeyboardMap(referenceNote: 69,
                               referenceFrequency: 440,
                               middleNote: 69,
                               equivalenceRatio: .octave,
                               ratios: [nil, nil] as [Ratio?])

        #expect(kmap.unrealize(ratio: .unison) == nil)
    }

    @Test
    func unrealize_ratio_unison() {
        #expect(standard.unrealize(ratio: .unison) == 0)
        #expect(standard.unrealize(ratio: .octave) == 12)
    }
}
