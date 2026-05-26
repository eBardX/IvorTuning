// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import Foundation
private import XestiNumbers

/// A tuning system that divides an interval of equivalence into equal logarithmic steps.
///
/// Standard pitch notation support depends on the configuration. Instances with an octave (2:1)
/// interval of equivalence and at most 35 divisions may support ``standardConversion(for:)``;
/// 12-EDO, 19-EDO, and 31-EDO are fully supported. Non-octave instances (e.g., ``bohlenPierce``,
/// ``carlosAlpha``) cannot support standard notation. Instances with more than 35 divisions
/// (e.g., ``edo53``) cannot be fully represented. Other octave instances (e.g., ``edo22``,
/// ``edo24``) may produce unexpected results.
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
    public func standardConversion(for standard: PitchStandard) -> [PitchClass: DirectedInterval<Ratio>]? {
        guard equivalenceRatio == .octave
        else { return nil }

        let stepsPerFifth = Int((Double(divisions) * log2(1.5)).rounded())
        let stepsPerOctave = Int(divisions)

        // Ensure that sharps raise and flats lower pitch in standard notation:
        guard (stepsPerFifth * 7) - (stepsPerOctave * 4) > 0
        else { return nil }

        let fifthRatio = equivalenceRatio.div(divisions).mul(stepsPerFifth)

        return buildStandardConversion(for: standard,
                                       fifthRatio: fifthRatio)
    }
}

// MARK: - Sendable

extension EqualTemperament: Sendable {
}
