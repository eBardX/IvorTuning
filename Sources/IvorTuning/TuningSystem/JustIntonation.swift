// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

/// A tuning system based on just intonation, using pure integer frequency ratios.
///
/// A just intonation system is defined by a set of frequency ratios relative to the
/// tonic, each derived from small-integer harmonics. Any number of tones per period is
/// supported — from a simple pentatonic to Harry Partch's 43-tone 11-limit scale.
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
    ///                         initialisation. Ratios outside `[1, period)` are reduced;
    ///                         exact multiples of the period (including 1:1) are
    ///                         silently discarded.
    /// - Parameter period:     The interval of equivalence. Must be greater than 1:1.
    ///                         Defaults to `.octave` (2:1).
    public init(ratios: [Ratio],
                period: Ratio = .octave) {
        precondition(period.numberValue > 1)

        self._period = period

        let reduced = ratios.compactMap { Self._reduce($0, period: period) }
        let sorted  = reduced.sorted { $0.numberValue < $1.numberValue }

        self._ratios = sorted.reduce(into: []) { acc, r in
            if acc.last.map({ $0.numberValue != r.numberValue }) ?? true {
                acc.append(r)
            }
        }
    }

    // MARK: Public Instance Properties

    /// The frequency ratios of this scale, including the tonic (1:1) and the period.
    ///
    /// The first element is always ``Ratio/unison`` (1:1) and the last is always the
    /// period. Interior ratios are in ascending order.
    public var ratios: [Ratio] {
        [.unison] + _ratios + [_period]
    }

    // MARK: Private Type Methods

    private static func _reduce(_ ratio: Ratio,
                                period: Ratio) -> Ratio? {
        var r = ratio

        while r.numberValue >= period.numberValue {
            guard let reduced = r.subtracting(period)
            else { return nil }

            r = reduced
        }

        return r == .unison ? nil : r
    }

    // MARK: Private Instance Properties

    private let _period: Ratio
    private let _ratios: [Ratio]
}

// MARK: - TuningSystem

extension JustIntonation: TuningSystem {
    public var period: Ratio? {
        _period
    }
}

// MARK: - Sendable

extension JustIntonation: Sendable {
}
