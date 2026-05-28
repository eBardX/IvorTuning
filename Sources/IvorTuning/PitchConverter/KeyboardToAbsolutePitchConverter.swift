// © 2026 John Gary Pusey (see LICENSE.md)

/// Converts MIDI note numbers (``NoteNumber``) to absolute frequency pitches (``Frequency``)
/// using a keyboard map.
public struct KeyboardToAbsolutePitchConverter {

    // MARK: Public Initializers

    /// Creates a converter with the given keyboard map.
    ///
    /// - Parameter keyboardMap:    The keyboard map defining the key-to-frequency layout.
    public init(keyboardMap: KeyboardMap) {
        self.keyboardMap = keyboardMap
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
}

// MARK: -

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
        fatalError("not yet implemented")
    }
}
