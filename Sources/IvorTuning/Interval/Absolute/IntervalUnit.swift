// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal import XestiNumbers

internal struct IntervalUnit {

    // MARK: Internal Type Properties

    internal static let cents = Self(logBase: 2,
                                     coefficient: 1_200)

    internal static let hekts = Self(logBase: 3,
                                     coefficient: 1_300)

    internal static let millioctaves = Self(logBase: 2,
                                            coefficient: 1_000)

    internal static let savarts = Self(logBase: 10,
                                       coefficient: 1_000)

    // MARK: Internal Constructors

    internal init(logBase: Number,
                  coefficient: Number) {
        let lnb = log(logBase)

        self.coefficient = coefficient
        self.expFactor = lnb / coefficient
        self.logBase = logBase
        self.logFactor = coefficient / lnb
    }

    // MARK: Internal Instance Properties

    internal let coefficient: Number
    internal let logBase: Number

    // MARK: Internal Instance Methods

    internal func convertFromRatio(_ value: Ratio) -> Number {
        log(value.numberValue) * logFactor
    }

    internal func convertToRatio(_ value: Number) -> Ratio {
        Ratio(exp(value * expFactor))
    }

    // MARK: Private Instance Properties

    private let expFactor: Number
    private let logFactor: Number
}

// MARK: - Sendable

extension IntervalUnit: Sendable {
}
