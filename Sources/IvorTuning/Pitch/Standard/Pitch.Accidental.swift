// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension Pitch {

    // MARK: Public Nested Types

    /// An accidental modifier applied to a diatonic letter. Combined with the seven diatonic
    /// letters, the five accidentals yield the 35 pitch classes of standard notation.
    public enum Accidental {

        /// A double-flat accidental (𝄫), lowering a pitch by two semitones.
        case doubleFlat

        /// A double-sharp accidental (𝄪), raising a pitch by two semitones.
        case doubleSharp

        /// A flat accidental (♭), lowering a pitch by one semitone.
        case flat

        /// A natural accidental (♮), indicating no modification.
        case natural

        /// A sharp accidental (♯), raising a pitch by one semitone.
        case sharp

        // MARK: Public Initializers

        /// Creates an accidental from its string representation.
        ///
        /// - Parameter stringValue:    The string representation of the accidental.
        ///
        /// - Throws:   `ParseError` if `stringValue` does not match a known accidental symbol.
        public init(stringValue: String) throws(ParseError) {
            guard let accidental = Self.accidentals[stringValue]
            else { throw ParseError.invalidPitchAccidental(stringValue) }

            self = accidental
        }
    }
}

// MARK: -

extension Pitch.Accidental {

    // MARK: Public Instance Properties

    /// The numeric order of this accidental relative to natural.
    public var order: Int {
        switch self {
        case .doubleFlat:
            -2

        case .doubleSharp:
            2

        case .flat:
            -1

        case .natural:
            0

        case .sharp:
            1
        }
    }

    // MARK: Private Type Properties

    private static let accidentals: [String: Self] = ["𝄫": .doubleFlat,
                                                      "bb": .doubleFlat,
                                                      "♭": .flat,
                                                      "b": .flat,
                                                      "♮": .natural,
                                                      "": .natural,
                                                      "♯": .sharp,
                                                      "#": .sharp,
                                                      "##": .doubleSharp,
                                                      "𝄪": .doubleSharp,
                                                      "x": .doubleSharp]
}

// MARK: - CaseIterable

extension Pitch.Accidental: CaseIterable {
}

// MARK: - CustomStringConvertible

extension Pitch.Accidental: CustomStringConvertible {

    /// The Unicode symbol for this accidental (e.g., `"♭"`, `"♯"`, `"♮"`, `"𝄫"`, `"𝄪"`).
    public var description: String {
        switch self {
        case .doubleFlat:
            "𝄫"

        case .doubleSharp:
            "𝄪"

        case .flat:
            "♭"

        case .natural:
            "♮"

        case .sharp:
            "♯"
        }
    }
}

// MARK: - Equatable

extension Pitch.Accidental: Equatable {
}

// MARK: - Sendable

extension Pitch.Accidental: Sendable {
}
