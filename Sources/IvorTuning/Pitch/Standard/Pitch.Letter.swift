// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension Pitch {

    // MARK: Public Nested Types

    /// A diatonic letter name for a pitch.
    public enum Letter {

        /// The pitch letter A.
        case a

        /// The pitch letter B.
        case b

        /// The pitch letter C.
        case c

        /// The pitch letter D.
        case d

        /// The pitch letter E.
        case e

        /// The pitch letter F.
        case f

        /// The pitch letter G.
        case g

        // MARK: Public Initializers

        /// Creates a pitch letter from its string representation.
        ///
        /// - Parameter stringValue:    The uppercase letter string (e.g., `"C"`).
        ///
        /// - Throws:   `ParseError` if `stringValue` does not match a known pitch letter.
        public init(stringValue: String) throws(ParseError) {
            guard let letter = Self.letters[stringValue]
            else { throw ParseError.invalidPitchLetter(stringValue) }

            self = letter
        }
    }
}

// MARK: -

extension Pitch.Letter {

    // MARK: Public Instance Properties

    /// The diatonic order of this pitch letter, where C is 1 and B is 7.
    public var order: Int {
        switch self {
        case .a:
            6

        case .b:
            7

        case .c:
            1

        case .d:
            2

        case .e:
            3

        case .f:
            4

        case .g:
            5
        }
    }

    // MARK: Private Type Properties

    private static let letters: [String: Self] = ["A": .a,
                                                  "B": .b,
                                                  "C": .c,
                                                  "D": .d,
                                                  "E": .e,
                                                  "F": .f,
                                                  "G": .g]
}

// MARK: - CaseIterable

extension Pitch.Letter: CaseIterable {
}

// MARK: - CustomStringConvertible

extension Pitch.Letter: CustomStringConvertible {

    /// The uppercase string representation of this pitch letter (e.g., `"C"`, `"D"`, `"E"`).
    public var description: String {
        switch self {
        case .a:
            "A"

        case .b:
            "B"

        case .c:
            "C"

        case .d:
            "D"

        case .e:
            "E"

        case .f:
            "F"

        case .g:
            "G"
        }
    }
}

// MARK: - Equatable

extension Pitch.Letter: Equatable {
}

// MARK: - Sendable

extension Pitch.Letter: Sendable {
}
