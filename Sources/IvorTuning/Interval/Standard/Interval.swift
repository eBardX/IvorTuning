// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A musical interval defined by a quality and a diatonic size.
public struct Interval {

    // MARK: Public Instance Properties

    /// The quality of this interval (e.g., perfect, major, minor, diminished, augmented).
    public let quality: Quality

    /// The diatonic size of this interval (e.g., 1 for unison, 5 for a fifth).
    public let size: Size

    // MARK: Internal Initializers

    internal init(_ quality: Quality,
                  _ size: Size) {
        self.size = size
        self.quality = quality
    }
}

// MARK: -

extension Interval {

    // MARK: Public Type Properties

    /// The perfect unison interval.
    public static let unison = Self.perfect1

    // MARK: Public Initializers

    /// An error thrown when a quality and size combination is not musically valid.
    public struct InvalidCombinationError: Error, CustomStringConvertible, Sendable {

        /// The quality that was invalid for the given size.
        public let quality: Quality

        /// The size that was invalid for the given quality.
        public let size: Size

        /// A human-readable description of the invalid combination.
        public var description: String {
            "Quality \"\(quality)\" is not valid for size \(size)"
        }
    }

    /// Creates an interval from a quality and size.
    ///
    /// - Parameter quality:    The interval quality.
    /// - Parameter size:       The diatonic size.
    ///
    /// - Throws:   `InvalidCombinationError` if the quality and size combination is not musically valid.
    public init(quality: Quality,
                size: Size) throws {
        guard Self._isValid(quality, size)
        else { throw InvalidCombinationError(quality: quality, size: size) }

        self.init(quality, size)
    }

    /// Creates an interval from its string representation.
    ///
    /// - Parameter stringValue:    The string representation of the interval (e.g., `"P5"`, `"m3"`).
    ///
    /// - Throws:   `ParseError` if `stringValue` cannot be parsed as a valid interval.
    public init(stringValue: String) throws {
        guard let result = Self._parse(Substring(stringValue))
        else { throw ParseError.invalidInterval(stringValue) }

        self.init(result.quality,
                  result.size)
    }

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this interval spans at most one octave.
    public var isSimple: Bool {
        !Self._isCompound(quality, size)
    }

    /// The number of complete octaves spanned by this interval.
    public var octaveSpan: Int {
        (size.intValue - 1) / 7
    }

    // MARK: Public Instance Methods

    /// Returns the inversion of this interval.
    ///
    /// - Returns:  The inverted interval, or `nil` if this interval is compound.
    public func inverted() -> Self? {
        guard !Self._isCompound(quality, size),
              let newSize = Size(intValue: 9 - size.intValue)
        else { return nil }

        return Self(quality.inverted(),
                    newSize)
    }

    /// Returns the simplified (non-compound) form of this interval.
    ///
    /// - Returns:  The equivalent simple interval within one octave.
    public func simplified() -> Self {
        guard Self._isCompound(quality, size)
        else { return self }

        var rawSize = size.intValue

        repeat {
            rawSize -= 7
        } while Self._isCompound(quality, Size(rawSize))

        return Self(quality, Size(rawSize))
    }

    // MARK: Internal Instance Methods

    internal func deconstructed() -> (Self, Int) {
        let simple = simplified()
        let extra = octaveSpan - simple.octaveSpan

        return (simple, extra)
    }

    // MARK: Private Nested Types

    private typealias ParseResult = (quality: Quality, size: Size)

    // MARK: Private Type Properties

    private static let sizeCharacters: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    // MARK: Private Type Methods

    private static func _diatonicDegree(for size: Size) -> Int {
        1 + ((size.intValue - 1) % 7)
    }

    private static func _isCompound(_ quality: Quality,
                                    _ size: Size) -> Bool {
        let rawSize = size.intValue

        return rawSize > 8 || (rawSize == 8 &&
                               [.augmented,
                                .doublyAugmented,
                                .triplyAugmented,
                                .quadruplyAugmented].contains(quality))
    }

    private static func _isValid(_ quality: Quality,
                                 _ size: Size) -> Bool {
        switch quality {
        case .diminished,
                .doublyDiminished,
                .quadruplyDiminished,
                .triplyDiminished:
            size.intValue != 1

        case .major,
                .minor:
            [2, 3, 6, 7].contains(_diatonicDegree(for: size))

        case .perfect:
            [1, 4, 5].contains(_diatonicDegree(for: size))

        case .augmented,
                .doublyAugmented,
                .quadruplyAugmented,
                .triplyAugmented:
            true
        }
    }

    private static func _parse(_ input: Substring) -> ParseResult? {
        let result = input.splitBeforeFirst(sizeCharacters)

        guard let stext = result.tail,
              let rawSize = Int(stext),
              let size = Size(intValue: rawSize),
              let quality = try? Quality(stringValue: String(result.head)),
              _isValid(quality, size)
        else { return nil }

        return (quality, size)
    }
}

// MARK: - Codable

extension Interval: Codable {

    // MARK: Public Initializers

    /// Creates an interval by decoding from the provided decoder.
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorruptedError` if the decoded value is
    ///             not a valid interval string.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let result = Self._parse(Substring(stringValue))
        else { throw DecodingError.dataCorruptedError(in: container,
                                                      debugDescription: "Invalid interval value: \(stringValue)") }

        self.init(result.quality,
                  result.size)
    }

    // MARK: Public Instance Methods

    /// Encodes this interval into the provided encoder.
    ///
    /// - Parameter encoder:    The encoder to write to.
    ///
    /// - Throws:   `EncodingError` if the value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(description)
    }
}

// MARK: - CustomStringConvertible

extension Interval: CustomStringConvertible {

    /// The string representation of this interval (e.g., `"P5"`, `"m3"`).
    public var description: String {
        quality.description + size.description
    }
}

// MARK: - Hashable

extension Interval: Hashable {
}

// MARK: - IntervalProtocol

extension Interval: IntervalProtocol {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this interval is a unison.
    public var isUnison: Bool {
        self == .unison
    }

    // MARK: Public Instance Methods

    /// Returns the sum of this interval and another interval.
    ///
    /// - Parameter other:  The interval to add.
    ///
    /// - Returns:  The combined interval, or `nil` if the result is out of range or invalid.
    public func adding(_ other: Self) -> Self? {
        guard let lpf = PerfectFifths.fifths(for: simplified()),
              let rpf = PerfectFifths.fifths(for: other.simplified()),
              let sum = PerfectFifths.interval(for: lpf + rpf),
              let newSize = Size(intValue: size.intValue + other.size.intValue - 1)
        else { return nil }

        return Self(sum.quality,
                    newSize)
    }

    /// Returns the difference between this interval and another interval.
    ///
    /// - Parameter other:  The interval to subtract.
    ///
    /// - Returns:  The resulting interval, or `nil` if the result is out of range or invalid.
    public func subtracting(_ other: Self) -> Self? {
        guard let lpf = PerfectFifths.fifths(for: simplified()),
              let rpf = PerfectFifths.fifths(for: other.simplified()),
              let dif = PerfectFifths.interval(for: lpf - rpf),
              let newSize = Size(intValue: size.intValue - other.size.intValue + 1)
        else { return nil }

        return Self(dif.quality,
                    newSize)
    }
}

// MARK: - Sendable

extension Interval: Sendable {
}
