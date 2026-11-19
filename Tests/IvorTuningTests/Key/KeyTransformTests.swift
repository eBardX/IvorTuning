// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiNumbers

struct KeyTransformTests {
}

// MARK: -

extension KeyTransformTests {

    // MARK: Atonal

    @Test
    func atonal_unchanged() {
        #expect(Key.atonal.inverted(around: Pitch.c4...Pitch.g4) == .atonal)
        #expect(Key.atonal.inverted(around: note(60)...note(67)) == .atonal)
        #expect(Key.atonal.transposed(by: up(.major2)) == .atonal)
        #expect(Key.atonal.transposed(by: steps(5)) == .atonal)
        #expect(Key.atonal.transposed(by: ratio(Ratio(3, 2), .ascending)) == .atonal)
    }

    @Test
    func atonal_unchangedEvenWhenOthersFail() {
        #expect(Key.atonal.transposed(by: ratio(Ratio(7, 4), .ascending)) == .atonal)
    }

    // MARK: Invariants

    @Test
    func invariant_customStaysCustom() throws {
        let customs = try [[PitchClass.fSharp, .gSharp],
                           [.bFlat, .fSharp],
                           [.bFlat, .aFlat],
                           [.eFlat],
                           [.cSharp],
                           [.aSharp, .bFlat],
                           [.fFlat, .bSharp]].map { try #require(Key(accidentals: $0)) }

        for custom in customs {
            var results = intervals.map { custom.transposed(by: up($0)) }

            results += intervals.map { custom.transposed(by: down($0)) }
            results += (-11...11).map { custom.transposed(by: steps($0)) }
            results += pitchRanges.map { custom.inverted(around: $0) }
            results += noteRanges.map { custom.inverted(around: $0) }

            for result in results {
                if let result, case .custom = result {
                    continue
                }

                #expect(result == nil, "\(custom) gave \(String(describing: result))")
            }
        }
    }

    @Test
    func invariant_diatonicStaysDiatonic() throws {
        for fifths in -7...7 {
            let diatonic = try #require(dia(fifths, .major))
            var results = intervals.map { diatonic.transposed(by: up($0)) }

            results += (-11...11).map { diatonic.transposed(by: steps($0)) }
            results += pitchRanges.map { diatonic.inverted(around: $0) }
            results += noteRanges.map { diatonic.inverted(around: $0) }

            for result in results {
                guard case let .diatonic(payload)? = result
                else { Issue.record("\(diatonic) gave \(String(describing: result))"); continue }

                #expect(payload.mode != nil)
            }
        }
    }

    // MARK: Inversion, keyboard

    @Test
    func invertedAroundNoteRange_diatonic() {
        #expect(key(1)?.inverted(around: note(60)...note(67)) == key(-4))
        #expect(key(0)?.inverted(around: note(60)...note(72)) == key(-4))
        #expect(key(0)?.inverted(around: note(60)...note(61)) == key(3))
    }

    @Test
    func invertedAroundNoteRange_mapsMode() {
        #expect(dia(0, .major)?.inverted(around: note(60)...note(60)) == Key.diatonic(tonic: .c, mode: .phrygian))
        #expect(dia(0, .minor)?.inverted(around: note(60)...note(60)) == Key.diatonic(tonic: .eFlat, mode: .mixolydian))
    }

    @Test
    func invertedAroundNoteRange_matchesStandard() {
        let standard = key(2)?.inverted(around: Pitch.c4...Pitch.g4)
        let keyboard = key(2)?.inverted(around: note(60)...note(67))

        #expect(standard == keyboard)
    }

    @Test
    func invertedAroundNoteRange_prefersFewerAccidentals() {
        // C major inverted around C4…B♭4 is G♭ major (n ↦ 130 − n), kept over the tied F♯ major.
        #expect(key(0)?.inverted(around: note(60)...note(70)) == key(-6))

        // C major inverted around C4…C♯4 is A major, not B𝄫 major.
        #expect(key(0)?.inverted(around: note(60)...note(61)) == key(3))
    }

    // MARK: Inversion, standard

    @Test
    func invertedAroundPitchRange_custom() {
        let custom = Key(accidentals: [PitchClass.bFlat, .fSharp])
        let expected = Key(accidentals: [PitchClass.bFlat, .eFlat, .aFlat, .gFlat])

        #expect(custom?.inverted(around: Pitch.c4...Pitch.c4) == expected)
    }

    @Test
    func invertedAroundPitchRange_diatonic() {
        #expect(key(1)?.inverted(around: Pitch.c4...Pitch.g4) == key(-4))
        #expect(key(0)?.inverted(around: Pitch.c4...Pitch.c5) == key(-4))
        #expect(key(-4)?.inverted(around: Pitch.c4...Pitch.c5) == key(0))
    }

    @Test
    func invertedAroundPitchRange_enharmonicFallback() {
        // C♯ major inverted around C4…G4 needs G♭ C♭ F♭ B𝄫 E𝄫 A𝄫 D𝄫, so it becomes D major.
        #expect(key(7)?.inverted(around: Pitch.c4...Pitch.g4) == key(2))
    }

    @Test
    func invertedAroundPitchRange_mapsMode() {
        // C major inverted around C is C phrygian.
        #expect(dia(0, .major)?.inverted(around: Pitch.c4...Pitch.c4) == Key.diatonic(tonic: .c, mode: .phrygian))

        // A minor inverted around C4…G4 (A ↦ B♭) is B♭ mixolydian.
        #expect(dia(0, .minor)?.inverted(around: Pitch.c4...Pitch.g4) == Key.diatonic(tonic: .bFlat, mode: .mixolydian))

        // D dorian inverted around C is B♭ dorian.
        #expect(Key.diatonic(tonic: .d, mode: .dorian)?.inverted(around: Pitch.c4...Pitch.c4)
                    == Key.diatonic(tonic: .bFlat, mode: .dorian))
    }

