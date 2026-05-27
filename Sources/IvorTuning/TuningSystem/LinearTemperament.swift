// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A tuning system defined by stacking a single generator interval (by default, a tempered
/// perfect fifth) within an interval of equivalence (by default, an octave).
///
/// Pythagorean tuning, meantone temperaments, and other fifth-based systems are all linear
/// temperaments. They differ only in how much the generator is narrowed from 3:2. When
/// `narrowingRatio` is `.unison`, the generator is a pure perfect fifth and the result is
/// Pythagorean tuning.
///
/// The tuning is fully determined by ``narrowingRatio``. The interval of equivalence is an
/// octave (2:1).
///
/// All predefined linear temperaments fully support standard pitch notation via
/// ``standardConversion(for:)``. So-called _extended_ linear temperaments — those requiring
/// more than 35 pitch classes to span the full chain of fifths — are not fully supported.
public struct LinearTemperament {

    // MARK: Public Initializers

    /// Creates a linear temperament with the given fifth-narrowing ratio.
    ///
    /// The generator equals the pure 3:2 divided by `narrowingRatio`. Pass `.unison` for
    /// Pythagorean tuning (pure fifth).
    ///
    /// - Parameter narrowingRatio: The ratio by which the pure perfect fifth (3:2) is
    ///   narrowed. Defaults to `.unison` (no narrowing; Pythagorean tuning).
    public init(narrowingRatio: Ratio = .unison) {
        self.narrowingRatio = narrowingRatio
    }

    // MARK: Public Instance Properties

    /// The ratio by which the pure perfect fifth (3:2) is narrowed.
    ///
    /// A value of `.unison` means no narrowing (Pythagorean tuning).
    public let narrowingRatio: Ratio
}

// MARK: - TuningSystem

extension LinearTemperament: TuningSystem {
    public func standardConversion(for standard: PitchStandard) -> [PitchClass: DirectedInterval<Ratio>]? {
        let fifthRatio = Ratio(3, 2).sub(narrowingRatio)

        return buildStandardConversion(for: standard,
                                       fifthRatio: fifthRatio)
    }
}
