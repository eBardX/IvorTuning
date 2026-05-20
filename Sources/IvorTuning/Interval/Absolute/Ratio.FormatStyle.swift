// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiNumbers

extension Ratio {

    // MARK: Public Nested Types

    /// A format style that produces an attributed string representation of a ``Ratio``.
    public struct FormatStyle {

        // MARK: Public Initializers

        /// Creates a format style with the given locale.
        ///
        /// - Parameter locale: The locale to use for formatting. Defaults to
        ///                     `.autoupdatingCurrent`.
        public init(locale: Locale = .autoupdatingCurrent) {
            self.baseStyle = Number.FormatStyle(locale: locale)
                .decimalPrecision(0...3)
                .fractionDisplay(strategy: .simple(alwaysShowDenominator: true))
                .attributed
            self.locale = locale
        }

        // MARK: Public Instance Properties

        /// The locale used for formatting.
        public let locale: Locale

        // MARK: Private Instance Properties

        private let baseStyle: Number.FormatStyle.Attributed
    }
}

// MARK: - FormatStyle

extension Ratio.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of the given ratio.
    ///
    /// - Parameter value:  The ratio to format.
    ///
    /// - Returns:  An attributed string representation of `value`.
    public func format(_ value: Ratio) -> AttributedString {
        baseStyle.format(value.numberValue)
    }
}

// MARK: -

extension Ratio {

    /// Returns an attributed string representation of this ratio.
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
