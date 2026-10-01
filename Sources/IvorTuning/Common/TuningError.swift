// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error that can occur when constructing a tuning-based converter.
public enum TuningError {
    /// Converting pitches between the two notations is not supported.
    case unsupportedConversion(from: PitchNotation, to: PitchNotation)

    /// The tuning system does not support standard pitch notation.
    case unsupportedStandardConversion
}

// MARK: - EnhancedError

extension TuningError: EnhancedError {
    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorTuning")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case let .unsupportedConversion(from, to):
            "Conversion from \(from) pitch notation to \(to) pitch notation is not supported"

        case .unsupportedStandardConversion:
            "Tuning system does not support standard pitch notation"
        }
    }
}

// MARK: - Equatable

extension TuningError: Equatable {
}

// MARK: - Sendable

extension TuningError: Sendable {
}
