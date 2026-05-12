public import Foundation

public protocol PitchProtocol<IntervalType>: Codable,
                                             Comparable,
                                             Hashable,
                                             Sendable {
    associatedtype IntervalType: IntervalProtocol

    static var `default`: Self { get }

    func interval(to pitch: Self) -> (interval: IntervalType,
                                      direction: IntervalDirection)?

    func transposed(by interval: IntervalType,
                    direction: IntervalDirection) -> Self?
}

// MARK: -

extension PitchProtocol {
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
