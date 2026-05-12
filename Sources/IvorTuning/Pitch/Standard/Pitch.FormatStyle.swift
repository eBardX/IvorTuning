public import Foundation

extension Pitch {

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

extension Pitch.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    public func format(_ value: Pitch) -> AttributedString {
        AttributedString(value.description(omitNatural: true))
    }
}

// MARK: -

extension Pitch {
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
