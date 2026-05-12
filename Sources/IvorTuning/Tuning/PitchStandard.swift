private import XestiNumbers

public struct PitchStandard {

    // MARK: Public Initializers

    public init(pitch: Pitch,
                frequency: Frequency) {
        self.frequency = frequency
        self.pitch = pitch
    }

    // MARK: Public Instance Properties

    public let frequency: Frequency
    public let pitch: Pitch
}

// MARK: -

extension PitchStandard {
    public static let a415 = PitchStandard(pitch: .a4,      // (modern) Baroque pitch
                                           frequency: 415)

    public static let c256 = PitchStandard(pitch: .c4,      // philosophical pitch / scientific pitch
                                           frequency: 256)

    public static let a432 = PitchStandard(pitch: .a4,      // Verdi pitch
                                           frequency: 432)

    public static let a435 = PitchStandard(pitch: .a4,      // diapason normal pitch
                                           frequency: 435)

    public static let a440 = PitchStandard(pitch: .a4,      // international standard pitch / Stuttgart pitch
                                           frequency: 440)
}

// MARK: - Sendable

extension PitchStandard: Sendable {
}
