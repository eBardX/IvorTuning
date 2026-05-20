// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers
public import XestiTools

/// A distance between MIDI note numbers, in the range `0...127`.
public struct NoteDistance: UIntRepresentable {

    // MARK: Public Type Properties

    /// The zero note distance, representing a unison.
    public static let unison: Self = 0

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the given unsigned integer is a valid note distance.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if `uintValue` is in the range `0...127`; otherwise, `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...127) ~= uintValue
    }

    // MARK: Public Initializers

    /// Creates a note distance from an unsigned integer value.
    ///
    /// - Parameter uintValue:  A MIDI semitone distance in the range `0...127`.
    ///
    /// - Returns:  `nil` if `uintValue` is outside the valid range.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The unsigned integer value of this note distance.
    public let uintValue: UInt
}

// MARK: -

extension NoteDistance {

    // MARK: Public Instance Properties

    /// The double-precision floating-point value of this note distance.
    public var doubleValue: Double {
        Double(uintValue)
    }

    /// The number value of this note distance.
    public var numberValue: Number {
        Number(uintValue)
    }
}

// MARK: - IntervalProtocol

extension NoteDistance: IntervalProtocol {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this note distance is zero.
    public var isUnison: Bool {
        self == .unison
    }

    // MARK: Public Instance Methods

    /// Returns the sum of this note distance and another note distance.
    ///
    /// - Parameter other:  The note distance to add.
    ///
    /// - Returns:  The combined note distance, or `nil` if the result is out of range.
    public func adding(_ other: Self) -> Self? {
        Self(uintValue: uintValue + other.uintValue)
    }

    /// Returns the difference between this note distance and another note distance.
    ///
    /// - Parameter other:  The note distance to subtract.
    ///
    /// - Returns:  The resulting note distance, or `nil` if the result is out of range.
    public func subtracting(_ other: Self) -> Self? {
        Self(uintValue: uintValue - other.uintValue)
    }
}
