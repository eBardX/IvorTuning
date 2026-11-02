// © 2026 John Gary Pusey (see LICENSE.md)

extension KeyboardLayout {

    // MARK: Public Nested Types

    /// What a keyboard layout was built from: exactly the arguments of one of its initializers.
    ///
    /// Read a layout’s ``KeyboardLayout/definition`` to export it or show it in an editor, and
    /// pass a definition to ``KeyboardLayout/init(_:)`` to build a layout from one. A definition
    /// built by hand is unchecked; it becomes a layout only through that throwing initializer.
    public enum Definition {

        /// A degree layout; see ``KeyboardLayout/init(degrees:anchorNote:referenceNote:)``.
        case degrees([Int?],
                     anchorNote: NoteNumber,
                     referenceNote: NoteNumber)

        /// A frequency layout; see ``KeyboardLayout/init(frequencies:)``.
        case frequencies([Frequency?])

        /// A pitch-class layout; see
        /// ``KeyboardLayout/init(pitchClasses:anchorNote:anchorOctave:)``.
        case pitchClasses([PitchClass?],
                          anchorNote: NoteNumber,
                          anchorOctave: Pitch.Octave)

        /// A raw-ratio layout; see
        /// ``KeyboardLayout/init(ratios:equivalenceRatio:anchorNote:referenceNote:referenceFrequency:)``.
        case ratios([Ratio?],
                    equivalenceRatio: Ratio,
                    anchorNote: NoteNumber,
                    referenceNote: NoteNumber,
                    referenceFrequency: Frequency)
    }
}

// MARK: - Codable

extension KeyboardLayout.Definition: Codable {
}

// MARK: - Equatable

extension KeyboardLayout.Definition: Equatable {
}

// MARK: - Hashable

extension KeyboardLayout.Definition: Hashable {
}

// MARK: - Sendable

extension KeyboardLayout.Definition: Sendable {
}
