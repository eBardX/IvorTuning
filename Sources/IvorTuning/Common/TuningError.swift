// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error that can occur when constructing a tuning-based converter.
public enum TuningError {
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
        case .unsupportedStandardConversion:
            "Tuning system does not support standard pitch notation"
        }
    }
}

// MARK: - Sendable

extension TuningError: Sendable {
}
