// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

private import XestiTools

/// A tuning system that divides a period into equal logarithmic steps.
public struct EqualTemperament {

    // MARK: Public Initializers

    /// Creates an equal temperament by dividing a period into a given number of
    /// equal steps.
    ///
    /// - Parameter divisions:  The number of equal divisions within the period.
    ///                         Must be greater than 1.
    /// - Parameter period:     The interval to divide. Defaults to `.octave`.
    ///
    /// - Precondition: Both `divisions` and `period` must be greater than 1.
    public init(divisions: Number,
                period: Ratio = .octave) {
        precondition(divisions > 1)
        precondition(period > 1)

        self.divisions = divisions
        self.period = period
        self.stepSize = period.divided(by: divisions).require() // for now
    }

    /// Creates an equal temperament defined by a specific step size.
    ///
    /// - Parameter stepSize:   The size of each equal step as a frequency
    ///                         ratio.
    public init(stepSize: Ratio) {
        self.divisions = nil
        self.period = nil
        self.stepSize = stepSize
    }

    // MARK: Public Instance Properties

    /// The number of equal divisions within the period, or `nil` if defined by
    /// step size only.
    public let divisions: Number?

    /// The period interval, or `nil` if defined by step size only.
    public let period: Ratio?

    /// The size of each equal step as a frequency ratio.
    public let stepSize: Ratio
}

// MARK: - TuningSystem

extension EqualTemperament: TuningSystem {
}

// MARK: - Sendable

extension EqualTemperament: Sendable {
}
