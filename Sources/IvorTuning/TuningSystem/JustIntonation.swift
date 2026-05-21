// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

/// A tuning system based on just intonation, using exact integer frequency ratios.
///
/// A just intonation system is defined by a set of frequency ratios relative to the
/// tonic, each derived from small-integer harmonics. Any number of tones per period is
/// supported — from a simple pentatonic to Harry Partch’s 43-tone 11-limit scale.
///
/// On initialisation, ratios outside `[1, period)` are reduced by dividing by the
/// period until they fall in range; exact multiples of the period (including 1:1) are
/// silently discarded. The remaining ratios are deduplicated and sorted ascending.
///
/// The ``ratios`` property prepends the tonic (1:1) and appends the period, so it
/// always spans a complete period.
public struct JustIntonation {

    // MARK: Public Initializers

    /// Creates a just intonation system with the given scale ratios.
    ///
    /// - Parameter ratios:     The frequency ratios of the scale degrees, relative to
    ///                         the tonic. Order is immaterial; ratios are sorted on
    ///                         initialization. Ratios outside `[1, period)` are reduced;
    ///                         exact multiples of the period (including 1:1) are
    ///                         silently discarded.
    /// - Parameter period:     The interval of equivalence.
    ///                         Defaults to `.octave` (2:1).
    ///
    /// - Precondition: `period` must be exact and not a unison (1:1).
    /// - Precondition: All elements of `ratios` must be exact.
    public init(ratios: [Ratio],
                period: Ratio = .octave) {
        precondition(period.numberValue.isExact && !period.isUnison)
        precondition(ratios.allSatisfy { $0.numberValue.isExact })

        let reducedRatios = ratios.compactMap { Self._reduceRatio($0, period) }

        self.interiorRatios = Set(reducedRatios).sorted()
        self.unwrappedPeriod = period
    }

    // MARK: Public Instance Properties

    /// The frequency ratios of this scale, including the tonic (1:1) and the period.
    ///
    /// The first element is always ``Ratio/unison`` (1:1) and the last is always the
    /// period. Interior ratios are in ascending order.
    public var ratios: [Ratio] {
        [.unison] + interiorRatios + [unwrappedPeriod]
    }

    // MARK: Private Type Methods

    private static func _reduceRatio(_ ratio: Ratio,
                                     _ period: Ratio) -> Ratio? {
        var r = ratio

        while r.numberValue >= period.numberValue {
            guard let reduced = r.subtracting(period)
            else { return nil }

            r = reduced
        }

        return r == .unison ? nil : r
    }

    // MARK: Private Instance Properties

    private let interiorRatios: [Ratio]
    private let unwrappedPeriod: Ratio
}

// MARK: - TuningSystem

extension JustIntonation: TuningSystem {
    /// The period interval of this tuning system. Always non-`nil`. Defaults to
    /// `.octave`.
    public var period: Ratio? {
        unwrappedPeriod
    }
}

// MARK: - Sendable

extension JustIntonation: Sendable {
}
