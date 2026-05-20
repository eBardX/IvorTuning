// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A tuning system that derives all intervals from the pure perfect fifth (3:2).
///
/// Every pitch ratio is computed as (3/2)ⁿ × 2ᵐ, where `n` is the pitch's position
/// along the chain of fifths and `m` is the octave adjustment that brings the result
/// within the period. The domain is bounded by the `Pitch` and `Interval` types: the
/// most extreme representable pitch classes are F𝄫 (−15 fifths) and B𝄪 (+19 fifths).
///
/// Because the tuning is fully determined by the pure fifth, this type has no stored
/// properties.
public struct PythagoreanTuning: TuningSystem {

    // MARK: Public Initializers

    /// Creates a Pythagorean tuning.
    public init() {
    }
}

// MARK: - Sendable

extension PythagoreanTuning: Sendable {
}
