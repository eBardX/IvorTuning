// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension Interval {
    /// The quality of a musical interval.
    public enum Quality {

        /// An augmented quality.
        case augmented

        /// A diminished quality.
        case diminished

        /// A doubly augmented quality.
        case doublyAugmented

        /// A doubly diminished quality.
        case doublyDiminished

        /// A major quality.
        case major

        /// A minor quality.
        case minor

        /// A perfect quality, used for unisons, fourths, fifths, and octaves.
        case perfect

        /// A quadruply augmented quality.
        case quadruplyAugmented

        /// A quadruply diminished quality.
        case quadruplyDiminished

        /// A triply augmented quality.
        case triplyAugmented

        /// A triply diminished quality.
        case triplyDiminished

        // MARK: Public Initializers

        /// Creates an interval quality from its string representation.
        ///
        /// - Parameter stringValue:    The string representation of the quality (e.g., `"P"`, `"m"`, `"M"`).
        ///
        /// - Throws:   `ParseError` if `stringValue` does not match a known quality symbol.
        public init(stringValue: String) throws(ParseError) {
            guard let quality = Self.qualities[stringValue]
            else { throw ParseError.invalidIntervalQuality(stringValue) }

            self = quality
        }
    }
}

// MARK: -

extension Interval.Quality {

    // MARK: Public Instance Methods

    /// Returns the inversion of this quality.
    ///
    /// - Returns:  The inverted quality (e.g., major inverts to minor, augmented inverts to diminished).
    public func inverted() -> Self {
        switch self {
        case .augmented:
            .diminished

        case .diminished:
            .augmented

        case .doublyAugmented:
            .doublyDiminished

        case .doublyDiminished:
            .doublyAugmented

        case .major:
            .minor

        case .minor:
            .major

        case .perfect:
            .perfect

        case .quadruplyAugmented:
            .quadruplyDiminished

        case .quadruplyDiminished:
            .quadruplyAugmented

        case .triplyAugmented:
            .triplyDiminished

        case .triplyDiminished:
            .triplyAugmented
        }
    }

    // MARK: Private Type Properties

    private static let qualities: [String: Self] = ["dddd": .quadruplyDiminished,
                                                    "ddd": .triplyDiminished,
                                                    "dd": .doublyDiminished,
                                                    "d": .diminished,
                                                    "m": .minor,
                                                    "P": .perfect,
                                                    "M": .major,
                                                    "A": .augmented,
                                                    "AA": .doublyAugmented,
                                                    "AAA": .triplyAugmented,
                                                    "AAAA": .quadruplyAugmented]
}

// MARK: - Codable

extension Interval.Quality: Codable {
}

// MARK: - CustomStringConvertible

extension Interval.Quality: CustomStringConvertible {
    /// The string representation of this quality (e.g., `"P"`, `"m"`, `"M"`, `"d"`, `"A"`).
    public var description: String {
        switch self {
        case .augmented:
            "A"

        case .diminished:
            "d"

        case .doublyAugmented:
            "AA"

        case .doublyDiminished:
            "dd"

        case .major:
            "M"

        case .minor:
            "m"

        case .perfect:
            "P"

        case .quadruplyAugmented:
            "AAAA"

        case .quadruplyDiminished:
            "dddd"

        case .triplyAugmented:
            "AAA"

        case .triplyDiminished:
            "ddd"
        }
    }
}

// MARK: - Equatable

extension Interval.Quality: Equatable {
}

// MARK: - Sendable

extension Interval.Quality: Sendable {
}
