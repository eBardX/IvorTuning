public import XestiNumbers

extension Ratio {
    public init(cents value: Number) {
        self = IntervalUnit.cents.convertToRatio(value)
    }

    public init(hekt value: Number) {
        self = IntervalUnit.hekts.convertToRatio(value)
    }

    public init(millioctaves value: Number) {
        self = IntervalUnit.millioctaves.convertToRatio(value)
    }

    public init(savarts value: Number) {
        self = IntervalUnit.savarts.convertToRatio(value)
    }

    public var cents: Number {
        IntervalUnit.cents.convertFromRatio(self)
    }

    public var hekt: Number {
        IntervalUnit.hekts.convertFromRatio(self)
    }

    public var millioctaves: Number {
        IntervalUnit.millioctaves.convertFromRatio(self)
    }

    public var savarts: Number {
        IntervalUnit.savarts.convertFromRatio(self)
    }
}
