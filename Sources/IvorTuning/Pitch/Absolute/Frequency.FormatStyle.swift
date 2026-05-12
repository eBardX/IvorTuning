public import Foundation

private import XestiNumbers

extension Frequency {

    // MARK: Public Nested Types

    public struct FormatStyle {

        // MARK: Public Initializers

        public init(locale: Locale = .autoupdatingCurrent) {
            self.baseStyle = Number.FormatStyle(locale: locale)
                .decimalPrecision(0...3)
                .fractionDisplay(strategy: .decimal)
                .attributed
            self.locale = locale
        }

        // MARK: Public Instance Properties

        public let locale: Locale

        // MARK: Private Instance Properties

        private let baseStyle: Number.FormatStyle.Attributed
    }
}

// MARK: - FormatStyle

extension Frequency.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    public func format(_ value: Frequency) -> AttributedString {
        baseStyle.format(value.numberValue)
    }
}

// MARK: -

extension Frequency {
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
