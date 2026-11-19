// © 2026 John Gary Pusey (see LICENSE.md)

extension Key.Signature {

    // MARK: Public Instance Methods

    /// Returns this signature inverted around a range of pitches, as
    /// `NoteTable.invert(around:noteIDs:)` inverts pitches in standard notation.
    ///
    /// Each of the signature’s seven pitch classes is reflected, so the result is exact and the
    /// lowest pitch of the range becomes the highest. If the exact result needs a double sharp
    /// or double flat, its enharmonic equivalent with single accidentals is returned instead
    /// (the one with fewer accidentals if both qualify). A custom signature always inverts to a
    /// custom signature.
    ///
    /// - Parameter pitchRange: The range of pitches to invert around.
    ///
    /// - Returns:  The inverted signature, or `nil` if no enharmonic equivalent fits in single
    ///             accidentals.
    public func inverted(around pitchRange: ClosedRange<Pitch>) -> Self? {
        Self._signature(LineOfFifths.inverted(fifthChainPositions,
                                              around: pitchRange))
    }

    /// Returns this signature inverted around a range of MIDI note numbers, as
    /// `NoteTable.invert(around:noteIDs:)` inverts pitches in keyboard notation.
    ///
    /// The signature is reflected around C, then transposed up by the key steps the range’s
    /// bounds add up to, as transposing by key steps does. This assumes 12 keys to the octave.
    ///
    /// - Parameter noteRange:  The range of note numbers to invert around.
    ///
    /// - Returns:  The inverted signature, or `nil` if no enharmonic equivalent fits in single
    ///             accidentals.
    public func inverted(around noteRange: ClosedRange<NoteNumber>) -> Self? {
        Self._signature(LineOfFifths.inverted(fifthChainPositions,
                                              around: noteRange))
    }

    /// Returns this signature transposed by a directed interval in standard notation.
    ///
    /// Each of the signature’s seven pitch classes moves by the interval, so the result is
    /// exact: `{B♭, A♭}` up a major second is `{F♯, B♭}`. If the exact result needs a double
    /// sharp or double flat, its enharmonic equivalent with single accidentals is returned
    /// instead (the one with fewer accidentals if both qualify): `{B♭, F♯}` up an augmented
    /// unison is `{D♭, E♭, A♭, B♭, C♭}`.
    ///
    /// - Parameter directedInterval:   The directed interval to transpose by.
    ///
    /// - Returns:  The transposed signature, or `nil` if no enharmonic equivalent fits in single
    ///             accidentals.
    public func transposed(by directedInterval: DirectedInterval<Interval>) -> Self? {
        Self._signature(LineOfFifths.transposed(fifthChainPositions,
                                                by: directedInterval))
    }

    /// Returns this signature transposed by a directed distance in key steps.
    ///
    /// Each key step count transposes as its usual interval: a minor second for 1, a major
    /// second for 2, and so on up to a major seventh for 11, with a tritone as an augmented
    /// fourth, plus any octaves. The result is then replaced by its enharmonic equivalent only
    /// if it needs a double sharp or double flat, or if the equivalent has strictly fewer
    /// accidentals. This assumes 12 keys to the octave.
    ///
    /// - Parameter directedInterval:   The directed distance to transpose by.
    ///
    /// - Returns:  The transposed signature, or `nil` if no enharmonic equivalent fits in single
    ///             accidentals.
    public func transposed(by directedInterval: DirectedInterval<NoteDistance>) -> Self? {
        Self._signature(LineOfFifths.transposed(fifthChainPositions,
                                                by: directedInterval))
    }

    /// Returns this signature transposed by a directed frequency ratio.
    ///
    /// A ratio within ±25 cents of a whole number of 12-tone equal-tempered semitones
    /// transposes as that many key steps, as transposing by a `NoteDistance` does. A ratio
    /// further off, such as a quarter tone or 7/4 (about 969 cents), leaves the music between
    /// keys, and gives `nil`.
    ///
    /// - Parameter directedInterval:   The directed ratio to transpose by.
    ///
    /// - Returns:  The transposed signature, or `nil` if the ratio is more than 25 cents from a
    ///             whole number of semitones, or if no enharmonic equivalent fits in single
    ///             accidentals.
    public func transposed(by directedInterval: DirectedInterval<Ratio>) -> Self? {
        Self._signature(LineOfFifths.transposed(fifthChainPositions,
                                                by: directedInterval))
    }

    // MARK: Private Type Methods

    private static func _signature(_ positions: [Int]?) -> Self? {
        guard let positions,
              let pitchClasses = LineOfFifths.pitchClasses(atPositions: positions)
        else { return nil }

        return Self(accidentals: pitchClasses)
    }
}
