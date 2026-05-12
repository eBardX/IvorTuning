private import XestiTools

public enum PitchNotation {
    case absolute
    case keyboard
    case standard
}

// MARK: -

extension PitchNotation {

    // MARK: Public Initializers

    public init?(stringValue: String) {
        guard let pitchNotations = Self.pitchNotations[stringValue]
        else { return nil }

        self = pitchNotations
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

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let pitchNotation = Self.pitchNotations[stringValue]
        else { throw DecodingError.dataCorruptedError(in: container,
                                                      debugDescription: "Invalid pitch notation value") }

        self = pitchNotation
    }

    // MARK: Public Instance Methods

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(description)
    }
}

// MARK: - CustomStringConvertible

extension PitchNotation: CustomStringConvertible {
    public var description: String {
        Self.stringValues[self].require()
    }
}

// MARK: - Sendable

extension PitchNotation: Sendable {
}
