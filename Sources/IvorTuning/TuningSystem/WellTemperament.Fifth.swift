// © 2025–2026 John Gary Pusey (see LICENSE.md)

extension WellTemperament {

    // MARK: Public Nested Types

    /// A position in the circle of fifths.
    public enum Fifth {
        /// The fifth from A♭ to E♭.
        case aFlatToEFlat

        /// The fifth from A to E.
        case aToE

        /// The fifth from B♭ to F.
        case bFlatToF

        /// The fifth from B to F♯.
        case bToFSharp

        /// The fifth from C♯ to A♭.
        case cSharpToAFlat

        /// The fifth from C to G.
        case cToG

        /// The fifth from D to A.
        case dToA

        /// The fifth from E♭ to B♭.
        case eFlatToBFlat

        /// The fifth from E to B.
        case eToB

        /// The fifth from F♯ to C♯.
        case fSharpToCSharp

        /// The fifth from F to C.
        case fToC

        /// The fifth from G to D.
        case gToD
    }
}

// MARK: - Sendable

extension WellTemperament.Fifth: Sendable {
}
