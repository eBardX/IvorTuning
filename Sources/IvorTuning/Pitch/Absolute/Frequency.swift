// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers
public import XestiTools

private import Foundation

/// A positive frequency value representing an absolute pitch, measured in microhertz.
public struct Frequency {

    // MARK: Public Initializers

    /// Creates a frequency from a number value.
    ///
    /// - Parameter numberValue:    A positive number representing the frequency in hertz.
    public init(_ numberValue: Number) {
        self.init(numberValue: numberValue)!    // swiftlint:disable:this force_unwrapping
    }

    /// Creates a frequency from a number value.
    ///
    /// - Parameter numberValue:    A positive number representing the frequency in hertz.
    ///
    /// - Returns:  `nil` if `numberValue` is not positive.
    public init?(numberValue: Number) {
        guard numberValue.isPositive,
              let value = UInt(exactly: (numberValue.doubleValue * 1_000_000).rounded())
        else { return nil }

        self.init(uintValue: value)
    }

    /// Creates a frequency by parsing its plain string representation, returning `nil` if the
    /// string cannot be parsed or is out of range.
    ///
    /// - Parameter plain:  The plain string representation of the frequency, in hertz (as
    ///                     produced by `plain`).
    public init?(plain: String) {
        guard let numberValue = try? Self.plainParseStrategy.parse(plain)
        else { return nil }

        self.init(numberValue: numberValue)
    }

    /// Creates a ``Frequency`` from a microhertz count.
    ///
    /// - Parameter uintValue:  The number of microhertz.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The number of microhertz representing this frequency.
    public let uintValue: UInt
}

// MARK: -

extension Frequency {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the given microhertz count is a valid
    /// frequency.
    ///
    /// - Parameter uintValue:  The microhertz count to validate.
    ///
    /// - Returns:  `true` if `uintValue` is positive; otherwise, `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        uintValue > 0
    }

    // MARK: Public Instance Properties

    /// The number of hertz representing this frequency.
    public var doubleValue: Double {
        Double(uintValue) / 1_000_000
    }

    /// The numeric value of this frequency, in hertz.
    ///
    /// This value is always an exact rational number, since it is derived from an exact
    /// microhertz count rather than a floating-point approximation.
    public var numberValue: Number {
        Number(uintValue) / Self.microhertzPerHertz
    }

    /// The plain string representation of this frequency, in hertz.
    public var plain: String {
        Self.plainFormatStyle.format(numberValue)
    }

    // MARK: Private Type Properties

    // The number of microhertz per hertz, as an exact `Number` for use in exact rational
    // arithmetic (avoiding any `Double` conversion).
    private static let microhertzPerHertz = Number(1_000_000)

    private static let plainFormatStyle = Number.FormatStyle(locale: plainLocale)
        .decimalPrecision(0...6)
        .fractionDisplay(strategy: .decimal)
        .grouping(false)

    private static let plainLocale = Locale(identifier: "en_US_POSIX")

    private static let plainParseStrategy = plainFormatStyle.parseStrategy
}

// MARK: - CustomStringConvertible

extension Frequency {

    // MARK: Public Instance Properties

    public var description: String {
        String(describing: numberValue)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Frequency: ExpressibleByIntegerLiteral {

    // MARK: Public Initializers

    /// Creates a frequency from an integer literal, interpreted as a whole number of hertz.
    ///
    /// - Parameter value:  The number of hertz.
    public init(integerLiteral value: UInt) {
        self.init(numberValue: Number(value))!    // swiftlint:disable:this force_unwrapping
    }
}

// MARK: - PitchProtocol

extension Frequency: PitchProtocol {

    // MARK: Public Instance Methods

    /// Returns the directed interval from this frequency to another frequency.
    ///
    /// - Parameter pitch:  The target frequency.
    ///
    /// - Returns:  The directed interval, containing the frequency ratio and direction.
    public func interval(to pitch: Self) -> DirectedInterval<Ratio>? {
        let val1 = numberValue
        let val2 = pitch.numberValue

        if val1 < val2 {
            return DirectedInterval(interval: Ratio(val2 / val1),
                                    direction: .ascending)
        }

        if val1 > val2 {
            return DirectedInterval(interval: Ratio(val1 / val2),
                                    direction: .descending)
        }

        return DirectedInterval(interval: .unison,
                                direction: .same)
    }

    /// Returns this frequency transposed by the given directed interval.
    ///
    /// - Parameter directedInterval:   The directed interval to transpose by.
    ///
    /// - Returns:  The transposed frequency, or `nil` if the result is out of range.
    public func transposed(by directedInterval: DirectedInterval<Ratio>) -> Self? {
        switch directedInterval.direction {
        case .ascending:
            Self(numberValue: numberValue * directedInterval.interval.numberValue)

        case .descending:
            Self(numberValue: numberValue / directedInterval.interval.numberValue)

        case .same:
            self
        }
    }
}

// MARK: - UIntRepresentable

extension Frequency: UIntRepresentable {
}
