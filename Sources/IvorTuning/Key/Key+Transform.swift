// © 2026 John Gary Pusey (see LICENSE.md)

extension Key {

    // MARK: Public Instance Methods

    /// Returns this key inverted around a range of pitches, as
    /// `NoteTable.invert(around:noteIDs:)` inverts pitches in standard notation.
    ///
    /// An atonal key is unchanged. A diatonic key inverts its tonic and maps its mode, if any
    /// (see ``Diatonic/inverted(around:)-(ClosedRange<Pitch>)``). A custom key inverts its
    /// pitch classes (see ``Signature/inverted(around:)-(ClosedRange<Pitch>)``). A diatonic
    /// key stays diatonic and a custom key stays custom.
    ///
    /// - Parameter pitchRange: The range of pitches to invert around.
    ///
    /// - Returns:  The inverted key, or `nil` if no enharmonic equivalent fits in single
    ///             accidentals.
    public func inverted(around pitchRange: ClosedRange<Pitch>) -> Self? {
        _transformed(diatonic: { $0.inverted(around: pitchRange) },
                     custom: { $0.inverted(around: pitchRange) })
    }

    /// Returns this key inverted around a range of MIDI note numbers, as
    /// `NoteTable.invert(around:noteIDs:)` inverts pitches in keyboard notation.
    ///
    /// An atonal key is unchanged; a diatonic or custom key inverts as its payload does. This
    /// assumes 12 keys to the octave.
    ///
    /// - Parameter noteRange:  The range of note numbers to invert around.
    ///
    /// - Returns:  The inverted key, or `nil` if no enharmonic equivalent fits in single
    ///             accidentals.
    public func inverted(around noteRange: ClosedRange<NoteNumber>) -> Self? {
        _transformed(diatonic: { $0.inverted(around: noteRange) },
                     custom: { $0.inverted(around: noteRange) })
    }

    /// Returns this key transposed by a directed interval in standard notation.
    ///
    /// An atonal key is unchanged. A diatonic key moves its tonic and keeps its mode; a custom
    /// key moves its pitch classes. Results that need a double sharp or double flat are
    /// respelled enharmonically.
    ///
    /// - Parameter directedInterval:   The directed interval to transpose by.
    ///
    /// - Returns:  The transposed key, or `nil` if the interval has no equivalent in fifths or
    ///             no enharmonic equivalent fits in single accidentals.
    public func transposed(by directedInterval: DirectedInterval<Interval>) -> Self? {
        _transformed(diatonic: { $0.transposed(by: directedInterval) },
                     custom: { $0.transposed(by: directedInterval) })
    }

    /// Returns this key transposed by a directed distance in key steps.
    ///
    /// An atonal key is unchanged; a diatonic or custom key transposes as its payload does,
    /// with the spelling that has the fewest accidentals. This assumes 12 keys to the octave.
    ///
    /// - Parameter directedInterval:   The directed distance to transpose by.
    ///
    /// - Returns:  The transposed key, or `nil` if no enharmonic equivalent fits in single
    ///             accidentals.
    public func transposed(by directedInterval: DirectedInterval<NoteDistance>) -> Self? {
        _transformed(diatonic: { $0.transposed(by: directedInterval) },
                     custom: { $0.transposed(by: directedInterval) })
    }

    /// Returns this key transposed by a directed frequency ratio.
    ///
    /// An atonal key is unchanged; a diatonic or custom key transposes as its payload does.
    ///
    /// - Parameter directedInterval:   The directed ratio to transpose by.
    ///
    /// - Returns:  The transposed key, or `nil` if the ratio is more than 25 cents from a whole
    ///             number of semitones, or if no enharmonic equivalent fits in single
    ///             accidentals.
    public func transposed(by directedInterval: DirectedInterval<Ratio>) -> Self? {
        _transformed(diatonic: { $0.transposed(by: directedInterval) },
                     custom: { $0.transposed(by: directedInterval) })
    }

    // MARK: Private Instance Methods

    private func _transformed(diatonic diatonicTransform: (Diatonic) -> Diatonic?,
                              custom customTransform: (Signature) -> Signature?) -> Self? {
        switch self {
        case .atonal:
            .atonal

        case let .custom(signature):
            customTransform(signature).map { .custom($0) }

        case let .diatonic(diatonic):
            diatonicTransform(diatonic).map { .diatonic($0) }
        }
    }
}
