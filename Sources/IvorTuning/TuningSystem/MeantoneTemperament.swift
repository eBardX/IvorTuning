// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A tuning system in the meantone family, defined by the size of the tempered perfect fifth.
///
/// In meantone temperament, the perfect fifth is narrowed from the pure Pythagorean 3:2 so
/// that a specific number of stacked fifths produces a pure target interval. All other
/// intervals are derived by chaining that fifth, exactly as in Pythagorean tuning but with a
/// non-pure fifth.
///
/// The tuning is fully determined by ``fifthRatio``. The period is an octave (2:1).
public struct MeantoneTemperament {

    // MARK: Public Initializers

    /// Creates a meantone temperament with the given tempered fifth.
    ///
    /// - Parameter fifthRatio: The frequency ratio of the tempered perfect fifth.
    public init(fifthRatio: Ratio) {
        self.fifthRatio = fifthRatio
    }

    // MARK: Public Instance Properties

    /// The frequency ratio of the tempered perfect fifth.
    public let fifthRatio: Ratio
}

// MARK: - TuningSystem

extension MeantoneTemperament: TuningSystem {
}

// MARK: - Sendable

extension MeantoneTemperament: Sendable {
}
