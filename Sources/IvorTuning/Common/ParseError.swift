// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error that can occur while parsing a string value.
public enum ParseError {
    /// The interval is malformed or unrecognized.
    case invalidInterval(String)

    /// The interval quality is unrecognized.
    case invalidIntervalQuality(String)

    /// The pitch is malformed or unrecognized.
    case invalidPitch(String)

    /// The pitch accidental is unrecognized.
    case invalidPitchAccidental(String)

    /// The pitch class is malformed or unrecognized.
    case invalidPitchClass(String)

    /// The pitch letter is unrecognized.
    case invalidPitchLetter(String)

    /// The pitch notation is unrecognized.
    case invalidPitchNotation(String)
}

// MARK: - EnhancedError

extension ParseError: EnhancedError {

    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorTuning")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case let .invalidInterval(value):
            "Invalid interval: ‘\(value)’"

        case let .invalidIntervalQuality(value):
            "Invalid interval quality: ‘\(value)’"

        case let .invalidPitch(value):
            "Invalid pitch: ‘\(value)’"

        case let .invalidPitchAccidental(value):
            "Invalid pitch accidental: ‘\(value)’"

        case let .invalidPitchClass(value):
            "Invalid pitch class: ‘\(value)’"

        case let .invalidPitchLetter(value):
            "Invalid pitch letter: ‘\(value)’"

        case let .invalidPitchNotation(value):
            "Invalid pitch notation: ‘\(value)’"
        }
    }
}

// MARK: - Sendable

extension ParseError: Sendable {
}
