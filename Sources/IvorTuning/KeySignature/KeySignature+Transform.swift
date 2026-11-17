// © 2026 John Gary Pusey (see LICENSE.md)

private import Foundation
private import XestiNumbers

extension KeySignature {

    // MARK: Public Instance Methods

    /// Returns this key signature inverted around a range of pitches, as
    /// `NoteTable.invert(around:noteIDs:)` inverts pitches in standard notation.
    ///
    /// Each of the signature’s seven pitch classes is reflected, so the result is exact: a
    /// diatonic signature stays diatonic, and the lowest pitch of the range becomes the highest.
    /// If the exact result needs a double sharp or double flat, its enharmonic equivalent with
    /// single accidentals is returned instead (the one with fewer accidentals if both qualify).
    ///
    /// - Parameter pitchRange: The range of pitches to invert around.
    ///
    /// - Returns:  The inverted key signature, or `nil` if no enharmonic equivalent fits in
    ///             single accidentals.
    public func inverted(around pitchRange: ClosedRange<Pitch>) -> Self? {
        let axis = pitchRange.lowerBound.pitchClass.fifthChainPosition
            + pitchRange.upperBound.pitchClass.fifthChainPosition

        return Self._normalized(fifthChainPositions.map { axis - $0 },
                                preferringExact: true)
    }

    /// Returns this key signature inverted around a range of MIDI note numbers, as
    /// `NoteTable.invert(around:noteIDs:)` inverts pitches in keyboard notation.
    ///
    /// The signature is reflected around C, then transposed up by the key steps the range’s
    /// bounds add up to, as transposing by key steps does. This
    /// assumes 12 keys to the octave.
    ///
    /// - Parameter noteRange:  The range of note numbers to invert around.
    ///
    /// - Returns:  The inverted key signature, or `nil` if no enharmonic equivalent fits in
    ///             single accidentals.
    public func inverted(around noteRange: ClosedRange<NoteNumber>) -> Self? {
        let keySteps = Int(noteRange.lowerBound.uintValue + noteRange.upperBound.uintValue)

        return Self._transposed(fifthChainPositions.map { -$0 },
                                keySteps: keySteps)
    }

    /// Returns this key signature transposed by a directed interval in standard notation.
    ///
    /// Each of the signature’s seven pitch classes moves by the interval, so the result is
    /// exact: `{B♭, A♭}` up a major second is `{F♯, B♭}`. If the exact result needs a double
    /// sharp or double flat, its enharmonic equivalent with single accidentals is returned
    /// instead (the one with fewer accidentals if both qualify): `{B♭, F♯}` up an augmented
    /// unison is `{D♭, E♭, A♭, B♭, C♭}`.
    ///
    /// - Parameter directedInterval:   The directed interval to transpose by.
    ///
    /// - Returns:  The transposed key signature, or `nil` if no enharmonic equivalent fits in
    ///             single accidentals.
    public func transposed(by directedInterval: DirectedInterval<Interval>) -> Self? {
        guard let fifths = PerfectFifths.fifths(for: directedInterval.interval.simplified())
        else { return nil }

        let shift = Self._signed(fifths,
                                 directedInterval.direction)

        return Self._normalized(fifthChainPositions.map { $0 + shift },
                                preferringExact: true)
    }

    /// Returns this key signature transposed by a directed distance in key steps.
    ///
    /// Each key step count transposes as its usual interval: a minor second for 1, a major
    /// second for 2, and so on up to a major seventh for 11, with a tritone as an augmented
    /// fourth, plus any octaves. The result is then replaced by its enharmonic equivalent only
    /// if it needs a double sharp or double flat, or if the equivalent has strictly fewer
    /// accidentals. So F major up one step is G♭ major (a minor second), not F♯ major; C major
    /// up six steps is F♯ major and down six is G♭ major; and a result past six sharps or flats
    /// folds to the other side. This assumes 12 keys to the octave.
    ///
    /// - Parameter directedInterval:   The directed distance to transpose by.
    ///
    /// - Returns:  The transposed key signature, or `nil` if no enharmonic equivalent fits in
    ///             single accidentals.
    public func transposed(by directedInterval: DirectedInterval<NoteDistance>) -> Self? {
        let keySteps = Self._signed(Int(directedInterval.interval.uintValue),
                                    directedInterval.direction)

        return Self._transposed(fifthChainPositions,
                                keySteps: keySteps)
    }

