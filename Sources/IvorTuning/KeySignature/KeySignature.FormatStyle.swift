// © 2026 John Gary Pusey (see LICENSE.md)

public import Foundation

extension KeySignature {

    // MARK: Public Nested Types

    /// A format style that produces an attributed string representation of a ``KeySignature``.
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

extension KeySignature.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of the given key signature, in its short form
    /// (see ``KeySignature/stringValue(ascii:)``).
    ///
    /// - Parameter value:  The key signature to format.
    ///
    /// - Returns:  An attributed string representation of `value`.
    public func format(_ value: KeySignature) -> AttributedString {
        AttributedString(value.stringValue())
    }
}

// MARK: -

extension KeySignature {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of this key signature.
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
