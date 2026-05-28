// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// The notation system used to represent a pitch.
public enum PitchNotation {

    /// A pitch expressed as a frequency value.
    case absolute

    /// A pitch expressed as a MIDI note number.
    case keyboard

    /// A pitch expressed as a letter, accidental, and octave.
    case standard
}

// MARK: -

extension PitchNotation {

    // MARK: Public Initializers

    /// Creates a pitch notation from its string representation.
    ///
    /// - Parameter stringValue:    The string representation of the pitch notation.
    ///
    /// - Throws:   `ParseError` if `stringValue` does not match a known pitch notation.
    public init(stringValue: String) throws {
        guard let pitchNotation = Self.pitchNotations[stringValue]
        else { throw ParseError.invalidPitchNotation(stringValue) }

        self = pitchNotation
    }

    // MARK: Private Type Properties

    private static let pitchNotations: [String: Self] = ["absolute": .absolute,
                                                         "keyboard": .keyboard,
                                                         "standard": .standard]

    private static let stringValues: [Self: String] = [.absolute: "absolute",
                                                       .keyboard: "keyboard",
                                                       .standard: "standard"]
}

// MARK: - Codable

extension PitchNotation: Codable {

    // MARK: Public Initializers

    /// Creates a pitch notation by decoding from the provided decoder.
    ///
    /// - Parameter decoder:    The decoder to read from.
    ///
    /// - Throws:   `DecodingError.dataCorruptedError` if the decoded value is
    ///             not a valid pitch notation string.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        do {
            try self.init(stringValue: stringValue)
        } catch {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Invalid pitch notation value")
        }
    }

    // MARK: Public Instance Methods

    /// Encodes this pitch notation into the provided encoder.
    ///
    /// - Parameter encoder:    The encoder to write to.
    ///
    /// - Throws:   `EncodingError` if the value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(description)
    }
}

// MARK: - Comparable

extension PitchNotation: Comparable {
}

// MARK: - CustomStringConvertible

extension PitchNotation: CustomStringConvertible {

    /// The string representation of this pitch notation (e.g., `"absolute"`, `"keyboard"`, `"standard"`).
    public var description: String {
        Self.stringValues[self].require()
    }
}

// MARK: - Equatable

extension PitchNotation: Equatable {
}

// MARK: - Hashable

extension PitchNotation: Hashable {
}

// MARK: - Sendable

extension PitchNotation: Sendable {
}
