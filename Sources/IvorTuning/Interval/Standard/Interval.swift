private import XestiTools

public struct Interval {

    // MARK: Public Instance Properties

    public let quality: Quality
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

    public static let unison = Self.perfect1

    // MARK: Public Initializers

    public init?(quality: Quality,
                 size: Size) {
        guard Self._isValid(quality, size)
        else { return nil }

        self.init(quality, size)
    }

    public init?(stringValue: String) {
        guard let result = Self._parse(Substring(stringValue))
        else { return nil }

        self.init(result.quality,
                  result.size)
    }

    // MARK: Public Instance Properties

    public var isSimple: Bool {
        !Self._isCompound(quality, size)
    }

    public var octaveSpan: Int {
        (size.intValue - 1) / 7
    }

    // MARK: Public Instance Methods

    public func inverted() -> Self? {
        guard !Self._isCompound(quality, size),
              let newSize = Size(intValue: 9 - size.intValue)
        else { return nil }

        return Self(quality: quality.inverted(),
                    size: newSize)
    }

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

    private static let sizeCS: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    // MARK: Private Type Methods

    private static func _sizeClass(for size: Size) -> Int {
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
            [2, 3, 6, 7].contains(_sizeClass(for: size))

        case .perfect:
            [1, 4, 5].contains(_sizeClass(for: size))

        case .augmented,
                .doublyAugmented,
                .quadruplyAugmented,
                .triplyAugmented:
            true
        }
    }

    private static func _parse(_ input: Substring) -> ParseResult? {
        let result = input.splitBeforeFirst(sizeCS)

        guard let stext = result.tail,
              let rawSize = Int(stext),
              let size = Size(intValue: rawSize),
              let quality = Quality(stringValue: String(input.dropFirst())),
              _isValid(quality, size)
        else { return nil }

        return (quality, size)
    }
}

// MARK: - Codable

extension Interval: Codable {

    // MARK: Public Initializers

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let result = Self._parse(Substring(stringValue))
        else { throw DecodingError.dataCorruptedError(in: container,
                                                      debugDescription: "Invalid interval value") }

        self.init(result.quality,
                  result.size)
    }

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(description)
    }
}

// MARK: - CustomStringConvertible

extension Interval: CustomStringConvertible {
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

    public var isUnison: Bool {
        self == .unison
    }

    // MARK: Public Instance Methods

    public func adding(_ other: Self) -> Self? {
        guard let lpf = PerfectFifths.fifths(for: simplified()),
              let rpf = PerfectFifths.fifths(for: other.simplified()),
              let sum = PerfectFifths.interval(for: lpf + rpf),
              let newSize = Size(intValue: size.intValue + other.size.intValue - 1)
        else { return nil }

        return Self(quality: sum.quality,
                    size: newSize)
    }

    public func subtracting(_ other: Self) -> Self? {
        guard let lpf = PerfectFifths.fifths(for: simplified()),
              let rpf = PerfectFifths.fifths(for: other.simplified()),
              let dif = PerfectFifths.interval(for: lpf - rpf),
              let newSize = Size(intValue: size.intValue - other.size.intValue + 1)
        else { return nil }

        return Self(quality: dif.quality,
                    size: newSize)
    }
}

// MARK: - Sendable

extension Interval: Sendable {
}
