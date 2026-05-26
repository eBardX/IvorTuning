// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

/// A tuning system based on just intonation, using exact integer frequency ratios.
///
/// A just intonation system is defined by a set of frequency ratios relative to the
/// tonic, each derived from small-integer harmonics. Any number of tones per interval of
/// equivalence is supported — from a simple pentatonic to Harry Partch’s 43-tone 11-limit scale.
///
/// On initialisation, ratios outside `[1, equivalenceRatio)` are reduced by dividing by
/// `equivalenceRatio` until they fall in range; exact multiples of `equivalenceRatio`
/// (including 1:1) are silently discarded. The remaining ratios are deduplicated and sorted
/// ascending.
///
/// The ``ratios`` property prepends the tonic (1:1) and appends the interval of equivalence,
/// so it always spans one complete interval of equivalence.
///
/// Standard pitch notation support is limited to 5-limit systems. ``fiveLimit`` fully
/// supports ``standardConversion(for:)``. Systems beyond 5-limit (e.g., ``sevenLimit``,
/// ``partch43``) diverge too far from Pythagorean tuning to be representable in standard
/// notation, and may also exceed the 35-pitch-class maximum.
public struct JustIntonation {

    // MARK: Public Initializers

    /// Creates a just intonation system with the given scale ratios.
    ///
    /// - Parameter ratios:            The frequency ratios of the scale degrees, relative to
    ///                                the tonic. Order is immaterial; ratios are sorted on
    ///                                initialization. Ratios outside `[1, equivalenceRatio)`
    ///                                are reduced; exact multiples of `equivalenceRatio`
    ///                                (including 1:1) are silently discarded.
    /// - Parameter equivalenceRatio:  The interval of equivalence. Defaults to `.octave` (2:1).
    ///
    /// - Precondition: `equivalenceRatio` must be exact and not a unison (1:1).
    /// - Precondition: All elements of `ratios` must be exact.
    public init(ratios: [Ratio],
                equivalenceRatio: Ratio = .octave) {
        precondition(equivalenceRatio.isExact && !equivalenceRatio.isUnison)
        precondition(ratios.allSatisfy { $0.isExact })

        let reducedRatios = ratios.compactMap { Self._reduceRatio($0, equivalenceRatio) }

        self.interiorRatios = Set(reducedRatios).sorted()
        self.equivalenceRatio = equivalenceRatio
    }

    // MARK: Public Instance Properties

    /// The interval of equivalence. Defaults to `.octave` (2:1).
    public let equivalenceRatio: Ratio

    /// The frequency ratios of this scale, including the tonic (1:1) and the interval of
    /// equivalence.
    ///
    /// The first element is always ``Ratio/unison`` (1:1) and the last is always the interval
    /// of equivalence. Interior ratios are in ascending order.
    public var ratios: [Ratio] {
        [.unison] + interiorRatios + [equivalenceRatio]
    }

    // MARK: Private Type Methods

    private static func _reduceRatio(_ ratio: Ratio,
                                     _ equivalenceRatio: Ratio) -> Ratio? {
        var r = ratio

        while r.numberValue >= equivalenceRatio.numberValue {
            guard let reduced = r.subtracting(equivalenceRatio)
            else { return nil }

            r = reduced
        }

        return r == .unison ? nil : r
    }

    // MARK: Private Instance Properties

    private let interiorRatios: [Ratio]
}

// MARK: - TuningSystem

extension JustIntonation: TuningSystem {
}

// MARK: - Sendable

extension JustIntonation: Sendable {
}