    @Test
    func invertedAroundPitchRange_everyMode() throws {
        for fifths in -7...7 {
            for mode in Key.Mode.allCases {
                let original = try #require(dia(fifths, mode))
                let inverted = try #require(original.inverted(around: Pitch.c4...Pitch.c4))
                let tonic = try #require(original.tonic)
                let invertedTonic = try #require(inverted.tonic)

                #expect(inverted.mode == mode.inverted)
                #expect((tonic.fifthChainPosition + invertedTonic.fifthChainPosition).isMultiple(of: 12))
            }
        }
    }

    @Test
    func invertedAroundPitchRange_noFit() {
        #expect(extreme?.inverted(around: Pitch.c4...Pitch.g4) == nil)
    }

    @Test
    func invertedAroundPitchRange_noMode() {
        #expect(key(1)?.inverted(around: Pitch.c4...Pitch.c4)?.mode == nil)
    }

    // MARK: Transposition by interval

    @Test
    func transposedByInterval_compound() {
        #expect(key(0)?.transposed(by: up(.major9)) == key(2))
        #expect(key(0)?.transposed(by: up(.perfect8)) == key(0))
    }

    @Test
    func transposedByInterval_custom() {
        let custom = Key(accidentals: [PitchClass.bFlat, .aFlat])
        let expected = Key(accidentals: [PitchClass.fSharp, .bFlat])

        #expect(custom?.transposed(by: up(.major2)) == expected)
        #expect(expected?.transposed(by: down(.major2)) == custom)
    }

