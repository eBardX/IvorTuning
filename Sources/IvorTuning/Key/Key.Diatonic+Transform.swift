// © 2026 John Gary Pusey (see LICENSE.md)

extension Key.Diatonic {

    // MARK: Public Instance Methods

    /// Returns this key inverted around a range of pitches, as
    /// `NoteTable.invert(around:noteIDs:)` inverts pitches in standard notation.
    ///
    /// The diatonic collection is reflected, so the tonic is inverted and the mode, if any, is
    /// mapped (see ``Key/Mode/inverted``): C major inverted around C is C phrygian. If the exact
    /// result needs more than seven sharps or flats, its enharmonic equivalent is returned
    /// instead.
    ///
    /// - Parameter pitchRange: The range of pitches to invert around.
    ///
    /// - Returns:  The inverted key, or `nil` if no enharmonic equivalent fits.
    public func inverted(around pitchRange: ClosedRange<Pitch>) -> Self? {
        _diatonic(LineOfFifths.inverted(positions,
                                        around: pitchRange),
                  mode: mode?.inverted)
    }

    /// Returns this key inverted around a range of MIDI note numbers, as
    /// `NoteTable.invert(around:noteIDs:)` inverts pitches in keyboard notation.
    ///
    /// The collection is reflected around C, then transposed up by the key steps the range’s
    /// bounds add up to, as transposing by key steps does; the mode, if any, is mapped. This
    /// assumes 12 keys to the octave.
    ///
    /// - Parameter noteRange:  The range of note numbers to invert around.
    ///
    /// - Returns:  The inverted key, or `nil` if no enharmonic equivalent fits.
    public func inverted(around noteRange: ClosedRange<NoteNumber>) -> Self? {
        _diatonic(LineOfFifths.inverted(positions,
                                        around: noteRange),
                  mode: mode?.inverted)
    }

    /// Returns this key transposed by a directed interval in standard notation.
    ///
    /// The tonic moves by the interval and the mode is kept. If the exact result needs more than
    /// seven sharps or flats, its enharmonic equivalent is returned instead: G♯ major becomes
    /// A♭ major.
    ///
    /// - Parameter directedInterval:   The directed interval to transpose by.
    ///
    /// - Returns:  The transposed key, or `nil` if the interval has no equivalent in fifths.
    public func transposed(by directedInterval: DirectedInterval<Interval>) -> Self? {
        _diatonic(LineOfFifths.transposed(positions,
                                          by: directedInterval),
                  mode: mode)
    }

    /// Returns this key transposed by a directed distance in key steps.
    ///
    /// Each key step count transposes as its usual interval, then the result is replaced by its
    /// enharmonic equivalent only if that has strictly fewer accidentals. So F major up one step
    /// is G♭ major, not F♯ major. The mode is kept. This assumes 12 keys to the octave.
    ///
    /// - Parameter directedInterval:   The directed distance to transpose by.
    ///
    /// - Returns:  The transposed key.
    public func transposed(by directedInterval: DirectedInterval<NoteDistance>) -> Self? {
        _diatonic(LineOfFifths.transposed(positions,
                                          by: directedInterval),
                  mode: mode)
    }

    /// Returns this key transposed by a directed frequency ratio.
    ///
    /// A ratio within ±25 cents of a whole number of 12-tone equal-tempered semitones
    /// transposes as that many key steps, as transposing by a `NoteDistance` does. The mode is
    /// kept.
    ///
    /// - Parameter directedInterval:   The directed ratio to transpose by.
    ///
    /// - Returns:  The transposed key, or `nil` if the ratio is more than 25 cents from a whole
    ///             number of semitones.
    public func transposed(by directedInterval: DirectedInterval<Ratio>) -> Self? {
        _diatonic(LineOfFifths.transposed(positions,
                                          by: directedInterval),
                  mode: mode)
    }

    // MARK: Private Instance Methods

    private func _diatonic(_ positions: [Int]?,
                           mode: Key.Mode?) -> Self? {
        guard let positions,
              let fifths = LineOfFifths.diatonicFifths(of: positions)
        else { return nil }

        return Self(fifths: fifths,
                    mode: mode)
    }
}
