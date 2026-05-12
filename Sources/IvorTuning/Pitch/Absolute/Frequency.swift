public import XestiNumbers

public struct Frequency: NumberRepresentable {

    // MARK: Public Type Methods

    public static func isValid(_ numberValue: Number) -> Bool {
        numberValue.isRational && numberValue.isPositive
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

// MARK: - PitchProtocol

extension Frequency: PitchProtocol {

    // MARK: Public Type Properties

    public static let `default`: Self = 1

    // MARK: Public Instance Methods

    public func interval(to pitch: Self) -> (interval: Ratio,
                                             direction: IntervalDirection)? {
        let val1 = numberValue
        let val2 = pitch.numberValue

        if val1 < val2 {
            return (Ratio(val2 / val1), .ascending)
        }

        if val1 > val2 {
            return (Ratio(val1 / val2), .descending)
        }

        return (.unison, .same)
    }

    public func transposed(by interval: Ratio,
                           direction: IntervalDirection) -> Self? {
        switch direction {
        case .ascending:
            return Self(numberValue: numberValue * interval.numberValue)

        case .descending:
            return Self(numberValue: numberValue / interval.numberValue)

        case .same:
            guard interval == .unison
            else { return nil }

            return self
        }
    }
}
