// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A type that can assign spelled pitch names to a sequence of MIDI note numbers.
public protocol PitchSpeller: Equatable,
                              Sendable {

    // MARK: Public Instance Methods

    /// Returns a spelled ``Pitch`` for each note number in the input.
    ///
    /// - Parameter noteNumbers: MIDI note numbers sorted by increasing onset time then
    ///                          chromatic pitch, with priority given to onset time.
    ///                          The output array is index-aligned with this array.
    func spell(_ noteNumbers: [NoteNumber]) -> [Pitch]
}

// MARK: -

extension PitchSpeller {

    // MARK: Internal Instance Methods

    // Spells the non-`nil` note numbers together, as one sequence, and leaves each `nil` in
    // place.
    internal func spellMapped(_ noteNumbers: [NoteNumber?]) -> [Pitch?] {
        var spelled = spell(noteNumbers.compactMap(\.self)).makeIterator()

        return noteNumbers.map { $0 == nil ? nil : spelled.next() }
    }
}
