// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

/// A type that represents a musical interval between two pitches.
public protocol IntervalProtocol: Codable,
                                  Hashable,
                                  Sendable {

    /// A Boolean value indicating whether this interval is a unison.
    var isUnison: Bool { get }

    /// Returns the sum of this interval and another interval of the same type.
    ///
    /// - Parameter other:  The interval to add.
    ///
    /// - Returns:  The combined interval, or `nil` if the result is out of range.
    func adding(_ other: Self) -> Self?

    /// Returns the difference between this interval and another interval of the same type.
    ///
    /// - Parameter other:  The interval to subtract.
    ///
    /// - Returns:  The resulting interval, or `nil` if the result is out of range.
    func subtracting(_ other: Self) -> Self?
}

// MARK: -

extension IntervalProtocol {

    /// Returns an attributed string representation of this interval.
    public func formatted() -> AttributedString {
        switch self {
        case let value as Interval:
            value.formatted()

        case let value as NoteDistance:
            value.formatted()

        case let value as Ratio:
            value.formatted()

        default:
            AttributedString("\(self)")
        }
    }
}