    @Test
    func transposedByInterval_diatonic() {
        #expect(key(0)?.transposed(by: up(.minor2)) == key(-5))
        #expect(key(0)?.transposed(by: up(.major2)) == key(2))
        #expect(key(0)?.transposed(by: down(.major2)) == key(-2))
        #expect(key(0)?.transposed(by: up(.minor3)) == key(-3))
        #expect(key(0)?.transposed(by: up(.major3)) == key(4))
        #expect(key(0)?.transposed(by: up(.perfect4)) == key(-1))
        #expect(key(0)?.transposed(by: up(.augmented4)) == key(6))
        #expect(key(0)?.transposed(by: up(.diminished5)) == key(-6))
        #expect(key(0)?.transposed(by: up(.perfect5)) == key(1))
        #expect(key(0)?.transposed(by: up(.augmented1)) == key(7))
        #expect(key(0)?.transposed(by: up(.diminished2)) == key(0))     // D𝄫 major is C major
        #expect(key(-1)?.transposed(by: up(.augmented1)) == key(6))
    }

    @Test
    func transposedByInterval_enharmonicFallback() {
        let custom = Key(accidentals: [PitchClass.bFlat, .fSharp])
        let expected = Key(accidentals: [PitchClass.dFlat, .eFlat, .aFlat, .bFlat, .cFlat])

        #expect(custom?.transposed(by: up(.augmented1)) == expected)

        // F♭ major (8♭) is out of reach, so C major up a diminished fourth is E major.
        #expect(dia(0, .major)?.transposed(by: up(.diminished4)) == Key.diatonic(tonic: .e, mode: .major))

        // C𝄪 major (14♯) is out of reach, so C♯ major up an augmented unison is D major.
        #expect(key(7)?.transposed(by: up(.augmented1)) == key(2))

        // G♯ major (8♯) is out of reach, so G major up an augmented unison is A♭ major.
        #expect(Key.diatonic(tonic: .g, mode: .major)?.transposed(by: up(.augmented1))
                    == Key.diatonic(tonic: .aFlat, mode: .major))
    }

    @Test
    func transposedByInterval_keepsMode() {
        #expect(Key.diatonic(tonic: .e, mode: .minor)?.transposed(by: up(.major2))
                    == Key.diatonic(tonic: .fSharp, mode: .minor))
        #expect(Key.diatonic(tonic: .d, mode: .dorian)?.transposed(by: down(.minor3))
                    == Key.diatonic(tonic: .b, mode: .dorian))
        #expect(key(2)?.transposed(by: up(.perfect5))?.mode == nil)
    }

    @Test
    func transposedByInterval_noFit() {
        #expect(extreme?.transposed(by: up(.perfect5)) == nil)
        #expect(extreme?.transposed(by: down(.perfect5)) == nil)
    }

    @Test
    func transposedByInterval_unison() {
        let unison = DirectedInterval(interval: Interval.perfect1,
                                      direction: .same)

        #expect(key(3)?.transposed(by: unison) == key(3))
        #expect(extreme?.transposed(by: unison) == extreme)
    }

    // MARK: Transposition by key steps

    @Test
    func transposedByKeySteps_custom() {
        let custom = Key(accidentals: [PitchClass.fSharp, .gSharp])
        let expected = Key(accidentals: [PitchClass.fSharp, .cSharp, .gSharp, .aSharp])

        #expect(custom?.transposed(by: steps(2)) == expected)
    }

    @Test
    func transposedByKeySteps_everyStep() {
        let expected = [0, -5, 2, -3, 4, -1, 6, 1, -4, 3, -2, 5, 0, -5]

        for (count, fifths) in expected.enumerated() {
            #expect(key(0)?.transposed(by: steps(count)) == key(fifths))
        }
    }

    @Test
    func transposedByKeySteps_folds() {
        // B major up two steps is C♯ major (7♯), but D♭ major (5♭) has fewer accidentals.
        #expect(dia(5, .major)?.transposed(by: steps(2)) == Key.diatonic(tonic: .dFlat, mode: .major))

        // G♭ major down two steps would be F♭ major (8♭), so it’s E major.
        #expect(key(-6)?.transposed(by: steps(-2)) == key(4))
    }

    @Test
    func transposedByKeySteps_tiesKeepInterval() {
        // F major up a semitone is G♭ major (a minor second), not F♯ major.
        #expect(key(-1)?.transposed(by: steps(1)) == key(-6))

        // C major up a tritone is F♯ major; down a tritone is G♭ major.
        #expect(key(0)?.transposed(by: steps(6)) == key(6))
        #expect(key(0)?.transposed(by: steps(-6)) == key(-6))
    }

    // MARK: Transposition by ratio

    @Test
    func transposedByRatio_nearSemitones() {
        #expect(key(0)?.transposed(by: ratio(Ratio(3, 2), .ascending)) == key(1))
        #expect(key(0)?.transposed(by: ratio(Ratio(3, 2), .descending)) == key(-1))
        #expect(key(0)?.transposed(by: ratio(Ratio(5, 4), .ascending)) == key(4))
        #expect(key(0)?.transposed(by: ratio(Ratio(cents: 75), .ascending)) == key(-5))
        #expect(key(0)?.transposed(by: ratio(Ratio(cents: 1_220), .ascending)) == key(0))
        #expect(key(2)?.transposed(by: ratio(.unison, .same)) == key(2))
        #expect(dia(-3, .minor)?.transposed(by: ratio(Ratio(3, 2), .ascending)) == dia(-2, .minor))
    }

    @Test
    func transposedByRatio_offSemitones() {
        #expect(key(0)?.transposed(by: ratio(Ratio(7, 4), .ascending)) == nil)
        #expect(key(0)?.transposed(by: ratio(Ratio(cents: 50), .ascending)) == nil)
        #expect(key(0)?.transposed(by: ratio(Ratio(cents: 74), .descending)) == nil)
    }
}

