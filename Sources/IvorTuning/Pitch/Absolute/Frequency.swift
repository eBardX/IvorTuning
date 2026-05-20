// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

/// A positive rational frequency value representing an absolute pitch.
public struct Frequency: NumberRepresentable {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the given number is a valid frequency.
    ///
    /// - Parameter numberValue:    The number to validate.
    ///
    /// - Returns:  `true` if `numberValue` is rational and positive; otherwise, `false`.
    public static func isValid(_ numberValue: Number) -> Bool {
        numberValue.isRational && numberValue.isPositive
    }

    // MARK: Public Initializers

    /// Creates a frequency from a number value.
    ///
    /// - Parameter numberValue:    A rational, positive number representing the frequency in hertz.
    ///
    /// - Returns:  `nil` if `numberValue` is not rational or not positive.
    public init?(numberValue: Number) {
        guard Self.isValid(numberValue)
        else { return nil }

        self.numberValue = numberValue
    }

    // MARK: Public Instance Properties

    /// The numeric value of this frequency.
    public let numberValue: Number
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
            return DirectedInterval(interval: Ratio(val2 / val1), direction: .ascending)
        }

        if val1 > val2 {
            return DirectedInterval(interval: Ratio(val1 / val2), direction: .descending)
        }

        return DirectedInterval(interval: .unison, direction: .same)
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
