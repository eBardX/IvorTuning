public import Foundation

public protocol IntervalProtocol: Codable,
                                  Hashable,
                                  Sendable {
    var isUnison: Bool { get }

    func adding(_ other: Self) -> Self?

    func subtracting(_ other: Self) -> Self?
}

// MARK: -

extension IntervalProtocol {
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