    /// Returns this key signature transposed by a directed frequency ratio.
    ///
    /// A ratio within ±25 cents of a whole number of 12-tone equal-tempered semitones
    /// transposes as that many key steps, as transposing by a `NoteDistance` does: a just fifth
    /// (3/2, about 702 cents) as a fifth, and 5/4 (about 386 cents) as a major third. A ratio
    /// further off, such as a quarter tone or 7/4 (about 969 cents), leaves the music between
    /// keys, and gives `nil`.
    ///
    /// - Parameter directedInterval:   The directed ratio to transpose by.
    ///
    /// - Returns:  The transposed key signature, or `nil` if the ratio is more than 25 cents
    ///             from a whole number of semitones, or if no enharmonic equivalent fits in single
    ///             accidentals.
    public func transposed(by directedInterval: DirectedInterval<Ratio>) -> Self? {
        let cents = directedInterval.interval.cents.doubleValue
        let semitones = (cents / 100).rounded()

        guard abs(cents - (semitones * 100)) <= Self.semitoneTolerance,
              semitones.isFinite
        else { return nil }

        let keySteps = Self._signed(Int(semitones),
                                    directedInterval.direction)

        return Self._transposed(fifthChainPositions,
                                keySteps: keySteps)
    }

    // MARK: Private Type Properties

    /// The usual interval for each number of key steps within an octave, as fifths.
    private static let keyStepFifths: [Int] = keyStepIntervals.map { PerfectFifths.fifths(for: $0) ?? 0 }

    /// The usual interval for each number of key steps within an octave.
    private static let keyStepIntervals: [Interval] = [.perfect1,
                                                       .minor2,
                                                       .major2,
                                                       .minor3,
                                                       .major3,
                                                       .perfect4,
                                                       .augmented4,
                                                       .perfect5,
                                                       .minor6,
                                                       .major6,
                                                       .minor7,
                                                       .major7]

    private static let semitoneTolerance = 25.0 + 1e-9     // cents, allowing for rounding error

    private static let validPositions = -8...12     // F♭ to B♯

    // MARK: Private Type Methods

    private static func _accidentalCount(_ positions: [Int]) -> Int {
        positions.count { !((-1...5) ~= $0) }       // F to B are natural
    }

    private static func _normalized(_ positions: [Int],
                                    preferringExact: Bool) -> Self? {
        if preferringExact,
           positions.allSatisfy({ validPositions ~= $0 }) {
            return _signature(positions)
        }

        // Shifting every pitch class by 12 fifths gives an enharmonic equivalent. At most two
        // shifts can fit in single accidentals, so ties go to the smaller shift.
        let candidates = (-5...5).compactMap { shift -> (positions: [Int], rank: (Int, Int))? in
            let shifted = positions.map { $0 + (shift * 12) }

            guard shifted.allSatisfy({ validPositions ~= $0 })
            else { return nil }

            return (shifted, (_accidentalCount(shifted), abs(shift)))
        }

        guard let best = candidates.min(by: { $0.rank < $1.rank })
        else { return nil }

        return _signature(best.positions)
    }

    private static func _signature(_ positions: [Int]) -> Self? {
        let pitchClasses = positions.compactMap { PerfectFifths.pitchClass(for: $0 + 1) }   // F is 0 there

        guard pitchClasses.count == positions.count
        else { return nil }

        return Self(accidentals: pitchClasses)
    }

    private static func _signed(_ value: Int,
                                _ direction: PitchDirection) -> Int {
        switch direction {
        case .ascending:
            value

        case .descending:
            -value

        case .same:
            0
        }
    }

    private static func _transposed(_ positions: [Int],
                                    keySteps: Int) -> Self? {
        let magnitude = keyStepFifths[abs(keySteps) % 12]
        let shift = keySteps < 0 ? -magnitude : magnitude

        return _normalized(positions.map { $0 + shift },
                           preferringExact: false)
    }
}
