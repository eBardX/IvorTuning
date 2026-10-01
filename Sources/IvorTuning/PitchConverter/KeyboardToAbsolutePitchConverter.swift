// © 2026 John Gary Pusey (see LICENSE.md)

/// Converts MIDI note numbers (``NoteNumber``) to absolute frequency pitches (``Frequency``)
/// using a keyboard map.
public struct KeyboardToAbsolutePitchConverter {

    // MARK: Public Initializers

    /// Creates a converter with the given keyboard map.
    ///
    /// This conversion is not yet supported, so this initializer always throws. Use
    /// ``PitchNotation/isConversionSupported(to:)`` to check first.
    ///
    /// - Parameter keyboardMap:    The keyboard map defining the key-to-frequency layout.
    ///
    /// - Throws:   ``TuningError/unsupportedConversion(from:to:)``, always.
    public init(keyboardMap: KeyboardMap) throws(TuningError) {
        throw TuningError.unsupportedConversion(from: .keyboard,
                                                to: .absolute)
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
}

// MARK: - PitchConverter

extension KeyboardToAbsolutePitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    // swiftlint:disable:next orphaned_doc_comment
    /// Returns the frequency corresponding to the given note number.
    ///
    /// - Parameter noteNumber: The MIDI note number to convert.
    ///
    /// - Returns:  The frequency of `noteNumber`.
    // swiftlint:disable:next unavailable_function
    public func convert(_ noteNumber: NoteNumber) -> Frequency {
        // Unreachable: `init` always throws.
        fatalError("not yet implemented")
    }
}
