// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import Foundation

extension Interval {

    // MARK: Public Nested Types

    /// A format style that produces an attributed string representation of an ``Interval``.
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

extension Interval.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of the given interval.
    ///
    /// - Parameter value:  The interval to format.
    ///
    /// - Returns:  An attributed string representation of `value`.
    public func format(_ value: Interval) -> AttributedString {
        AttributedString(value.description)
    }
}

// MARK: -

extension Interval {

    /// Returns an attributed string representation of this interval.
    public func formatted() -> AttributedString {
        FormatStyle().format(self)
    }
}
