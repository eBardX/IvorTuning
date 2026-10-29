// © 2026 John Gary Pusey (see LICENSE.md)

/// A musical interval combined with a direction, indicating whether it ascends,
/// descends, or stays in place (see ``PitchDirection``).
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

// MARK: - Comparable

extension DirectedInterval: Comparable {

    /// Returns a Boolean value indicating whether the first directed interval comes before the
    /// second.
    ///
    /// Descending intervals come first, in the reverse of their intervals’ order; then the unison;
    /// then ascending intervals, in their intervals’ order. So with ``Interval``, which is ordered
    /// by notation, a descending fifth comes before a descending third, which comes before an
    /// ascending third.
    ///
    /// - Parameter lhs:    The left-hand directed interval.
    /// - Parameter rhs:    The right-hand directed interval.
    ///
    /// - Returns:  `true` if `lhs` comes before `rhs`; otherwise, `false`.
    public static func < (lhs: Self,
                          rhs: Self) -> Bool {
        let lhsRank = Self._rank(of: lhs.direction)
        let rhsRank = Self._rank(of: rhs.direction)

        guard lhsRank == rhsRank
        else { return lhsRank < rhsRank }

        return switch lhs.direction {
        case .ascending:
            lhs.interval < rhs.interval

        case .descending:
            rhs.interval < lhs.interval

        case .same:
            false
        }
    }

    // MARK: Private Type Methods

    private static func _rank(of direction: PitchDirection) -> Int {
        switch direction {
        case .ascending:
            1

        case .descending:
            -1

        case .same:
            0
        }
    }
}

// MARK: - Equatable

extension DirectedInterval: Equatable {
}

// MARK: - Hashable

extension DirectedInterval: Hashable {
}

// MARK: - Sendable

extension DirectedInterval: Sendable {
}
