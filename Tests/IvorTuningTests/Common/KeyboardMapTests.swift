// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning
import Testing
import XestiNumbers
import XestiTools

struct KeyboardMapTests {
    private let cRooted = KeyboardMap(referenceNote: 69,
                                      referenceFrequency: 440,
                                      middleNote: 60,
                                      equivalenceRatio: .octave,
                                      ratios: Fixtures.twelveETRatios)

    private let standard = KeyboardMap(referenceNote: 69,
                                       referenceFrequency: 440,
                                       middleNote: 69,
                                       equivalenceRatio: .octave,
                                       ratios: Fixtures.twelveETRatios)
}

// MARK: -

extension KeyboardMapTests {
    @Test(arguments: [(KeyboardMap.a415, PitchStandard.a415),
                      (.a432, .a432),
                      (.a435, .a435),
                      (.a440, .a440),
                      (.c256, .c256)])
    func twelveTone_matchesPitchStandard(kmap: KeyboardMap,
                                         standard: PitchStandard) {
        let referenceNote: NoteNumber = standard.pitch == .a4 ? 69 : 60

        #expect(kmap.middleNote == 60)
        #expect(kmap.equivalenceRatio == .octave)
        #expect(kmap.ratios == Fixtures.twelveETRatios)
        #expect(kmap.referenceNote == referenceNote)
        #expect(kmap.referenceFrequency == standard.frequency)
        assertEqual(kmap.realize(noteNumber: referenceNote), standard.frequency)
        #expect(kmap.unrealize(frequency: standard.frequency) == referenceNote)
    }

    @Test
    func bohlenPierce_tritaveLayout() throws {
        let kmap = KeyboardMap.bohlenPierce
        let middleC = try #require(KeyboardMap.a440.realize(noteNumber: 60))
        let tritaveUp = try #require(middleC.transposed(by: DirectedInterval(interval: .tritave,
                                                                             direction: .ascending)))
        let step = Ratio(cents: Number(1_200) * log(Number(3)) / log(Number(2)) / Number(13))
        let oneStepUp = try #require(middleC.transposed(by: DirectedInterval(interval: step,
                                                                             direction: .ascending)))

        #expect(kmap.middleNote == 60)
        #expect(kmap.equivalenceRatio == .tritave)
        #expect(kmap.ratios.count == 13)
        #expect(kmap.referenceNote == 60)
        assertEqual(kmap.realize(noteNumber: 60), middleC)
        assertEqual(kmap.realize(noteNumber: 61), oneStepUp)
        assertEqual(kmap.realize(noteNumber: 73), tritaveUp)
        #expect(kmap.unrealize(frequency: tritaveUp) == 73)
    }

    @Test
    func a440_pianoLayout() {
        let kmap = KeyboardMap.a440

        #expect(kmap.middleNote == 60)
        #expect(kmap.equivalenceRatio == .octave)
        #expect(kmap.ratios.count == 12)
        #expect(kmap.referenceFrequency == 440)
        #expect(kmap.referenceNote == 69)
        assertEqual(kmap.realize(noteNumber: 60), Frequency(Number(261.625565)))
        assertEqual(kmap.realize(noteNumber: 69), 440)
        #expect(kmap.unrealize(frequency: 440) == 69)
    }

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
    func unrealize_frequency_outOfRange() throws {
        let justBelowLowest = try #require(Frequency(uintValue: 7_900_000))   // ≈ 59 ¢ below MIDI 0

        #expect(cRooted.unrealize(frequency: 8) == 0)                        // ≈ 38 ¢ below MIDI 0
        #expect(cRooted.unrealize(frequency: justBelowLowest) == nil)
        #expect(cRooted.unrealize(frequency: 12_900) == 127)                 // ≈ 49 ¢ above MIDI 127
        #expect(cRooted.unrealize(frequency: 13_000) == nil)                 // ≈ 62 ¢ above MIDI 127
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
    func unrealize_ratio_outOfRange() {
        #expect(standard.unrealize(ratio: Ratio(cents: 12_740)) == 127)
        #expect(standard.unrealize(ratio: Ratio(cents: 12_760)) == nil)
    }

    @Test
    func unrealize_ratio_unison() {
        #expect(standard.unrealize(ratio: .unison) == 0)
        #expect(standard.unrealize(ratio: .octave) == 12)
    }
}
