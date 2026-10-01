// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

extension Ratio {

    // MARK: Public Nested Types

    /// A logarithmic unit for measuring the size of a ``Ratio``.
    ///
    /// Each unit divides some period ratio into a fixed number of equal steps: cents divide the
    /// octave (2:1) into 1200, millioctaves divide the octave into 1000, savarts divide the decade
    /// (10:1) into 1000, and hekts divide the tritave (3:1) into 1300.
    public enum Unit {

        /// Hundredths of an equal-tempered semitone; 1200 to the octave.
        case cents

        /// Hundredths of an equal-tempered Bohlen–Pierce step; 1300 to the tritave.
        case hekts

        /// Thousandths of an octave.
        case millioctaves

        /// Thousandths of a decade; about 301 to the octave.
        case savarts
    }
}

// MARK: -

extension Ratio.Unit {

    // MARK: Public Instance Properties

    /// The number of equal steps this unit divides its ``period`` into.
    public var divisions: Number {
        switch self {
        case .cents:
            1_200

        case .hekts:
            1_300

        case .millioctaves,
             .savarts:
            1_000
        }
    }

    /// The ratio this unit divides into ``divisions`` equal steps.
    public var period: Ratio {
        switch self {
        case .cents,
             .millioctaves:
            .octave

        case .hekts:
            .tritave

        case .savarts:
            10
        }
    }

    // MARK: Internal Instance Methods

    internal func ratio(for value: Number) -> Ratio? {
        Ratio(numberValue: exp(value * logPeriod / divisions))
    }

    internal func value(of ratio: Ratio) -> Number {
        log(ratio.numberValue) * divisions / logPeriod
    }

    // MARK: Private Type Properties

    private static let logDecade = log(Number(10))
    private static let logOctave = log(Number(2))
    private static let logTritave = log(Number(3))

    // MARK: Private Instance Properties

    private var logPeriod: Number {
        switch self {
        case .cents,
             .millioctaves:
            Self.logOctave

        case .hekts:
            Self.logTritave

        case .savarts:
            Self.logDecade
        }
    }
}

// MARK: - CaseIterable

extension Ratio.Unit: CaseIterable {
}

// MARK: - Codable

extension Ratio.Unit: Codable {
}

// MARK: - Hashable

extension Ratio.Unit: Hashable {
}

// MARK: - Sendable

extension Ratio.Unit: Sendable {
}
