public protocol TuningSystem: Sendable {
    var period: Ratio? { get }

    func realize(interval: Interval) -> Ratio?

    func realize(pitch: Pitch) -> Frequency?

    func realize(pitch: Pitch,
                 standard: PitchStandard) -> Frequency?
}

extension TuningSystem {
    public var period: Ratio? {
        .octave
    }

    public func realize(pitch: Pitch) -> Frequency? {
        realize(pitch: pitch,
                standard: .a440)
    }
}
