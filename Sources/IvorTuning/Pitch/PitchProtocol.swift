// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

/// A type that represents a musical pitch with an associated interval type.
public protocol PitchProtocol<IntervalType>: Codable,
                                             Comparable,
                                             Hashable,
                                             Sendable {
    associatedtype IntervalType: IntervalProtocol

    /// Returns the directed interval from this pitch to another pitch.
    ///
    /// - Parameter pitch:  The target pitch.
    ///
    /// - Returns:  The directed interval from this pitch to `pitch`, or `nil` if the
    ///             interval cannot be determined.
    func interval(to pitch: Self) -> DirectedInterval<IntervalType>?

    /// Returns this pitch transposed by the given directed interval.
    ///
    /// - Parameter directedInterval:   The directed interval to transpose by.
    ///
    /// - Returns:  The transposed pitch, or `nil` if the result is out of range.
    func transposed(by directedInterval: DirectedInterval<IntervalType>) -> Self?
}

// MARK: -

extension PitchProtocol {

    /// Returns an attributed string representation of this pitch.
    public func formatted() -> AttributedString {
        switch self {
        case let value as Frequency:
            value.formatted()

        case let value as NoteNumber:
            value.formatted()

        case let value as Pitch:
            value.formatted()

        default:
            AttributedString("\(self)")
        }
    }
}
