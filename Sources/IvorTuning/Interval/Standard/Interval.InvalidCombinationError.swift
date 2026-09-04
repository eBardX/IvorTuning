// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension Interval {

    // MARK: Public Nested Types

    /// An error thrown when a quality and size combination is not musically valid.
    public struct InvalidCombinationError {

        // MARK: Public Instance Properties

        /// The quality that was invalid for the given size.
        public let quality: Quality

        /// The size that was invalid for the given quality.
        public let size: Size
    }
}

// MARK: - CustomStringConvertible

extension Interval.InvalidCombinationError: CustomStringConvertible {

    /// A human-readable description of the invalid combination.
    public var description: String {
        "Quality \"\(quality)\" is not valid for size \(size)"
    }
}

// MARK: - Equatable

extension Interval.InvalidCombinationError: Equatable {
}

// MARK: - Error

extension Interval.InvalidCombinationError: Error {
}

// MARK: - Sendable

extension Interval.InvalidCombinationError: Sendable {
}
