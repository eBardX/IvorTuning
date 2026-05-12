public struct WellTemperament: TuningSystem {

    // MARK: Public Instance Methods

    public func realize(interval: Interval) -> Ratio? {
        nil
    }

    public func realize(pitch: Pitch,
                        standard: PitchStandard) -> Frequency? {
        nil
    }
}

// MARK: - Sendable

extension WellTemperament: Sendable {
}
