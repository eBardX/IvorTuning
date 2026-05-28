// © 2026 John Gary Pusey (see LICENSE.md)

/// Converts absolute frequency pitches (``Frequency``) to MIDI note numbers (``NoteNumber``)
/// using a keyboard map.
public struct AbsoluteToKeyboardPitchConverter {

    // MARK: Public Initializers

    /// Creates a converter with the given keyboard map.
    ///
    /// - Parameter keyboardMap:    The keyboard map defining the frequency-to-key layout.
    public init(keyboardMap: KeyboardMap) {
        self.keyboardMap = keyboardMap
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
}

// MARK: -

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
        fatalError("not yet implemented")
    }
}
