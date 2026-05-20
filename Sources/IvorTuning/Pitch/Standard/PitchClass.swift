// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A pitch class identified by a diatonic letter and an accidental.
public struct PitchClass {

    // MARK: Public Nested Types

    /// A type alias for ``Pitch/Accidental``.
    public typealias Accidental = Pitch.Accidental

    /// A type alias for ``Pitch/Letter``.
    public typealias Letter = Pitch.Letter

    // MARK: Public Initializers

    /// Creates a pitch class from a letter and accidental.
    ///
    /// - Parameter letter:     The diatonic letter name.
    /// - Parameter accidental: The accidental of the pitch class.
    public init(letter: Letter,
                accidental: Accidental) {
        self.accidental = accidental
        self.letter = letter
    }

    // MARK: Public Instance Properties

    /// The accidental of this pitch class.
    public let accidental: Accidental

    /// The diatonic letter name of this pitch class.
    public let letter: Letter
}

// MARK: -

extension PitchClass {

    // MARK: Public Initializers

    /// Creates a pitch class from its string representation.
    ///
    /// - Parameter stringValue:    The string representation of the pitch class (e.g., `"C♯"`).
    ///
    /// - Throws:   `ParseError` if `stringValue` cannot be parsed as a valid pitch class.
    public init(stringValue: String) throws {
        guard let result = Self._parse(Substring(stringValue))
        else { throw ParseError.invalidPitchClass(stringValue) }

        self.init(letter: result.letter,
                  accidental: result.accidental)
    }

    // MARK: Public Instance Methods

    /// Returns the string representation of this pitch class.
    ///
    /// Renamed to ``stringValue(omitNatural:)``.
    ///
    /// - Parameter omitNatural:    When `true`, the natural accidental symbol is omitted.
    ///
    /// - Returns:  The string representation of the pitch class.
    @available(*, deprecated, renamed: "stringValue(omitNatural:)")
    public func description(omitNatural: Bool) -> String {
        stringValue(omitNatural: omitNatural)
    }

    /// Returns the string representation of this pitch class.
    ///
    /// - Parameter omitNatural:    When `true`, the natural accidental symbol is omitted.
    ///
    /// - Returns:  The string representation of the pitch class.
    public func stringValue(omitNatural: Bool) -> String {
        var result = letter.description

        if accidental != .natural || !omitNatural {
            result += accidental.description
        }

        return result
    }

    // MARK: Private Nested Types

    private typealias ParseResult = (letter: Letter, accidental: Accidental)

    // MARK: Private Type Methods

    private static func _parse(_ input: Substring) -> ParseResult? {
        guard let first = input.first,
              let letter = try? Letter(stringValue: String(first)),
              let accidental = try? Accidental(stringValue: String(input.dropFirst()))
        else { return nil }

        return (letter, accidental)
    }
}

// MARK: - Codable

extension PitchClass: Codable {

    // MARK: Public Initializers

    /// Creates a pitch class by decoding from the provided decoder.
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorruptedError` if the decoded value is
    ///             not a valid pitch class string.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let result = Self._parse(Substring(stringValue))
        else { throw DecodingError.dataCorruptedError(in: container,
                                                      debugDescription: "Invalid pitch class value: \(stringValue)") }

        self.init(letter: result.letter,
                  accidental: result.accidental)
    }

    // MARK: Public Instance Methods

    /// Encodes this pitch class into the provided encoder.
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

extension PitchClass: CustomStringConvertible {

    /// The string representation of this pitch class, including the natural accidental symbol when present.
    public var description: String {
        stringValue(omitNatural: false)
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
