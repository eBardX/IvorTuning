private import XestiTools

extension Pitch {

    // MARK: Public Nested Types

    public enum Letter {
        case c
        case d
        case e
        case f
        case g
        case a
        case b
    }
}

// MARK: -

extension Pitch.Letter {

    // MARK: Public Initializers

    public init?(stringValue: String) {
        guard let letter = Self.letters[stringValue]
        else { return nil }

        self = letter
    }

    // MARK: Public Instance Properties

    public var order: Int {
        Self.orders[self].require()
    }

    // MARK: Private Type Properties

    private static let letters: [String: Self] = ["A": .a,
                                                  "B": .b,
                                                  "C": .c,
                                                  "D": .d,
                                                  "E": .e,
                                                  "F": .f,
                                                  "G": .g]

    private static let orders: [Self: Int] = [.a: 6,
                                              .b: 7,
                                              .c: 1,
                                              .d: 2,
                                              .e: 3,
                                              .f: 4,
                                              .g: 5]

    private static let stringValues: [Self: String] = [.a: "A",
                                                       .b: "B",
                                                       .c: "C",
                                                       .d: "D",
                                                       .e: "E",
                                                       .f: "F",
                                                       .g: "G"]
}

// MARK: - CustomStringConvertible

extension Pitch.Letter: CustomStringConvertible {
    public var description: String {
        Self.stringValues[self].require()
    }
}

// MARK: - Sendable

extension Pitch.Letter: Sendable {
}
