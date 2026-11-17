// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorTuning
import Testing
import XestiNumbers

struct KeySignatureTransformTests {
}

// MARK: -

extension KeySignatureTransformTests {

    // MARK: Inversion, keyboard

    @Test
    func invertedAroundNoteRange_diatonic() {
        #expect(key(1)?.inverted(around: note(60)...note(67)) == key(-4))
        #expect(key(0)?.inverted(around: note(60)...note(72)) == key(-4))
        #expect(key(0)?.inverted(around: note(60)...note(61)) == key(3))
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
        let keySignature = KeySignature(accidentals: [PitchClass.bFlat, .fSharp])
        let expected = KeySignature(accidentals: [PitchClass.bFlat, .eFlat, .aFlat, .gFlat])

        #expect(keySignature?.inverted(around: Pitch.c4...Pitch.c4) == expected)
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
    func invertedAroundPitchRange_noFit() {
        #expect(extreme?.inverted(around: Pitch.c4...Pitch.g4) == nil)
    }

    // MARK: Nearest diatonic signature

    @Test
    func nearestDiatonic_diatonic() {
        for fifths in -7...7 {
            #expect(key(fifths)?.nearestDiatonic == key(fifths))
        }
    }

    @Test
    func nearestDiatonic_fewestDifferences() {
        #expect(KeySignature(accidentals: [PitchClass.fSharp, .cSharp, .gSharp, .eSharp])?.nearestDiatonic == key(3))
        #expect(KeySignature(accidentals: [PitchClass.eFlat])?.nearestDiatonic == key(0))
    }

    @Test
    func nearestDiatonic_tieBreaks() {
        // One letter from both 1♯ and 3♯: fewer accidentals.
        #expect(KeySignature(accidentals: [PitchClass.fSharp, .gSharp])?.nearestDiatonic == key(1))

        // One letter from both 1♭ and 3♭: fewer accidentals.
        #expect(KeySignature(accidentals: [PitchClass.bFlat, .aFlat])?.nearestDiatonic == key(-1))

        // One letter from both 1♯ and 1♭, leaning neither way: sharps.
        #expect(KeySignature(accidentals: [PitchClass.bFlat, .fSharp])?.nearestDiatonic == key(1))

        // Two letters from 1♯, 1♭ and 3♯, leaning to sharps.
        #expect(KeySignature(accidentals: [PitchClass.bFlat, .fSharp, .gSharp])?.nearestDiatonic == key(1))

        // Two letters from 1♯, 1♭ and 3♭, leaning to flats.
        #expect(KeySignature(accidentals: [PitchClass.bFlat, .aFlat, .fSharp])?.nearestDiatonic == key(-1))
    }

    // MARK: Transposition by interval

    @Test
    func transposedByInterval_compound() {
        #expect(key(0)?.transposed(by: up(.major9)) == key(2))
        #expect(key(0)?.transposed(by: up(.perfect8)) == key(0))
    }

    @Test
    func transposedByInterval_custom() {
        let keySignature = KeySignature(accidentals: [PitchClass.bFlat, .aFlat])
        let expected = KeySignature(accidentals: [PitchClass.fSharp, .bFlat])

        #expect(keySignature?.transposed(by: up(.major2)) == expected)
        #expect(expected?.transposed(by: down(.major2)) == keySignature)
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
        let keySignature = KeySignature(accidentals: [PitchClass.bFlat, .fSharp])
        let expected = KeySignature(accidentals: [PitchClass.dFlat, .eFlat, .aFlat, .bFlat, .cFlat])

        #expect(keySignature?.transposed(by: up(.augmented1)) == expected)

        // F♭ major (8♭) is out of reach, so C major up a diminished fourth is E major.
        #expect(key(0)?.transposed(by: up(.diminished4)) == key(4))

        // C𝄪 major (14♯) is out of reach, so C♯ major up an augmented unison is D major.
        #expect(key(7)?.transposed(by: up(.augmented1)) == key(2))
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
        let keySignature = KeySignature(accidentals: [PitchClass.fSharp, .gSharp])
        let expected = KeySignature(accidentals: [PitchClass.fSharp, .cSharp, .gSharp, .aSharp])

        #expect(keySignature?.transposed(by: steps(2)) == expected)
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
        #expect(key(5)?.transposed(by: steps(2)) == key(-5))

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
private let extreme = KeySignature(accidentals: [PitchClass.fFlat, .bSharp])

private func down(_ interval: Interval) -> DirectedInterval<Interval> {
    DirectedInterval(interval: interval,
                     direction: .descending)
}

private func key(_ fifths: Int) -> KeySignature? {
    KeySignature(fifths: fifths)
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
