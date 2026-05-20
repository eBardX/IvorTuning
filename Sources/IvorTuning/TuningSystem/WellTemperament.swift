// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A tuning system in which all twelve keys are usable but have distinct tonal characters,
/// achieved by distributing the Pythagorean comma unevenly around the circle of fifths.
///
/// A well temperament is fully defined by the sizes of its twelve perfect fifths around
/// the circle. ``fifths`` maps each ``Fifth`` to its frequency ratio. Any fifth not
/// present in the map is assumed to be a pure 3:2.
///
/// For the tuning to be internally consistent, the product of all twelve fifths must equal
/// 2⁷ (seven octaves), closing the circle. This invariant is not enforced at init time,
/// but all predefined constants satisfy it exactly.
///
/// The period is an octave (2:1).
public struct WellTemperament {

    // MARK: Public Initializers

    /// Creates a well temperament with the given tempered fifths.
    ///
    /// - Parameter fifths: A mapping from ``Fifth`` to its frequency ratio. Any fifth
    ///                     not present defaults to a pure 3:2 at lookup time.
    public init(fifths: [Fifth: Ratio]) {
        self.fifths = fifths
    }

    // MARK: Public Instance Properties

    /// The tempered fifth ratios, keyed by position in the circle of fifths.
    ///
    /// Any ``Fifth`` not present in this dictionary is a pure perfect fifth (3:2).
    public let fifths: [Fifth: Ratio]
}

// MARK: - TuningSystem

extension WellTemperament: TuningSystem {
}

// MARK: - Sendable

extension WellTemperament: Sendable {
}
