public import XestiNumbers

public struct Ratio: NumberRepresentable {

    // MARK: Public Type Properties

    public static let octave: Self  = 2
    public static let tritave: Self = 3
    public static let unison: Self  = 1

    // MARK: Public Type Methods

    public static func isValid(_ numberValue: Number) -> Bool {
        numberValue.isRational && numberValue >= 1
    }

    // MARK: Public Initializers

    public init?(numberValue: Number) {
        guard Self.isValid(numberValue)
        else { return nil }

        self.numberValue = numberValue
    }

    // MARK: Public Instance Properties

    public let numberValue: Number
}

// MARK: -

extension Ratio {

    // MARK: Public Instance Methods

    public func divided(by factor: Number) -> Self? {
        Self(numberValue: exp(log(numberValue) / factor))
    }

    public func multiplied(by factor: Number) -> Self? {
        Self(numberValue: exp(log(numberValue) * factor))
    }
}

// MARK: - CustomStringConvertible

 extension Ratio: CustomStringConvertible {

     // MARK: Public Instance Properties

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

    public var isUnison: Bool {
        self == .unison
    }

    // MARK: Public Instance Methods

    public func adding(_ other: Self) -> Self? {
        Self(numberValue: numberValue * other.numberValue)
    }

    public func subtracting(_ other: Self) -> Self? {
        Self(numberValue: numberValue / other.numberValue)
    }
}
