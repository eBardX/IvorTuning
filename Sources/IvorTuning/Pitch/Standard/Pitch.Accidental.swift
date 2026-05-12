private import XestiTools

extension Pitch {

    // MARK: Public Nested Types

    public enum Accidental {
        case doubleFlat
        case flat
        case natural
        case sharp
        case doubleSharp
    }
}

// MARK: -

extension Pitch.Accidental {

    // MARK: Public Initializers

    public init?(stringValue: String) {
        guard let accidental = Self.accidentals[stringValue]
        else { return nil }

        self = accidental
    }

    // MARK: Public Instance Properties

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
    public var description: String {
        Self.stringValues[self].require()
    }
}

// MARK: - Sendable

extension Pitch.Accidental: Sendable {
}
