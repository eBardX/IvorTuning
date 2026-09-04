// © 2025–2026 John Gary Pusey (see LICENSE.md)

import IvorTuning

/// A minimal `IntervalProtocol` conformer that is neither `Interval`, `NoteDistance`, nor
/// `Ratio` — used to exercise the fallback case of `IntervalProtocol.formatted()`.
struct StubInterval: IntervalProtocol {
    var isUnison: Bool {
        false
    }

    func adding(_ other: Self) -> Self? {
        nil
    }

    func subtracting(_ other: Self) -> Self? {
        nil
    }
}

/// A minimal `PitchProtocol` conformer that is neither `Frequency`, `NoteNumber`, nor
/// `Pitch` — used to exercise the fallback case of `PitchProtocol.formatted()`.
struct StubPitch: PitchProtocol {
    typealias IntervalType = NoteDistance

    static func < (lhs: Self,
                   rhs: Self) -> Bool {
        false
    }

    func interval(to pitch: Self) -> DirectedInterval<NoteDistance>? {
        nil
    }

    func transposed(by directedInterval: DirectedInterval<NoteDistance>) -> Self? {
        nil
    }
}

/// A minimal `TuningSystem` conformer that overrides neither `equivalenceRatio` nor
/// `standardConversion(for:)` — used to exercise the protocol's default implementations.
struct StubTuningSystem: TuningSystem {
}
