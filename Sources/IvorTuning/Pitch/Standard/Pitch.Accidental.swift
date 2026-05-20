// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

extension Pitch {

    // MARK: Public Nested Types

    /// An accidental modifier applied to a pitch letter.
    public enum Accidental {

        /// A double-flat accidental (𝄫), lowering a pitch by two semitones.
        case doubleFlat

        /// A flat accidental (♭), lowering a pitch by one semitone.
        case flat

        /// A natural accidental (♮), indicating no modification.
        case natural

        /// A sharp accidental (♯), raising a pitch by one semitone.
        case sharp

        /// A double-sharp accidental (𝄪), raising a pitch by two semitones.
        case doubleSharp
    }
}

// MARK: -

extension Pitch.Accidental {

    // MARK: Public Initializers

    /// Creates an accidental from its string representation.
    ///
    /// - Parameter stringValue:    The string representation of the accidental.
    ///
    /// - Throws:   `ParseError` if `stringValue` does not match a known accidental symbol.
    public init(stringValue: String) throws {
        guard let accidental = Self.accidentals[stringValue]
        else { throw ParseError.invalidPitchAccidental(stringValue) }

        self = accidental
    }

    // MARK: Public Instance Properties

    /// The numeric order of this accidental relative to natural.
    public var order: Int {
        Self.orders[self].require()
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
                                                      "𝄪": .doubleSharp,
                                                      "x": .doubleSharp]

    private static let orders: [Self: Int] = [.doubleFlat: -2,
                                              .flat: -1,
                                              .natural: 0,
                                              .sharp: 1,
                                              .doubleSharp: 2]

    private static let stringValues: [Self: String] = [.doubleFlat: "𝄫",
                                                       .flat: "♭",
                                                       .natural: "♮",
                                                       .sharp: "♯",
                                                       .doubleSharp: "𝄪"]
}

// MARK: - CustomStringConvertible

extension Pitch.Accidental: CustomStringConvertible {

    /// The Unicode symbol for this accidental (e.g., `"♭"`, `"♯"`, `"♮"`, `"𝄫"`, `"𝄪"`).
    public var description: String {
        Self.stringValues[self].require()
    }
}

// MARK: - Sendable

extension Pitch.Accidental: Sendable {
}
