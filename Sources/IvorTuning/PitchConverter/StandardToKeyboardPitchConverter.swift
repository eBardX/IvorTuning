// © 2026 John Gary Pusey (see LICENSE.md)

/// Converts standard notation pitches (``Pitch``) to MIDI note numbers (``NoteNumber``)
/// using a keyboard map, tuning system, and pitch standard.
public struct StandardToKeyboardPitchConverter<System: TuningSystem> {

    // MARK: Public Initializers

    /// Creates a converter with the given keyboard map, tuning system, and pitch standard.
    ///
    /// - Parameter keyboardMap:    The keyboard map defining the key layout.
    /// - Parameter tuningSystem:   The tuning system used to map pitches to frequencies.
    /// - Parameter pitchStandard:  The reference pitch and its frequency. Defaults to `.a440`.
    public init(keyboardMap: KeyboardMap,
                tuningSystem: System,
                pitchStandard: PitchStandard = .a440) {
        self.keyboardMap = keyboardMap
        self.pitchStandard = pitchStandard
        self.tuningSystem = tuningSystem
    }

    // MARK: Private Instance Properties

    private let keyboardMap: KeyboardMap
    private let pitchStandard: PitchStandard
    private let tuningSystem: System
}

// MARK: -

extension StandardToKeyboardPitchConverter: PitchConverter {

    // MARK: Public Instance Methods

    // swiftlint:disable:next orphaned_doc_comment
    /// Returns the MIDI note number nearest to the given standard pitch.
    ///
    /// - Parameter pitch:  The standard pitch to convert.
    ///
    /// - Returns:  The nearest mapped note number.
    // swiftlint:disable:next unavailable_function
    public func convert(_ pitch: Pitch) -> NoteNumber {
        fatalError("not yet implemented")
    }
}
