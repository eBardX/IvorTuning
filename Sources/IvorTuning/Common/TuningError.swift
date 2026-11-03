// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiTools

/// An error that can occur when constructing a tuning-based converter.
public enum TuningError {
    /// The keyboard layout is invalid, for the given reason.
    case invalidKeyboardLayout(KeyboardLayout.Problem)

    /// The tuning system does not support standard pitch notation.
    case unsupportedStandardConversion
}

// MARK: - EnhancedError

extension TuningError: EnhancedError {

    // MARK: Public Instance Properties

    /// The error category identifying the source module.
    public var category: Category? {
        Category("IvorTuning")
    }

    /// A human-readable description of this error.
    public var message: String {
        switch self {
        case let .invalidKeyboardLayout(problem):
            "Keyboard layout is invalid: \(problem.message)"

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
