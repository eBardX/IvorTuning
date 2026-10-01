// © 2026 John Gary Pusey (see LICENSE.md)

/// Converts absolute frequency pitches (``Frequency``) to MIDI note numbers (``NoteNumber``)
/// using a keyboard map.
public struct AbsoluteToKeyboardPitchConverter {

    // MARK: Public Initializers

    /// Creates a converter with the given keyboard map.
    ///
    /// This conversion is not yet supported, so this initializer always throws. Use
    /// ``PitchNotation/isConversionSupported(to:)`` to check first.
    ///
    /// - Parameter keyboardMap:    The keyboard map defining the frequency-to-key layout.
    ///
    /// - Throws:   ``TuningError/unsupportedConversion(from:to:)``, always.
    public init(keyboardMap: KeyboardMap) throws(TuningError) {
        throw TuningError.unsupportedConversion(from: .absolute,
                                                to: .keyboard)
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
}

// MARK: - PitchConverter

extension AbsoluteToKeyboardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    // swiftlint:disable:next orphaned_doc_comment
    /// Returns the MIDI note number nearest to the given frequency.
    ///
    /// - Parameter frequency:  The frequency to convert.
    ///
    /// - Returns:  The nearest mapped note number.
    // swiftlint:disable:next unavailable_function
    public func convert(_ frequency: Frequency) -> NoteNumber {
        // Unreachable: `init` always throws.
        fatalError("not yet implemented")
    }
}
