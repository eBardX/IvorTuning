// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A type that describes a musical tuning system.
///
/// A tuning system may optionally support conversion to standard pitch notation (SPN) by
/// implementing ``standardConversion(for:)``. Standard notation requires a 2:1 octave as its
/// interval of equivalence and can represent at most 35 distinct pitch classes per octave
/// (7 letters × 5 accidentals).
public protocol TuningSystem: Equatable,
                              Sendable {

    /// The interval of equivalence of this tuning system.
    var equivalenceRatio: Ratio { get }

    /// Returns a pitch-class mapping for converting standard pitches to absolute frequencies.
    ///
    /// Returns `nil` if this tuning system does not support standard pitch notation (e.g., because
    /// its interval of equivalence is not 2:1, or it has more than 35 distinct pitch classes per
    /// octave). Otherwise returns a dictionary with exactly 35 entries — one per pitch class.
    ///
    /// **Convention for each entry:** the directed frequency ratio from `standard`’s reference
    /// pitch to the instance of that pitch class within the **same SPN octave** as the reference.
    /// Direction is `.ascending` if that same-octave instance lies above the reference,
    /// `.descending` if below, and `.same` if it is the reference (or enharmonically equivalent).
    ///
    /// For example, with A4 as the reference, every entry corresponds to a pitch in the range
    /// [C4, B4]. B maps to the ascending ratio to B4 — not to the nearer descending ratio to B3.
    /// This same-SPN-octave rule holds for all pitch classes, regardless of chromatic distance
    /// from the reference, and regardless of which pitch class is chosen as the reference.
    ///
    /// - Parameter standard: The reference pitch and its associated frequency.
    ///
    /// - Returns: A 35-entry dictionary, or `nil` if standard notation is not supported.
    func standardConversion(for standard: PitchStandard) -> [PitchClass: DirectedInterval<Ratio>]?
}

extension TuningSystem {

    /// The interval of equivalence of this tuning system. Defaults to `.octave`.
    public var equivalenceRatio: Ratio {
        .octave
    }

    /// Returns `nil` by default; override to support standard pitch notation.
    public func standardConversion(for standard: PitchStandard) -> [PitchClass: DirectedInterval<Ratio>]? {
        nil
    }
}
