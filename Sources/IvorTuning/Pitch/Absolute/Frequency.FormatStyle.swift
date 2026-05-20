// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiNumbers

extension Frequency {

    // MARK: Public Nested Types

    /// A format style that produces an attributed string representation of a ``Frequency``.
    public struct FormatStyle {

        // MARK: Public Initializers

        /// Creates a format style with the given locale.
        ///
        /// - Parameter locale: The locale to use for formatting. Defaults to
        ///                     `.autoupdatingCurrent`.
        public init(locale: Locale = .autoupdatingCurrent) {
            self.baseStyle = Number.FormatStyle(locale: locale)
                .decimalPrecision(0...3)
                .fractionDisplay(strategy: .decimal)
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

extension Frequency.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of the given frequency.
    ///
    /// - Parameter value:  The frequency to format.
    ///
    /// - Returns:  An attributed string representation of `value`.
    public func format(_ value: Frequency) -> AttributedString {
        baseStyle.format(value.numberValue)
    }
}

// MARK: -

extension Frequency {

    /// Returns an attributed string representation of this frequency.
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
