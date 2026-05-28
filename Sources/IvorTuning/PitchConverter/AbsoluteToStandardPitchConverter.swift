// © 2026 John Gary Pusey (see LICENSE.md)

/// Converts absolute frequency pitches (``Frequency``) to standard notation pitches (``Pitch``)
/// using a keyboard map and a pitch speller.
public struct AbsoluteToStandardPitchConverter<Speller: PitchSpeller> {

    // MARK: Public Initializers

    /// Creates a converter with the given keyboard map and pitch speller.
    ///
    /// - Parameter keyboardMap:    The keyboard map defining the frequency-to-key layout.
    /// - Parameter pitchSpeller:   The pitch speller used to assign spelled pitch names.
    public init(keyboardMap: KeyboardMap,
                pitchSpeller: Speller) {
        self.keyboardMap = keyboardMap
        self.pitchSpeller = pitchSpeller
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
    private let pitchSpeller: Speller
}

// MARK: -

extension AbsoluteToStandardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    // swiftlint:disable:next orphaned_doc_comment
    /// Returns the standard pitch nearest to the given frequency.
    ///
    /// - Parameter frequency:  The frequency to convert.
    ///
    /// - Returns:  The spelled standard pitch.
    // swiftlint:disable:next unavailable_function
    public func convert(_ frequency: Frequency) -> Pitch {
        fatalError("not yet implemented")
    }
}
