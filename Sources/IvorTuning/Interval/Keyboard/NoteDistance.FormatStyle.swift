// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiNumbers

extension NoteDistance {

    // MARK: Public Nested Types

    /// A format style that produces an attributed string representation of a ``NoteDistance``.
    public struct FormatStyle {

        // MARK: Public Initializers

        /// Creates a format style with the given locale.
        ///
        /// - Parameter locale: The locale to use for formatting. Defaults to
        ///                     `.autoupdatingCurrent`.
        public init(locale: Locale = .autoupdatingCurrent) {
            self.baseStyle = Number.FormatStyle(locale: locale)
                .decimalPrecision(0)
                .fractionDisplay(strategy: .simple(alwaysShowDenominator: false))
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

extension NoteDistance.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of the given note distance.
    ///
    /// - Parameter value:  The note distance to format.
    ///
    /// - Returns:  An attributed string representation of `value`.
    public func format(_ value: NoteDistance) -> AttributedString {
        baseStyle.format(value.numberValue)
    }
}

// MARK: -

extension NoteDistance {

    /// Returns an attributed string representation of this note distance.
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
