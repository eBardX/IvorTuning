// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension Pitch {

    // MARK: Public Nested Types

    /// A diatonic letter name for a pitch.
    public enum Letter {

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

        /// The pitch letter A.
        case a

        /// The pitch letter B.
        case b
    }
}

// MARK: -

extension Pitch.Letter {

    // MARK: Public Initializers

    /// Creates a pitch letter from its string representation.
    ///
    /// - Parameter stringValue:    The uppercase letter string (e.g., `"C"`).
    ///
    /// - Throws:   `ParseError` if `stringValue` does not match a known pitch letter.
    public init(stringValue: String) throws {
        guard let letter = Self.letters[stringValue]
        else { throw ParseError.invalidPitchLetter(stringValue) }

        self = letter
    }

    // MARK: Public Instance Properties

    /// The diatonic order of this pitch letter, where C is 1 and B is 7.
    public var order: Int {
        Self.orders[self].require()
    }

    // MARK: Private Type Properties

    private static let letters: [String: Self] = ["A": .a,
                                                  "B": .b,
                                                  "C": .c,
                                                  "D": .d,
                                                  "E": .e,
                                                  "F": .f,
                                                  "G": .g]

    private static let orders: [Self: Int] = [.a: 6,
                                              .b: 7,
                                              .c: 1,
                                              .d: 2,
                                              .e: 3,
                                              .f: 4,
                                              .g: 5]

    private static let stringValues: [Self: String] = [.a: "A",
                                                       .b: "B",
                                                       .c: "C",
                                                       .d: "D",
                                                       .e: "E",
                                                       .f: "F",
                                                       .g: "G"]
}

// MARK: - CaseIterable

extension Pitch.Letter: CaseIterable {
}

// MARK: - CustomStringConvertible

extension Pitch.Letter: CustomStringConvertible {

    /// The uppercase string representation of this pitch letter (e.g., `"C"`, `"D"`, `"E"`).
    public var description: String {
        Self.stringValues[self].require()
    }
}

// MARK: - Sendable

extension Pitch.Letter: Sendable {
}
