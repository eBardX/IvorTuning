// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import Foundation
private import XestiNumbers

/// A tuning system that divides an interval of equivalence into equal logarithmic steps.
///
/// Standard pitch notation support depends on the configuration. ``standardConversion(for:)``
/// needs an octave (2:1) interval of equivalence, letters that ascend in pitch (so that E lies
/// below F), and a sharp that raises the pitch; 12-EDO, 19-EDO, and 31-EDO are fully supported.
/// Non-octave instances (e.g., ``bohlenPierce``, ``carlosAlpha``) cannot support standard
/// notation. Standard notation has only 35 pitch classes, so instances with more than 35
/// divisions (e.g., ``edo53``) cannot be fully represented: a conversion reaches only the steps
/// its spellings land on, and a work must stay within those. Some instances with fewer divisions
/// have the same limit, because their chain of fifths closes early (e.g., ``edo24``, whose
/// spellings land on only 12 pitches). Accidentals can also surprise: a sharp larger than a
/// diatonic semitone puts E♯ above F, and in 17-EDO and ``edo22`` it lands at least a whole
/// diatonic semitone above F.
public struct EqualTemperament {

    // MARK: Public Initializers

    /// Creates an equal temperament by dividing an interval of equivalence into a given
    /// number of equal steps.
    ///
    /// - Parameter divisions:         The number of equal divisions. Must be greater than 1.
    /// - Parameter equivalenceRatio:  The interval of equivalence to divide. Defaults to
    ///                                `.octave`.
    ///
    /// - Precondition: Both `divisions` and `equivalenceRatio` must be greater than 1.
    public init(divisions: UInt,
                equivalenceRatio: Ratio = .octave) {
        precondition(divisions > 1)
        precondition(equivalenceRatio > 1)

        self.divisions = divisions
        self.equivalenceRatio = equivalenceRatio
    }

    // MARK: Public Instance Properties

    /// The number of equal divisions within the interval of equivalence.
    public let divisions: UInt

    /// The interval of equivalence.
    public let equivalenceRatio: Ratio
}

// MARK: - TuningSystem

extension EqualTemperament: TuningSystem {

    // MARK: Public Instance Methods

    /// Returns the frequency ratio of the given step above the unison, within one period.
    ///
    /// Degree `d` is `d` equal steps above the unison, for `d` in `0..<divisions`.
    ///
    /// - Parameter degree: The degree, counted from 0 (the unison).
    ///
    /// - Returns:  The ratio of `degree` above the unison, or `nil` if `degree` is outside
    ///             `0..<divisions`.
    public func ratio(forDegree degree: Int) -> Ratio? {
        guard degree >= 0,
              UInt(degree) < divisions
        else { return nil }

        guard degree > 0
        else { return .unison }

        return equivalenceRatio.mul(UInt(degree), divisions)
    }

    public func standardConversion(for standard: PitchStandard) -> [PitchClass: DirectedInterval<Ratio>]? {
        guard equivalenceRatio == .octave
        else { return nil }

        let stepsPerFifth = Int((Double(divisions) * log2(1.5)).rounded())
        let stepsPerOctave = Int(divisions)

        // Ensure that sharps raise and flats lower pitch in standard notation:
        guard (stepsPerFifth * 7) - (stepsPerOctave * 4) > 0
        else { return nil }

        // Ensure that the letters ascend in pitch in standard notation, so that E lies below F:
        guard (stepsPerOctave * 3) - (stepsPerFifth * 5) > 0
        else { return nil }

        let fifthRatio = equivalenceRatio.div(divisions).mul(stepsPerFifth)

        return buildStandardConversion(for: standard,
                                       fifthRatio: fifthRatio)
    }
}
