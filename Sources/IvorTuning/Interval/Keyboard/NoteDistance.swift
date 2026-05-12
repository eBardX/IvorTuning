public import XestiNumbers
public import XestiTools

public struct NoteDistance: UIntRepresentable {

    // MARK: Public Type Properties

    public static let unison: Self = 0

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

extension NoteDistance {

    // MARK: Public Instance Properties

    public var doubleValue: Double {
        Double(uintValue)
    }

    public var numberValue: Number {
        Number(uintValue)
    }
}

// MARK: - IntervalProtocol

extension NoteDistance: IntervalProtocol {

    // MARK: Public Instance Properties

    public var isUnison: Bool {
        self == .unison
    }

    // MARK: Public Instance Methods

    public func adding(_ other: Self) -> Self? {
        Self(uintValue: uintValue + other.uintValue)
    }

    public func subtracting(_ other: Self) -> Self? {
        Self(uintValue: uintValue - other.uintValue)
    }
}
