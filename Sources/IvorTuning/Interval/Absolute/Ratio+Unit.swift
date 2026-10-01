// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

extension Ratio {

    // MARK: Public Initializers

    /// Creates a ratio from its size in the given unit.
    ///
    /// - Parameter value:  The interval size, in `unit`.
    /// - Parameter unit:   The unit `value` is expressed in.
    ///
    /// - Returns:  `nil` if `value` is negative or too large for a ratio to represent.
    public init?(_ value: Number,
                 in unit: Unit) {
        guard let ratio = unit.ratio(for: value)
        else { return nil }

        self = ratio
    }

    /// Creates a ratio from a value expressed in cents.
    ///
    /// - Parameter value:  The interval size in cents (hundredths of a semitone).
    ///
    /// - Precondition: `value` is not negative.
    public init(cents value: Number) {
        self.init(value, in: .cents)!    // swiftlint:disable:this force_unwrapping
    }

    /// Creates a ratio from a value expressed in hekts.
    ///
    /// - Parameter value:  The interval size in hekts (hundredths of a tritave step).
    ///
    /// - Precondition: `value` is not negative.
    public init(hekts value: Number) {
        self.init(value, in: .hekts)!    // swiftlint:disable:this force_unwrapping
    }

    /// Creates a ratio from a value expressed in millioctaves.
    ///
    /// - Parameter value:  The interval size in millioctaves (thousandths of an octave).
    ///
    /// - Precondition: `value` is not negative.
    public init(millioctaves value: Number) {
        self.init(value, in: .millioctaves)!    // swiftlint:disable:this force_unwrapping
    }

    /// Creates a ratio from a value expressed in savarts.
    ///
    /// - Parameter value:  The interval size in savarts (thousandths of a decade).
    ///
    /// - Precondition: `value` is not negative.
    public init(savarts value: Number) {
        self.init(value, in: .savarts)!    // swiftlint:disable:this force_unwrapping
    }

    // MARK: Public Instance Properties

    /// The value of this ratio, expressed in cents.
    public var cents: Number {
        value(in: .cents)
    }

    /// The value of this ratio, expressed in hekts.
    public var hekts: Number {
        value(in: .hekts)
    }

    /// The value of this ratio, expressed in millioctaves.
    public var millioctaves: Number {
        value(in: .millioctaves)
    }

    /// The value of this ratio, expressed in savarts.
    public var savarts: Number {
        value(in: .savarts)
    }

    // MARK: Public Instance Methods

    /// Returns the size of this ratio in the given unit.
    ///
    /// - Parameter unit:   The unit to express the size in.
    ///
    /// - Returns:  The size of this ratio, in `unit`; never negative.
    public func value(in unit: Unit) -> Number {
        unit.value(of: self)
    }
}
