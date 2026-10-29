// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// The direction of movement between two pitches.
///
/// The direction follows each pitch type’s ordering. For ``Frequency`` and ``NoteNumber``, that is
/// how high the pitches sound. For ``Pitch``, it is their notation, because how high a notated
/// pitch sounds depends on the tuning system: C𝄪4 to D♭4 ascends, although in equal temperament
/// it sounds lower.
public enum PitchDirection {

    /// Movement to a pitch that comes later in the ordering: higher, or for ``Pitch``, higher in
    /// notation.
    case ascending

    /// Movement to a pitch that comes earlier in the ordering: lower, or for ``Pitch``, lower in
    /// notation.
    case descending

    /// No movement; the two pitches are identical.
    case same
}

// MARK: - Codable

extension PitchDirection: Codable {
}

// MARK: - Equatable

extension PitchDirection: Equatable {
}

// MARK: - Sendable

extension PitchDirection: Sendable {
}
