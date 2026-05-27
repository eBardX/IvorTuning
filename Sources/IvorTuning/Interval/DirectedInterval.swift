// © 2026 John Gary Pusey (see LICENSE.md)

/// A musical interval combined with a direction, indicating whether it moves
/// upward, downward, or stays in place.
///
/// A unison interval must always pair with ``PitchDirection/same``; a non-unison
/// interval must pair with ``PitchDirection/ascending`` or
/// ``PitchDirection/descending``. The initializer enforces this with a precondition.
public struct DirectedInterval<IntervalType: IntervalProtocol> {

    // MARK: Public Initializers

    /// Creates a directed interval from a bare interval and a direction.
    ///
    /// - Parameter interval:   The interval value.
    /// - Parameter direction:  The direction of movement.
    ///
    /// - Precondition: A unison interval requires `.same`; a non-unison interval
    ///                 requires `.ascending` or `.descending`.
    public init(interval: IntervalType,
                direction: PitchDirection) {
        precondition(interval.isUnison
                     ? direction == .same
                     : direction != .same)

        self.direction = direction
        self.interval = interval
    }

    // MARK: Public Instance Properties

    /// The direction of the interval: ascending, descending, or same.
    public let direction: PitchDirection

    /// The underlying interval value.
    public let interval: IntervalType
}

// MARK: - Codable

extension DirectedInterval: Codable {
}

// MARK: - Equatable

extension DirectedInterval: Equatable {
}

// MARK: - Sendable

extension DirectedInterval: Sendable {
}
