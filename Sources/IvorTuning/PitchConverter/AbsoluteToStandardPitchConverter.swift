// © 2026 John Gary Pusey (see LICENSE.md)

/// Converts absolute frequency pitches (``Frequency``) to standard notation pitches (``Pitch``)
/// using a keyboard map and a pitch speller.
public struct AbsoluteToStandardPitchConverter<Speller: PitchSpeller> {

    // MARK: Public Initializers

    /// Creates a converter with the given keyboard map and pitch speller.
    ///
    /// This conversion is not yet supported, so this initializer always throws. Use
    /// ``PitchNotation/isConversionSupported(to:)`` to check first.
    ///
    /// - Parameter keyboardMap:    The keyboard map defining the frequency-to-key layout.
    /// - Parameter pitchSpeller:   The pitch speller used to assign spelled pitch names.
    ///
    /// - Throws:   ``TuningError/unsupportedConversion(from:to:)``, always.
    public init(keyboardMap: KeyboardMap,
                pitchSpeller: Speller) throws(TuningError) {
        throw TuningError.unsupportedConversion(from: .absolute,
                                                to: .standard)
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
    private let pitchSpeller: Speller
}

// MARK: - PitchConverter

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
        // Unreachable: `init` always throws.
        fatalError("not yet implemented")
    }
}
