// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

private import XestiTools

/// A frequency ratio representing a musical interval.
public struct Ratio: NumberRepresentable {

    // MARK: Public Type Properties

    /// The octave ratio (2:1).
    public static let octave: Self = 2

    /// The tritave ratio (3:1).
    public static let tritave: Self = 3

    /// The unison ratio (1:1).
    public static let unison: Self = 1

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the given number is a valid ratio.
    ///
    /// - Parameter numberValue:    The number to validate.
    ///
    /// - Returns:  `true` if `numberValue` is rational and at least 1; otherwise, `false`.
    public static func isValid(_ numberValue: Number) -> Bool {
        numberValue.isRational && numberValue >= 1
    }

    // MARK: Public Initializers

    /// Creates a ratio from a number value.
    ///
    /// - Parameter numberValue:    A rational number greater than or equal to 1.
    ///
    /// - Returns:  `nil` if `numberValue` is not rational or is less than 1.
    public init?(numberValue: Number) {
        guard Self.isValid(numberValue)
        else { return nil }

        self.numberValue = numberValue
    }

    // MARK: Public Instance Properties

    /// The numeric value of this ratio.
    public let numberValue: Number
}

// MARK: -

extension Ratio {

    // MARK: Public Instance Methods

    /// Returns this ratio divided by the given factor.
    ///
    /// - Parameter factor: The factor to divide by.
    ///
    /// - Returns:  The resulting ratio, or `nil` if the result is less than 1.
    public func divided(by factor: Number) -> Self? {
        Self(numberValue: exp(log(numberValue) / factor))
    }

    /// Returns this ratio multiplied by the given factor.
    ///
    /// - Parameter factor: The factor to multiply by.
    ///
    /// - Returns:  The resulting ratio, or `nil` if the result is less than 1.
    public func multiplied(by factor: Number) -> Self? {
        Self(numberValue: exp(log(numberValue) * factor))
    }

    // MARK: Internal Initializers

    internal init<T: BinaryInteger>(_ numerator: T,
                                    _ denominator: T) {
        self.init(Number(numerator: numerator,
                         denominator: denominator))
    }

    // MARK: Internal Instance Methods

    internal func add(_ other: Self) -> Self {
        adding(other).require()
    }

    internal func div(_ factor: Number) -> Self {
        divided(by: factor).require()
    }

    internal func div<T: BinaryInteger>(_ nfactor: T,
                                        _ dfactor: T = 1) -> Self {
        div(Number(numerator: nfactor,
                   denominator: dfactor))
    }

    internal func mul(_ factor: Number) -> Self {
        multiplied(by: factor).require()
    }

    internal func mul<T: BinaryInteger>(_ nfactor: T,
                                        _ dfactor: T = 1) -> Self {
        mul(Number(numerator: nfactor,
                   denominator: dfactor))
    }

    internal func sub(_ other: Self) -> Self {
        subtracting(other).require()
    }
}

// MARK: - CustomStringConvertible

 extension Ratio: CustomStringConvertible {

     // MARK: Public Instance Properties

     /// The string representation of this ratio.
     public var description: String {
        if numberValue.isExact {
            numberValue.numerator.description + "/" + numberValue.denominator.description
        } else {
            doubleValue.description
        }
    }
 }

// MARK: - IntervalProtocol

extension Ratio: IntervalProtocol {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this ratio represents a unison (1:1).
    public var isUnison: Bool {
        self == .unison
    }

    // MARK: Public Instance Methods

    /// Returns the product of this ratio and another ratio.
    ///
    /// - Parameter other:  The ratio to add.
    ///
    /// - Returns:  The combined ratio, or `nil` if the result is less than 1.
    public func adding(_ other: Self) -> Self? {
        Self(numberValue: numberValue * other.numberValue)
    }

    /// Returns the quotient of this ratio and another ratio.
    ///
    /// - Parameter other:  The ratio to subtract.
    ///
    /// - Returns:  The resulting ratio, or `nil` if the result is less than 1.
    public func subtracting(_ other: Self) -> Self? {
        Self(numberValue: numberValue / other.numberValue)
    }
}
