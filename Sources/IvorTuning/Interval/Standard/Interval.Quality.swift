// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension Interval {
    /// The quality of a musical interval.
    public enum Quality {

        /// A quadruply diminished quality.
        case quadruplyDiminished

        /// A triply diminished quality.
        case triplyDiminished

        /// A doubly diminished quality.
        case doublyDiminished

        /// A diminished quality.
        case diminished

        /// A minor quality.
        case minor

        /// A perfect quality, used for unisons, fourths, fifths, and octaves.
        case perfect

        /// A major quality.
        case major

        /// An augmented quality.
        case augmented

        /// A doubly augmented quality.
        case doublyAugmented

        /// A triply augmented quality.
        case triplyAugmented

        /// A quadruply augmented quality.
        case quadruplyAugmented
    }
}

// MARK: -

extension Interval.Quality {

    // MARK: Public Initializers

    /// Creates an interval quality from its string representation.
    ///
    /// - Parameter stringValue:    The string representation of the quality (e.g., `"P"`, `"m"`, `"M"`).
    ///
    /// - Throws:   `ParseError` if `stringValue` does not match a known quality symbol.
    public init(stringValue: String) throws {
        guard let quality = Self.qualities[stringValue]
        else { throw ParseError.invalidIntervalQuality(stringValue) }

        self = quality
    }

    // MARK: Public Instance Methods

    /// Returns the inversion of this quality.
    ///
    /// - Returns:  The inverted quality (e.g., major inverts to minor, augmented inverts to diminished).
    public func inverted() -> Self {
        Self.inversions[self].require()
    }

    // MARK: Private Type Properties

    private static let inversions: [Self: Self] = [.quadruplyDiminished: .quadruplyAugmented,
                                                   .triplyDiminished: .triplyAugmented,
                                                   .doublyDiminished: .doublyAugmented,
                                                   .diminished: .augmented,
                                                   .minor: .major,
                                                   .perfect: .perfect,
                                                   .major: .minor,
                                                   .augmented: .diminished,
                                                   .doublyAugmented: .doublyDiminished,
                                                   .triplyAugmented: .triplyDiminished,
                                                   .quadruplyAugmented: .quadruplyDiminished]

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

    private static let stringValues: [Self: String] = [.quadruplyDiminished: "dddd",
                                                       .triplyDiminished: "ddd",
                                                       .doublyDiminished: "dd",
                                                       .diminished: "d",
                                                       .minor: "m",
                                                       .perfect: "P",
                                                       .major: "M",
                                                       .augmented: "A",
                                                       .doublyAugmented: "AA",
                                                       .triplyAugmented: "AAA",
                                                       .quadruplyAugmented: "AAAA"]
}

// MARK: - Codable

extension Interval.Quality: Codable {
}

// MARK: - CustomStringConvertible

extension Interval.Quality: CustomStringConvertible {

    /// The string representation of this quality (e.g., `"P"`, `"m"`, `"M"`, `"d"`, `"A"`).
    public var description: String {
        Self.stringValues[self].require()
    }
}

// MARK: - Equatable

extension Interval.Quality: Equatable {
}

// MARK: - Sendable

extension Interval.Quality: Sendable {
}
