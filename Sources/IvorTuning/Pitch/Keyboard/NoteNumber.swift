// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers
public import XestiTools

private import Foundation

/// A MIDI note number in the range `0...127`.
public struct NoteNumber: UIntRepresentable {

    // MARK: Public Initializers

    /// Creates a note number by parsing its plain string representation, returning `nil` if the
    /// string cannot be parsed or is out of range.
    ///
    /// - Parameter plain:  The plain string representation of the note number (as produced by
    ///                     `plain`).
    public init?(plain: String) {
        guard let numberValue = try? Self.plainParseStrategy.parse(plain),
              numberValue.isExact,
              numberValue.isInteger,
              !numberValue.isNegative
        else { return nil }

        self.init(uintValue: numberValue.uintValue)
    }

    /// Creates a note number from an unsigned integer value.
    ///
    /// - Parameter uintValue:  A MIDI note number in the range `0...127`.
    ///
    /// - Returns:  `nil` if `uintValue` is outside the valid range.
    public init?(uintValue: UInt) {
        guard Self.isValid(uintValue)
        else { return nil }

        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The unsigned integer value of this note number.
    public let uintValue: UInt
}

// MARK: -

extension NoteNumber {

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the given unsigned integer is a valid note number.
    ///
    /// - Parameter uintValue:  The value to validate.
    ///
    /// - Returns:  `true` if `uintValue` is in the range `0...127`; otherwise, `false`.
    public static func isValid(_ uintValue: UInt) -> Bool {
        (0...127) ~= uintValue
    }

    // MARK: Public Instance Properties

    /// The double-precision floating-point value of this note number.
    public var doubleValue: Double {
        Double(uintValue)
    }

    /// The number value of this note number.
    public var numberValue: Number {
        Number(uintValue)
    }

    /// The plain string representation of this note number.
    public var plain: String {
        Self.plainFormatStyle.format(numberValue)
    }

    // MARK: Private Type Properties

    private static let plainFormatStyle = Number.FormatStyle(locale: plainLocale)
        .decimalPrecision(0)
        .fractionDisplay(strategy: .simple(alwaysShowDenominator: false))
        .grouping(false)

    private static let plainLocale = Locale(identifier: "en_US_POSIX")

    private static let plainParseStrategy = plainFormatStyle.parseStrategy
}

// MARK: - PitchProtocol

extension NoteNumber: PitchProtocol {

    // MARK: Public Instance Methods

    /// Returns the directed interval from this note number to another.
    ///
    /// - Parameter pitch:  The target note number.
    ///
    /// - Returns:  The directed interval, containing the note distance and direction.
    public func interval(to pitch: Self) -> DirectedInterval<NoteDistance>? {
        let val1 = uintValue
        let val2 = pitch.uintValue

        if val1 < val2 {
            return DirectedInterval(interval: NoteDistance(val2 - val1),
                                    direction: .ascending)
        }

        if val1 > val2 {
            return DirectedInterval(interval: NoteDistance(val1 - val2),
                                    direction: .descending)
        }

        return DirectedInterval(interval: .unison,
                                direction: .same)
    }

    /// Returns this note number transposed by the given directed interval.
    ///
    /// - Parameter directedInterval:   The directed interval to transpose by.
    ///
    /// - Returns:  The transposed note number, or `nil` if the result is out of range.
    public func transposed(by directedInterval: DirectedInterval<NoteDistance>) -> Self? {
        switch directedInterval.direction {
        case .ascending:
            Self(uintValue: uintValue + directedInterval.interval.uintValue)

        case .descending:
            uintValue >= directedInterval.interval.uintValue
                ? Self(uintValue: uintValue - directedInterval.interval.uintValue)
                : nil

        case .same:
            self
        }
    }
}
