// © 2026 John Gary Pusey (see LICENSE.md)

public import Foundation

extension Key {

    // MARK: Public Nested Types

    /// A format style that produces an attributed string representation of a ``Key``: its full
    /// name, in English.
    ///
    /// A diatonic key with a mode is named by its tonic and mode (`"F♯ minor"`). A diatonic key
    /// with no mode and a custom key are named by their accidentals (`"F♯ C♯ G♯"`, `"B♭ F♯"`), or
    /// `"(no accidentals)"` for a diatonic key with none. An atonal key is `"Atonal"`.
    public struct FormatStyle {

        // MARK: Public Initializers

        /// Creates a format style with the given options and locale.
        ///
        /// - Parameter ascii:  When `true`, accidentals are rendered using their ASCII
        ///                     representations (`"F# minor"`, `"Bb F#"`) instead of their
        ///                     Unicode symbols. Defaults to `false`.
        /// - Parameter locale: The locale to use for formatting. Defaults to
        ///                     `.autoupdatingCurrent`.
        public init(ascii: Bool = false,
                    locale: Locale = .autoupdatingCurrent) {
            self.ascii = ascii
            self.locale = locale
        }

        // MARK: Public Instance Properties

        /// Whether accidentals are rendered using their ASCII representations.
        public let ascii: Bool

        /// The locale used for formatting.
        public let locale: Locale
    }
}

// MARK: - FormatStyle

extension Key.FormatStyle: FormatStyle {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of the given key: its full name.
    ///
    /// - Parameter value:  The key to format.
    ///
    /// - Returns:  An attributed string representation of `value`.
    public func format(_ value: Key) -> AttributedString {
        AttributedString(value.name(ascii: ascii))
    }
}

// MARK: -

extension Key {

    // MARK: Public Instance Methods

    /// Returns an attributed string representation of this key, using the given format style.
    ///
    /// - Parameter style:  The format style to use. Defaults to a style with Unicode
    ///                     accidentals.
    ///
    /// - Returns:  The full name of this key.
    public func formatted(_ style: FormatStyle = FormatStyle()) -> AttributedString {
        style.format(self)
    }
}
