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
/// The interval of equivalence is an octave (2:1). All predefined well temperaments fully
/// support standard pitch notation via ``standardConversion(for:)``.
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
    public func standardConversion(for standard: PitchStandard) -> [PitchClass: DirectedInterval<Ratio>]? {
        let pureFifth = Ratio(3, 2)

        // The 11 circle-of-fifths steps from position 0 (C) upward through position 11 (F).
        // The 12th fifth (F→C) is not needed here: circleRatios[0] = .unison already anchors C.
        let orderedFifths: [Fifth] = [.cToG,
                                      .gToD,
                                      .dToA,
                                      .aToE,
                                      .eToB,
                                      .bToFSharp,
                                      .fSharpToCSharp,
                                      .cSharpToAFlat,
                                      .aFlatToEFlat,
                                      .eFlatToBFlat,
                                      .bFlatToF]

        // Frequency ratio for each of the 12 circle positions, relative to C, within [1, 2)
        // 0=C, 1=G, 2=D, 3=A, 4=E, 5=B, 6=F♯, 7=C♯, 8=A♭, 9=E♭, 10=B♭, 11=F
        var circleRatios = [Ratio](repeating: .unison,
                                   count: 12)

        for idx in 0..<11 {
            let next = circleRatios[idx].add(fifths[orderedFifths[idx]] ?? pureFifth)

            circleRatios[idx + 1] = (next >= .octave
                                     ? next.sub(.octave)
                                     : next)
        }

        // Chain position idx maps to the same circle index as (idx mod 12), so enharmonically
        // equivalent pitch classes always receive the exact same ratio value.
        return buildStandardConversion(for: standard) { circleRatios[(($0 % 12) + 12) % 12] }
    }
}

// MARK: - Sendable

extension WellTemperament: Sendable {
}
