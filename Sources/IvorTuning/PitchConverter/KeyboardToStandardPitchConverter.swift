// © 2026 John Gary Pusey (see LICENSE.md)

/// Converts MIDI note numbers (``NoteNumber``) to standard notation pitches (``Pitch``)
/// using a pitch speller.
public struct KeyboardToStandardPitchConverter<Speller: PitchSpeller> {

    // MARK: Public Initializers

    /// Creates a converter with the given pitch speller.
    ///
    /// - Parameter pitchSpeller:   The pitch speller used to assign spelled pitch names.
    public init(pitchSpeller: Speller) {
        self.pitchSpeller = pitchSpeller
    }

    // MARK: Private Instance Properties

    private let pitchSpeller: Speller
}

// MARK: -

extension KeyboardToStandardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    // swiftlint:disable:next orphaned_doc_comment
    /// Returns the standard pitch for the given note number.
    ///
    /// - Parameter noteNumber: The MIDI note number to convert.
    ///
    /// - Returns:  The spelled standard pitch.
    // swiftlint:disable:next unavailable_function
    public func convert(_ noteNumber: NoteNumber) -> Pitch {
        fatalError("not yet implemented")
    }
}
