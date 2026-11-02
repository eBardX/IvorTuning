// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A pitch speller that reads each key’s spelling from a pitch-class ``KeyboardLayout``.
///
/// A pitch-class layout names every key it maps, and those names are what the instrument plays:
/// on a 12-key meantone keyboard, the black key between G and A *is* G♯. The spelling is fixed and
/// context-free, so each key always gets its layout spelling, in the octave the layout’s placement
/// gives it.
///
/// There is no public initializer. ``AbsoluteToStandardPitchConverter`` and
/// ``KeyboardToStandardPitchConverter`` create one when they are given a pitch-class layout and no
/// other speller; it appears only in their type, such as
/// `KeyboardToStandardPitchConverter<KeyboardLayoutSpeller>`.
public struct KeyboardLayoutSpeller {

    // MARK: Internal Instance Properties

    // Indexed by MIDI note number; `nil` for a key the layout leaves unmapped or can’t spell.
    internal let pitches: [Pitch?]
}

// MARK: - PitchSpeller

extension KeyboardLayoutSpeller: PitchSpeller {

    // MARK: Public Instance Methods

    /// Returns the layout’s spelling of each note number.
    ///
    /// The converters that own this speller call it only with keys it can spell.
    ///
    /// - Parameter noteNumbers:    The MIDI note numbers to spell. Order doesn’t matter: the
    ///                             spelling is context-free.
    ///
    /// - Returns:  The spelled pitch of each note number, index-aligned with `noteNumbers`.
    public func spell(_ noteNumbers: [NoteNumber]) -> [Pitch] {
        noteNumbers.map { pitches[Int($0.uintValue)].require() }
    }
}

// MARK: - Equatable

extension KeyboardLayoutSpeller: Equatable {
}

// MARK: - Sendable

extension KeyboardLayoutSpeller: Sendable {
}
