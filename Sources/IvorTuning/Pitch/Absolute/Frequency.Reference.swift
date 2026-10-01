// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

extension Frequency {

    // MARK: Public Nested Types

    /// Anchors a logarithmic ``Ratio/Unit`` to hertz, so that frequencies can be measured as values
    /// in that unit.
    ///
    /// The reference ``frequency`` measures as ``value``. Every other frequency measures as
    /// ``value`` plus the size of its interval from ``frequency`` in ``unit``: more above it, less
    /// below it. For example, with 440 Hz at 6900 cents, 880 Hz measures 8100 cents and 220 Hz
    /// measures 5700 cents.
    ///
    /// See ``default(in:)`` for each unit’s conventional reference.
    public struct Reference {

        // MARK: Public Initializers

        /// Creates a frequency reference.
        ///
        /// - Parameter frequency:  The reference frequency.
        /// - Parameter value:      The value `frequency` measures as, in `unit`.
        /// - Parameter unit:       The unit values are measured in.
        public init(frequency: Frequency,
                    value: Number,
                    unit: Ratio.Unit) {
            self.frequency = frequency
            self.unit = unit
            self.value = value
        }

        // MARK: Public Instance Properties

        /// The reference frequency.
        public let frequency: Frequency

        /// The unit values are measured in.
        public let unit: Ratio.Unit

        /// The value ``frequency`` measures as, in ``unit``.
        public let value: Number
    }
}

// MARK: -

extension Frequency.Reference {

    // MARK: Public Type Methods

    /// Returns the conventional reference for measuring frequencies in the given unit, which puts
    /// 440 Hz at a round value.
    ///
    /// Cents follow the SoundFont “absolute cents” and MIDI midicents convention, where 6900 ¢ is
    /// MIDI note 69 (A4 = 440 Hz), so zero falls at about 8.176 Hz. The other units have no
    /// established convention, so each puts 440 Hz at that same zero point’s value in the unit,
    /// rounded down to the nearest hundred: 5700 millioctaves, 1700 savarts, and 4700 hekts.
    ///
    /// - Parameter unit:   The unit to measure frequencies in.
    ///
    /// - Returns:  The conventional reference for `unit`.
    public static func `default`(in unit: Ratio.Unit) -> Self {
        switch unit {
        case .cents:
            Self(frequency: 440,
                 value: 6_900,
                 unit: unit)

        case .hekts:
            Self(frequency: 440,
                 value: 4_700,
                 unit: unit)

        case .millioctaves:
            Self(frequency: 440,
                 value: 5_700,
                 unit: unit)

        case .savarts:
            Self(frequency: 440,
                 value: 1_700,
                 unit: unit)
        }
    }

    // MARK: Public Instance Methods

    /// Returns the frequency that measures as the given value.
    ///
    /// - Parameter value:  A value in ``unit``.
    ///
    /// - Returns:  The frequency, or `nil` if `value` is too far from ``value`` for a
    ///             ``Frequency`` to represent.
    public func frequency(at value: Number) -> Frequency? {
        let difference = value - self.value

        guard let ratio = Ratio(difference.isNegative ? -difference : difference,
                                in: unit)
        else { return nil }

        guard !ratio.isUnison
        else { return frequency }

        return frequency.transposed(by: DirectedInterval(interval: ratio,
                                                         direction: difference.isNegative ? .descending : .ascending))
    }

    /// Returns the value the given frequency measures as.
    ///
    /// - Parameter frequency:  The frequency to measure.
    ///
    /// - Returns:  The value of `frequency`, in ``unit``.
    public func value(of frequency: Frequency) -> Number {
        guard let interval = self.frequency.interval(to: frequency)
        else { return value }

        let size = interval.interval.value(in: unit)

        switch interval.direction {
        case .ascending:
            return value + size

        case .descending:
            return value - size

        case .same:
            return value
        }
    }
}

// MARK: - Equatable

extension Frequency.Reference: Equatable {
}

// MARK: - Hashable

extension Frequency.Reference: Hashable {
}

// MARK: - Sendable

extension Frequency.Reference: Sendable {
}
