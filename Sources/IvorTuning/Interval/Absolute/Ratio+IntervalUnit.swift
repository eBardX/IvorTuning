// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

extension Ratio {

    /// Creates a ratio from a value expressed in cents.
    ///
    /// - Parameter value:  The interval size in cents (hundredths of a semitone).
    public init(cents value: Number) {
        self = IntervalUnit.cents.convertToRatio(value)
    }

    /// Creates a ratio from a value expressed in hekts.
    ///
    /// Renamed to ``init(hekts:)``.
    ///
    /// - Parameter value:  The interval size in hekts (hundredths of a tritave step).
    @available(*, deprecated, renamed: "init(hekts:)")
    public init(hekt value: Number) {
        self.init(hekts: value)
    }

    /// Creates a ratio from a value expressed in hekts.
    ///
    /// - Parameter value:  The interval size in hekts (hundredths of a tritave step).
    public init(hekts value: Number) {
        self = IntervalUnit.hekts.convertToRatio(value)
    }

    /// Creates a ratio from a value expressed in millioctaves.
    ///
    /// - Parameter value:  The interval size in millioctaves (thousandths of an octave).
    public init(millioctaves value: Number) {
        self = IntervalUnit.millioctaves.convertToRatio(value)
    }

    /// Creates a ratio from a value expressed in savarts.
    ///
    /// - Parameter value:  The interval size in savarts (thousandths of a decade).
    public init(savarts value: Number) {
        self = IntervalUnit.savarts.convertToRatio(value)
    }

    /// Returns this ratio expressed in cents.
    public var cents: Number {
        IntervalUnit.cents.convertFromRatio(self)
    }

    /// Returns this ratio expressed in hekts.
    ///
    /// Renamed to ``hekts``.
    @available(*, deprecated, renamed: "hekts")
    public var hekt: Number {
        hekts
    }

    /// Returns this ratio expressed in hekts.
    public var hekts: Number {
        IntervalUnit.hekts.convertFromRatio(self)
    }

    /// Returns this ratio expressed in millioctaves.
    public var millioctaves: Number {
        IntervalUnit.millioctaves.convertFromRatio(self)
    }

    /// Returns this ratio expressed in savarts.
    public var savarts: Number {
        IntervalUnit.savarts.convertFromRatio(self)
    }
}
