// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// The direction of movement between two pitches.
public enum PitchDirection {

    /// Movement from a higher pitch to a lower pitch.
    case descending

    /// No movement; the two pitches are identical.
    case same

    /// Movement from a lower pitch to a higher pitch.
    case ascending
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
