public import Foundation

extension Interval {

    // MARK: Public Nested Types

    public struct FormatStyle {

        // MARK: Public Initializers

        public init(locale: Locale = .autoupdatingCurrent) {
            self.locale = locale
        }

        // MARK: Public Instance Properties

        public let locale: Locale
    }
}

// MARK: - FormatStyle

extension Interval.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    public func format(_ value: Interval) -> AttributedString {
        AttributedString(value.description)
    }
}

// MARK: -

extension Interval {
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
