// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A type that describes a musical tuning system.
public protocol TuningSystem: Sendable {

    /// The period interval of this tuning system, or `nil` if it has no defined period.
    var period: Ratio? { get }
}

extension TuningSystem {

    /// The period interval of this tuning system. Defaults to `.octave`.
    public var period: Ratio? {
        .octave
    }
}
