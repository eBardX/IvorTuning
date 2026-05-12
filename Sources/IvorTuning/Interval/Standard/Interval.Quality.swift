private import XestiTools

extension Interval {
    public enum Quality {
        case quadruplyDiminished
        case triplyDiminished
        case doublyDiminished
        case diminished
        case minor
        case perfect
        case major
        case augmented
        case doublyAugmented
        case triplyAugmented
        case quadruplyAugmented
    }
}

// MARK: -

extension Interval.Quality {

    // MARK: Public Initializers

    public init?(stringValue: String) {
        guard let quality = Self.qualities[stringValue]
        else { return nil }

        self = quality
    }

    // MARK: Public Instance Methods

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
    public var description: String {
        Self.stringValues[self].require()
    }
}

// MARK: - Sendable

extension Interval.Quality: Sendable {
}