// MARK: - Private

/// `{F♭, B♯}` spans the whole line of fifths that single accidentals reach, so it can’t move.
private let extreme = Key(accidentals: [PitchClass.fFlat, .bSharp])

private let intervals: [Interval] = [.augmented1,
                                     .minor2,
                                     .major2,
                                     .minor3,
                                     .major3,
                                     .diminished4,
                                     .perfect4,
                                     .augmented4,
                                     .diminished5,
                                     .perfect5,
                                     .minor6,
                                     .major6,
                                     .minor7,
                                     .major7,
                                     .perfect8]

private let noteRanges: [ClosedRange<NoteNumber>] = [note(60)...note(60),
                                                     note(60)...note(61),
                                                     note(60)...note(67),
                                                     note(60)...note(70)]

private let pitchRanges: [ClosedRange<Pitch>] = [Pitch.c4...Pitch.c4,
                                                 Pitch.c4...Pitch.g4,
                                                 Pitch.c4...Pitch.c5]

private func dia(_ fifths: Int,
                 _ mode: Key.Mode) -> Key? {
    Key.diatonic(fifths: fifths,
                 mode: mode)
}

private func down(_ interval: Interval) -> DirectedInterval<Interval> {
    DirectedInterval(interval: interval,
                     direction: .descending)
}

private func key(_ fifths: Int) -> Key? {
    Key.diatonic(fifths: fifths,
                 mode: nil)
}

private func note(_ value: UInt) -> NoteNumber {
    NoteNumber(uintValue: value)!     // swiftlint:disable:this force_unwrapping
}

private func ratio(_ ratio: Ratio,
                   _ direction: PitchDirection) -> DirectedInterval<Ratio> {
    DirectedInterval(interval: ratio,
                     direction: direction)
}

private func steps(_ count: Int) -> DirectedInterval<NoteDistance> {
    let distance = NoteDistance(uintValue: UInt(abs(count)))!     // swiftlint:disable:this force_unwrapping
    let direction: PitchDirection = switch count.signum() {
    case 1:
        .ascending

    case -1:
        .descending

    default:
        .same
    }

    return DirectedInterval(interval: distance,
                            direction: direction)
}

private func up(_ interval: Interval) -> DirectedInterval<Interval> {
    DirectedInterval(interval: interval,
                     direction: .ascending)
}
