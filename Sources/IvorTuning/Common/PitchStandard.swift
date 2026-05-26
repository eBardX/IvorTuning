// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

/// A reference pitch that associates a specific pitch with its frequency.
public struct PitchStandard {

    // MARK: Public Initializers

    /// Creates a pitch standard from a reference pitch and frequency.
    ///
    /// - Parameter pitch:      The reference pitch.
    /// - Parameter frequency:  The frequency of the reference pitch.
    public init(pitch: Pitch,
                frequency: Frequency) {
        self.frequency = frequency
        self.pitch = pitch
    }

    // MARK: Public Instance Properties

    /// The reference frequency.
    public let frequency: Frequency

    /// The reference pitch.
    public let pitch: Pitch
}

// MARK: -

extension PitchStandard {

    /// The (modern) Baroque pitch standard, with A4 tuned to 415 Hz.
    public static let a415 = PitchStandard(pitch: .a4,      // (modern) Baroque pitch
                                           frequency: 415)

    /// The philosophical (scientific) pitch standard, with C4 tuned to 256 Hz.
    public static let c256 = PitchStandard(pitch: .c4,      // philosophical pitch / scientific pitch
                                           frequency: 256)

    /// The Verdi pitch standard, with A4 tuned to 432 Hz.
    public static let a432 = PitchStandard(pitch: .a4,      // Verdi pitch
                                           frequency: 432)

    /// The diapason normal pitch standard, with A4 tuned to 435 Hz.
    public static let a435 = PitchStandard(pitch: .a4,      // diapason normal pitch
                                           frequency: 435)

    /// The international concert pitch standard, with A4 tuned to 440 Hz.
    public static let a440 = PitchStandard(pitch: .a4,      // international standard pitch / Stuttgart pitch
                                           frequency: 440)
}

// MARK: - Sendable

extension PitchStandard: Sendable {
}
