public struct PitchClass {

    // MARK: Public Nested Types

    public typealias Accidental = Pitch.Accidental
    public typealias Letter     = Pitch.Letter

    // MARK: Public Initializers

    public init(letter: Letter,
                accidental: Accidental) {
        self.accidental = accidental
        self.letter = letter
    }

    // MARK: Public Instance Properties

    public let accidental: Accidental
    public let letter: Letter
}

// MARK: -

extension PitchClass {

    // MARK: Public Initializers

    public init?(stringValue: String) {
        guard let result = Self._parse(Substring(stringValue))
        else { return nil }

        self.init(letter: result.letter,
                  accidental: result.accidental)
    }

    // MARK: Private Nested Types

    private typealias ParseResult = (letter: Letter, accidental: Accidental)

    // MARK: Private Type Methods

    private static func _parse(_ input: Substring) -> ParseResult? {
        guard let first = input.first,
              let letter = Letter(stringValue: String(first)),
              let accidental = Accidental(stringValue: String(input.dropFirst()))
        else { return nil }

        return (letter, accidental)
    }
}

// MARK: - Codable

extension PitchClass: Codable {

    // MARK: Public Initializers

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let result = Self._parse(Substring(stringValue))
        else { throw DecodingError.dataCorruptedError(in: container,
                                                      debugDescription: "Invalid pitch class value") }

        self.init(letter: result.letter,
                  accidental: result.accidental)
    }

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(description)
    }
}

// MARK: - CustomStringConvertible

extension PitchClass: CustomStringConvertible {
    public var description: String {
        description(omitNatural: false)
    }

    public func description(omitNatural: Bool) -> String {
        var result = letter.description

        if accidental != .natural || !omitNatural {
            result += accidental.description
        }

        return result
    }
}

// MARK: - Equatable

extension PitchClass: Equatable {
}

// MARK: - Hashable

extension PitchClass: Hashable {
}

// MARK: - Sendable

extension PitchClass: Sendable {
}
