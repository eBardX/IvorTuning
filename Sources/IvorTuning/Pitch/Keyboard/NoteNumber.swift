public import XestiNumbers
public import XestiTools

public struct NoteNumber: UIntRepresentable {

    // MARK: Public Type Methods

    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...127) ~= uintValue
    }

    // MARK: Public Initializers

    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    public let uintValue: UInt
}

// MARK: -

extension NoteNumber {

    // MARK: Public Instance Properties

    public var doubleValue: Double {
        Double(uintValue)
    }

    public var numberValue: Number {
        Number(uintValue)
    }
}

// MARK: - PitchProtocol

extension NoteNumber: PitchProtocol {

    // MARK: Public Type Methods

    public static let `default`: Self = 0

    // MARK: Public Instance Methods

    public func interval(to pitch: Self) -> (interval: NoteDistance,
                                             direction: IntervalDirection)? {
        let val1 = uintValue
        let val2 = pitch.uintValue

        if val1 < val2 {
            return (NoteDistance(val2 - val1), .ascending)
        }

        if val1 > val2 {
            return (NoteDistance(val1 - val2), .descending)
        }

        return (.unison, .same)
    }

    public func transposed(by interval: NoteDistance,
                           direction: IntervalDirection) -> Self? {
        switch direction {
        case .ascending:
            return Self(uintValue: uintValue + interval.uintValue)

        case .descending:
            return Self(uintValue: uintValue - interval.uintValue)

        case .same:
            guard interval == .unison
            else { return nil }

            return self
        }
    }
}
