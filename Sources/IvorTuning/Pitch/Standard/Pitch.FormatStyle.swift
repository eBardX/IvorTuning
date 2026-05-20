// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

extension Pitch {

    // MARK: Public Nested Types

    /// A format style that produces an attributed string representation of a ``Pitch``.
    public struct FormatStyle {

        // MARK: Public Initializers

        /// Creates a format style with the given locale.
        ///
        /// - Parameter locale: The locale to use for formatting. Defaults to
        ///                     `.autoupdatingCurrent`.
        public init(locale: Locale = .autoupdatingCurrent) {
            self.locale = locale
        }

        // MARK: Public Instance Properties

        /// The locale used for formatting.
        public let locale: Locale
    }
}

// MARK: - FormatStyle

extension Pitch.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of the given pitch, omitting the natural accidental.
    ///
    /// - Parameter value:  The pitch to format.
    ///
    /// - Returns:  An attributed string representation of `value`.
    public func format(_ value: Pitch) -> AttributedString {
        AttributedString(value.stringValue(omitNatural: true))
    }
}

// MARK: -

extension Pitch {

    /// Returns an attributed string representation of this pitch.
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
